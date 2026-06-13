{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  plover,
  setuptools,
  nix-update-script,
}:

buildPythonPackage (finalAttrs: {
  pname = "plover-next-stroke";
  version = "0.2.2";
  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Kaoffie";
    repo = "plover_next_stroke";
    rev = "62090e25514d53d3775ac28343ad28ede41fa5c9";
    hash = "sha256-GU02AxN6jV4FG7JeGBI3N+p4P0mgBufD6R48rkh1uGo=";
  };

  postPatch = lib.optionalString (lib.versionAtLeast plover.version "5") ''
    substituteInPlace plover_next_stroke/next_stroke_ui.py \
      --replace-fail \
        "    QHeaderView, QLabel, QPlainTextEdit, QAction," \
        "    QHeaderView, QLabel, QPlainTextEdit," \
      --replace-fail \
        "from PyQt5.QtGui import QIcon, QKeySequence" \
        "from PySide6.QtGui import QIcon, QKeySequence, QAction"

    for _file in plover_next_stroke/{config_ui,next_stroke_suggestions,next_stroke_ui}.py; do
      substituteInPlace "$_file" \
        --replace-fail "PyQt5" "PySide6"
    done

    mv plover_next_stroke/resources/resources.qrc plover_next_stroke

    substituteInPlace plover_next_stroke/resources.qrc \
      --replace-fail "<file>" "<file>resources/"

    echo "
    exclude plover_next_stroke/*_rc.py
    recursive-include plover_next_stroke *.ui *.qrc
    recursive-include plover_next_stroke/resources *
    include plover_next_stroke/*.py
    include README* LICENSE*
    " > MANIFEST.in
  '';

  build-system = [
    plover
    setuptools
  ];

  dependencies = [
    plover
  ]
  ++ plover.optional-dependencies.gui-qt;

  pythonImportsCheck = [
    "plover_next_stroke"

    # Modules providing Plover entry points
    "plover_next_stroke.next_stroke_suggestions"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Next Stroke Suggestions GUI Plugin for Plover Steno";
    homepage = "https://github.com/Kaoffie/plover_next_stroke";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      ShamrockLee
    ];
  };
})
