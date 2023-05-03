patchRcPathPosixGenHead(){
    local SOURCETIME_PATH="$1"
    cat <<EOF
# Add to PATH the source-time utilities for Nixpkgs packaging
PATH="$SOURCETIME_PATH\${PATH:+:}\${PATH-}"; export PATH
EOF
}

patchRcPathPosixGenTail(){
    local SOURCETIME_PATH="$1"
    cat <<EOF >> "$FILE_TO_WORK_ON"
# Lines to clean up inside PATH the source-time utilities for Nixpkgs packaging
if [ -n "\${PATH-}" ]; then
    PATH="\$(echo "\$PATH" | @sed@ "s/${SOURCETIME_PATH//\//\\\/}//" | @sed@ "s/::/:/g" | @sed@ "s/^://" | @sed@ "s/:\\\$//")"
    export PATH
fi
# End of lines to clean up inside PATH the source-time utilities for Nixpkgs packaging
EOF
}

patchRcPathPosix(){
    local FILE_TO_PATCH="$1"
    local SOURCETIME_PATH="$2"
    local FILE_TO_WORK_ON="$(mktemp "$(basename "$FILE_TO_PATCH").XXXXXX.tmp")"
    patchRcPathPosixGenHead "$SOURCETIME_PATH" >> "$FILE_TO_WORK_ON"
    cat "$FILE_TO_PATCH" >> "$FILE_TO_WORK_ON"
    patchRcPathPosixGenTail "$SOURCETIME_PATH" >> "$FILE_TO_WORK_ON"
    cat "$FILE_TO_WORK_ON" > "$FILE_TO_PATCH"
    rm "$FILE_TO_WORK_ON"
}
