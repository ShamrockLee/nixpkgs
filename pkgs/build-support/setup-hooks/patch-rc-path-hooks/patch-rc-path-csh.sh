patchRcPathCsh(){
    local FILE_TO_PATCH="$1"
    local SOURCETIME_PATH="$2"
    local FILE_TO_WORK_ON="$(mktemp "$(basename "$FILE_TO_PATCH").XXXXXX.tmp")"
    cat <<EOF >> "$FILE_TO_WORK_ON"
# Lines to add to PATH the source-time utilities for Nixpkgs packaging
if (! \$?PATH) then
    setenv PATH ""
endif
if ("\$PATH" != "") then
    setenv PATH "${SOURCETIME_PATH}:\$PATH"
else
    setenv PATH "$SOURCETIME_PATH"
endif
# End of lines to add to PATH source-time utilities for Nixpkgs packaging
EOF
    cat "$FILE_TO_PATCH" >> "$FILE_TO_WORK_ON"
    cat <<EOF >> "$FILE_TO_WORK_ON"
# Lines to clean up inside PATH the source-time utilities for Nixpkgs packaging
if (\$?PATH) then
    if ("\$PATH" != "") then
        # Remove the inserted section, the duplicated colons, and the leading and trailing colon
        setenv PATH \`echo "\$PATH" | @sed@ "s/${SOURCETIME_PATH//\//\\\/}//" | @sed@ "s/::/:/g" | @sed@ "s/^://" | @sed@ 's/:\$//'\`
    endif
endif
# End of lines to clean up inside PATH the source-time utilities for Nixpkgs packaging
EOF
    cat "$FILE_TO_WORK_ON" > "$FILE_TO_PATCH"
    rm "$FILE_TO_WORK_ON"
}
