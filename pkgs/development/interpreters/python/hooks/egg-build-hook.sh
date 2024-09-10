# Setup hook to use for eggs
# shellcheck shell=bash

echo "Sourcing egg-build-hook"

eggBuildPhase() {
    echo "Executing eggBuildPhase"
    runHook preBuild

    runHook postBuild
    echo "Finished executing eggBuildPhase"
}

if [ -z "${dontUseEggBuild-}" ] && [ -z "${buildPhase-}" ]; then
    echo "Using eggBuildPhase"
    buildPhase=eggBuildPhase
fi
