patchRcPathFish(){
    local FILE_TO_PATCH="$1"
    local SOURCETIME_PATH="$2"
    local FILE_TO_WORK_ON="$(mktemp "$(basename "$FILE_TO_PATCH").XXXXXX.tmp")"
    cat <<EOF >> "$FILE_TO_WORK_ON"
# Add to PATH the source-time utilities for Nixpkgs packaging
set -g --path PATH "$SOURCETIME_PATH" \$PATH
EOF
    cat "$FILE_TO_PATCH" >> "$FILE_TO_WORK_ON"
    cat <<EOF >> "$FILE_TO_WORK_ON"
# Lines to clean up inside PATH the source-time utilities for Nixpkgs packaging
begin
    set --path _SOURCETIME_PATH "$SOURCETIME_PATH"
    if set -q PATH && test "\$PATH" != "" && test (count \$PATH) -ge (count \$_SOURCETIME_PATH)
        # Remove the inserted section
        for i in (seq 0 (math (count \$PATH) - (count \$_SOURCETIME_PATH)))
            for j in (seq 1 (count \$_SOURCETIME_PATH))
                if test \$PATH[(math \$i + \$j)] != \$_SOURCETIME_PATH[\$j]
                    set i -1
                    break
                end
            end
            if test \$i -eq -1
                continue
            end
            if test \$i -eq 0
                set -g --path PATH \$PATH[(math (count \$_SOURCETIME_PATH) + 1)..]
            else
                set -g --path PATH \$PATH[..\$i] \$PATH[(math (count \$_SOURCETIME_PATH) + 1 + \$i)..]
            end
            break
        end
    end
end
# End of lines to clean up inside PATH the source-time utilities for Nixpkgs packaging
EOF
    cat "$FILE_TO_WORK_ON" > "$FILE_TO_PATCH"
    rm "$FILE_TO_WORK_ON"
}
