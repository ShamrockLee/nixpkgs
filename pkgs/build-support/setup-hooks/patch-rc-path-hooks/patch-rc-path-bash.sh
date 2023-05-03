patchRcPathBashGenHead() {
    local SOURCETIME_PATH="$1"
    cat <<EOF
# Add to PATH the source-time utilities for Nixpkgs packaging
PATH="$SOURCETIME_PATH\${PATH:+:}\${PATH-}"; export PATH
EOF
}

patchRcPathBashGenTail() {
    local SOURCETIME_PATH="$1"
    cat <<EOF
# Lines to clean up inside PATH the source-time utilities for Nixpkgs packaging
if [[ -n "\${PATH-}" ]]; then
    # Remove the inserted section
    PATH="\${PATH/${SOURCETIME_PATH//\//\\\/}}"
    # Remove the duplicated colons
    PATH="\${PATH//::/:}"
    # Remove the prefixing colon
    if [[ -n "\$PATH" && "\${PATH:0:1}" == ":" ]]; then
        PATH="\${PATH:1}"
    fi
    # Remove the trailing colon
    if [[ -n "\$PATH" && "\${PATH:\${#PATH}-1}" == ":" ]]; then
        PATH="\${PATH::}"
    fi
    export PATH
fi
# End of lines to clean up inside PATH the source-time utilities for Nixpkgs packaging
EOF
}

patchRcPathBash(){
    local FILE_TO_PATCH="$1"
    local SOURCETIME_PATH="$2"
    local FILE_TO_WORK_ON="$(mktemp "$(basename "$FILE_TO_PATCH").XXXXXX.tmp")"
    patchRcPathBashGenHead "$SOURCETIME_PATH" >> "$FILE_TO_WORK_ON"
    cat "$FILE_TO_PATCH" >> "$FILE_TO_WORK_ON"
    patchRcPathBashGenTail "$SOURCETIME_PATH" >> "$FILE_TO_WORK_ON"
    cat "$FILE_TO_WORK_ON" > "$FILE_TO_PATCH"
    rm "$FILE_TO_WORK_ON"
}
