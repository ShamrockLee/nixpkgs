# Setup hook for PyPA installer.
# shellcheck shell=bash

echo "Sourcing pypa-install-hook"

# shellcheck source=pkgs/stdenv/generic/setup.sh
source /dev/null

pypaInstallPhase() {
    echo "Executing pypaInstallPhase"
    runHook preInstall

    pushd dist >/dev/null

    for wheel in *.whl; do
        # shellcheck disable=2154
        @pythonInterpreter@ -m installer --prefix "$out" "$wheel"
        echo "Successfully installed $wheel"
    done

    popd >/dev/null

    export PYTHONPATH="$out/@pythonSitePackages@:$PYTHONPATH"

    runHook postInstall
    echo "Finished executing pypaInstallPhase"
}

if [ -z "${dontUsePypaInstall-}" ] && [ -z "${installPhase-}" ]; then
    echo "Using pypaInstallPhase"
    installPhase=pypaInstallPhase
fi
