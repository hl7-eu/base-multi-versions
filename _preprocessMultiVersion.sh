#!/bin/bash

set -e

# Optional CLI usage:
#   ./_preprocessMultiVersion.sh           -> build both 4.0.1 and 5.0.0
#   ./_preprocessMultiVersion.sh 4.0.1     -> build only 4.0.1
#   ./_preprocessMultiVersion.sh 5.0.0     -> build only 5.0.0
if [ "$#" -eq 0 ]; then
    versions=("4.0.1" "5.0.0")
elif [ "$#" -eq 1 ]; then
    versions=("$1")
else
    echo "Usage: $0 [4.0.1|5.0.0]"
    exit 1
fi

ig_base="base"

# liquidjs is installed once and then run through node directly. `npx --yes
# liquidjs` re-resolves the package on every single call, which stats its way
# through thousands of files in the npx cache and now and then asks the
# registry: about a second per template, against a tenth of a second for the
# render itself. Windows pays that overhead several times over.
#
# Installing once also removes the race this warm-up used to work around, where
# concurrent `npx --yes` calls could each try to populate the cache and produce
# empty output.
liquid_dir="$(pwd)/.liquidjs"
liquid_js="$liquid_dir/node_modules/liquidjs/bin/liquid.js"

if [ ! -f "$liquid_js" ]; then
    echo "Installing liquidjs into $liquid_dir"
    npm install --prefix "$liquid_dir" --no-save --no-audit --no-fund --silent liquidjs
fi

for version in "${versions[@]}"; do
    if [ "$version" = "4.0.1" ]; then
        context_version="R4"
        build_dir="igs/${ig_base}-r4"
    elif [ "$version" = "5.0.0" ]; then
        context_version="R5"
        build_dir="igs/${ig_base}-r5"
    fi

    mkdir -p "$build_dir"

    echo remove all files from $build_dir
    # rm -Rf $build_dir/*
    echo Setting read-only permissions on $build_dir
    chmod -R a+w "$build_dir"
    find "$build_dir" -maxdepth 1 -type f -exec rm -f {} +
    rm -Rf "$build_dir/input"
    rm -Rf "$build_dir/output"
    rm -Rf "$build_dir/ig-template"
    
    echo copy all files to  $build_dir
    find ig-src/ -maxdepth 1 -type f -exec cp {} "$build_dir" \;
    cp -R ig-src/input "$build_dir"
    cp -R ig-src/ig-template "$build_dir"
    
    # Process all liquid files
    echo Processing liquid files
    pids=()
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            (
                file_path=${file}
                clean_file_path=${file_path/\.liquid\./\.}
                echo "- $file_path --> $clean_file_path"

                # Process liquid template and inline version tags
                if ! content=$(node "$liquid_js" -t @"$file" --context @"context-${context_version}.json"); then
                    echo "Failed to process liquid file: $file"
                    exit 1
                fi
                printf '%s\n' "$content" > "$clean_file_path"
                rm -f "$file"
            ) &
            pids+=("$!")
        fi
    done < <(find "$build_dir" -type f -name "*.liquid.*" -print0)

    for pid in "${pids[@]}"; do
        wait "$pid"
    done

    # # make readonly
    # echo Setting read-only permissions on $build_dir
    # chmod -R a-w $build_dir
done
