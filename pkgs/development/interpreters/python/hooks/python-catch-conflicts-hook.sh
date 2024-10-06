# Setup hook for detecting conflicts in Python packages
# shellcheck shell=bash

echo "Sourcing python-catch-conflicts-hook.sh"

pythonCatchConflictsPhase() {
    PYTHONPATH="@setuptools@/@pythonSitePackages@:$PYTHONPATH" @pythonInterpreter@ @catchConflicts@
}

if [ -z "${dontUsePythonCatchConflicts-}" ]; then
    appendToVar preDistPhases pythonCatchConflictsPhase
fi
