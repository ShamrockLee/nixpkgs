# Helper Bash functions to build compatibility layers.
# shellcheck shell=bash

# shellcheck source=pkgs/stdenv/generic/setup.sh
source /dev/null

_evalAndConcatTo() {
    local targetName="$1"
    shift
    for sourceName in "$@"; do
        local -a flagsArray=()
        if [[ -v "$sourceName" ]]; then
            local -n sourceRef="$sourceName"
            if [[ "$(declare -p "$sourceName")" =~ "^declare -a" ]]; then
                flagsArray=("${sourceRef[@]}")
            else
                # Bash-evaluate only when the sourceRef is not a Bash array.
                local -a "flagsArray=($sourceRef)"
            fi
            unset -n sourceRef
        fi
        concatTo "$targetName" flagsArray
        unset flagsArray
    done
}

_canonicalizeFlagsArrayEval() {
    local varName="$1"
    local -n varRef="$varName"
    local varText="${varRef[*]-}"
    unset -n varRef
    unset "$varName"
    declare -ga "$varName=($varText)"
}
