# HyperStudio Author 1.0 (build 156), Universal 2

Source translation of MacKiev's HyperStudio Author (i386-only, `com.mackiev.hyperstudioauthor`)
into Objective-C that builds as a fat arm64 + x86_64 app for macOS 11+.

HyperStudio Author shares about 97 % of its classes with HyperStudio 5.2, so this tree starts
from the translated HyperStudio 5 sources (`src/`) and is brought in line with the Author binaries:

* `analysis/`           thin i386 binaries and Objective-C metadata of the Author frameworks
* `baseline-analysis/`  the same for HyperStudio 5.2 (symlink to the HyperStudio5-Universal2 checkout)
* `game/`               the original Author app bundle, used for its resources (symlink)
* `docs/delta.json`     classes and selectors that differ between the two (`tools/delta.py`)

Workflow: `make` builds everything, `tools/delta.py` lists what differs, the differing methods are
decompiled (`tools/decompile.sh`) and translated like the HyperStudio 5 ones.
