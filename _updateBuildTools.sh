#!/bin/bash

set -e

# Updates the tooling used to build the IGs:
#
#   ./_updateBuildTools.sh             -> update both
#   ./_updateBuildTools.sh scripts     -> only _build.sh / _build.bat
#   ./_updateBuildTools.sh publisher   -> only publisher.jar
#
# The build scripts are maintained by HL7 in
# https://github.com/HL7/ig-publisher-scripts. The copies in igs/base-<rx> are
# overwritten on every preprocessing run, so they are updated in ig-src, the
# source for the generated IGs. Run ./_preprocessMultiVersion.sh afterwards to
# propagate them to the generated IGs.
#
# The publisher.jar is placed in the parent directory of the generated IGs, so
# that all FHIR versions share a single copy.

cd "$(dirname "$0")"

scriptdlroot="https://raw.githubusercontent.com/HL7/ig-publisher-scripts/main"
publisher_dlurl="https://github.com/HL7/fhir-ig-publisher/releases/latest/download/publisher.jar"
publisher_jar="igs/publisher.jar"

update_scripts=false
update_publisher=false

case "${1:-all}" in
    all)       update_scripts=true ; update_publisher=true ;;
    scripts)   update_scripts=true ;;
    publisher) update_publisher=true ;;
    *)
        echo "Usage: $0 [scripts|publisher]"
        exit 1
        ;;
esac

if [ "$update_scripts" = true ]; then
    for script in _build.sh _build.bat; do
        echo "Downloading $script"
        curl -fsSL "$scriptdlroot/$script" -o "ig-src/${script}.new"
        mv "ig-src/${script}.new" "ig-src/$script"
    done

    chmod +x ig-src/_build.sh

    echo "Build scripts updated in ig-src."
    echo "Run ./_preprocessMultiVersion.sh to propagate them to the generated IGs."
fi

if [ "$update_publisher" = true ]; then
    mkdir -p "$(dirname "$publisher_jar")"

    echo "Downloading $publisher_jar (~200 MB)"
    if ! curl -fL "$publisher_dlurl" -o "${publisher_jar}.new"; then
        rm -f "${publisher_jar}.new"
        echo "Downloading the IG Publisher failed. Aborting..."
        exit 1
    fi
    mv "${publisher_jar}.new" "$publisher_jar"

    echo "IG Publisher updated: $publisher_jar"
fi
