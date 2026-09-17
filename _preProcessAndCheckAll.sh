#!/bin/bash

set -e

ig_base="base"

selected_versions=()

if [ "$#" -eq 0 ]; then
	selected_versions=("4.0.1" "5.0.0")
elif [ "$#" -eq 1 ] && { [ "$1" = "4.0.1" ] || [ "$1" = "5.0.0" ]; }; then
	selected_versions=("$1")
else
	echo "Usage: $0 [4.0.1|5.0.0]"
	exit 1
fi

# The version of the latest IG publisher release, looked up once and cached in
# latest_publisher_version. Empty when the lookup fails, i.e. when offline.
latest_publisher_version=""
latest_publisher_version_checked=false
lookup_latest_publisher_version() {
	if [ "$latest_publisher_version_checked" = false ]; then
		latest_publisher_version_checked=true
		latest_publisher_version=$(curl -sf --max-time 10 \
			https://api.github.com/repos/HL7/fhir-ig-publisher/releases/latest \
			| grep '"tag_name"' | cut -d'"' -f4)
	fi
}

# Replaces the publisher in the FHIR publisher home when a newer release is
# available. A publisher.jar in the input-cache of the IG or in the parent
# directory is a deliberate override that takes precedence over the central
# one, so it is only reported, not touched.
update_publisher_if_outdated() {
	jar="$1"
	lookup_latest_publisher_version
	if [ -z "$latest_publisher_version" ]; then
		echo "Latest IG Publisher version could not be determined (offline?), keeping $jar"
		return 0
	fi

	current_publisher_version=$(java -jar "$jar" -v 2>/dev/null | tr -d '\r')
	if [ "$current_publisher_version" = "$latest_publisher_version" ]; then
		echo "IG Publisher $current_publisher_version is up to date"
		return 0
	fi

	if [ "$jar" != "$home_publisher" ]; then
		echo "WARNING: IG Publisher $current_publisher_version in $jar is outdated (latest: $latest_publisher_version)."
		echo "         It takes precedence over the central copy and is not updated automatically; remove it to use the central one."
		return 0
	fi

	echo "IG Publisher $current_publisher_version is outdated (latest: $latest_publisher_version). Starting _updateBuildTools.sh publisher..."
	./_updateBuildTools.sh publisher
}

ensure_build_assets_for_ig() {
	ig_dir="$1"
	# The same three locations _build.sh checks, in the same order of precedence
	local_publisher="$ig_dir/input-cache/publisher.jar"
	parent_publisher="$(dirname "$ig_dir")/publisher.jar"
	home_publisher="${FHIR_PUBLISHER_HOME:-$HOME/.fhir/tools/publisher}/publisher.jar"

	for jar in "$local_publisher" "$parent_publisher" "$home_publisher"; do
		if [ -f "$jar" ]; then
			echo "IG Publisher FOUND for $ig_dir: $jar"
			update_publisher_if_outdated "$jar"
			return 0
		fi
	done

	# _updateBuildTools.sh downloads the jar to the FHIR publisher home, the
	# central location shared by all IGs on this machine (_build.sh looks for it
	# there as well).
	echo "IG Publisher NOT FOUND for $ig_dir. Starting _updateBuildTools.sh publisher..."
	./_updateBuildTools.sh publisher

	if [ -f "$local_publisher" ] || [ -f "$parent_publisher" ] || [ -f "$home_publisher" ]; then
		echo "IG Publisher ready for $ig_dir"
		return 0
	fi

	echo "IG Publisher still missing for $ig_dir. Aborting..."
	return 1
}

build_ig() {
	version="$1"
	case "$version" in
		4.0.1)
			ig_dir="igs/${ig_base}-r4"
			;;
		5.0.0)
			ig_dir="igs/${ig_base}-r5"
			;;
		*)
			echo "Unsupported version: $version"
			return 1
			;;
	esac

	echo ==================================================================================
	echo "ensure publisher is available for $ig_dir"
	ensure_build_assets_for_ig "$ig_dir" || exit 1

	echo ==================================================================================
	echo "build $ig_dir using _build.sh ${build_args[*]}"
	(
		cd "$ig_dir" || exit 1
		# The terminology server is passed explicitly instead of using the build
		# option of _build.sh: that option decides between online and offline with
		# `ping tx.fhir.org`, which fails wherever ICMP is blocked - CI runners in
		# particular - and then silently builds with `-tx n/a`, which makes the
		# publisher fail while rendering value set narratives. An argument that is
		# not one of its own options is passed straight through to the publisher.
		./_build.sh "${build_args[@]}"
	)
}

# Determine the terminology server to use. curl is used rather than ping, as it
# reports what actually matters here and works where ICMP is blocked.
determine_tx_server() {
	if curl -sSf --max-time 10 -o /dev/null https://tx.fhir.org; then
		echo "Terminology server tx.fhir.org is available"
		build_args=(-tx https://tx.fhir.org)
	else
		echo "WARNING: tx.fhir.org is not reachable, building without terminology server."
		echo "         Terminology content will not publish correctly."
		build_args=(-tx n/a)
	fi
}

echo ==================================================================================
echo Preprocessing - generate FHIR version specific IG
./_preprocessMultiVersion.sh "$@"

echo ==================================================================================
determine_tx_server

for version in "${selected_versions[@]}"; do
	build_ig "$version"
done
