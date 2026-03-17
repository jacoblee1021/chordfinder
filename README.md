# Chord Finder

Flutter-based application designed to help guitarists locate alternative chord positions on the fretboard.

## Features

- Select from a list of major and minor chords.
- Visual chord diagrams with six strings and fret information.
- Multiple variations per chord, moving progressively up the fretboard.

## Getting Started

### Prerequisites

- Flutter SDK installed (see https://flutter.dev/docs/get-started/install)
- Visual Studio Code with Flutter/Dart extensions

### Setup

```bash
flutter pub get
```

### Running

```bash
flutter run
```

A few built-in tasks are defined in `.vscode/tasks.json`:

- **flutter pub get** – install dependencies
- **flutter run** – launch the app on a connected device or emulator

If you use VS Code, you can also start debugging using the Flutter extension (F5) or run the tasks from the Command Palette.

## Next Steps

- Implement `FretboardDiagram` widget to render chord shapes based on position data.
  * Diagram is styled with a thick border and uniform line weights; strings and frets intersect in a tall vertical layout. When the chord starts at fret 1 a thicker top line represents the nut; this is omitted for higher‑fret shapes.
  * Strings run vertically and frets horizontally (rotated 90°) to match common chord chart layouts.
  * Finger numbers are not shown; only black dots indicate fretted strings.
- Populate chord variations in `lib/chord_data.dart` and use them to drive the diagram.  Variations are ordered according to the CAGED system (open shapes first, then barre shapes up the neck).  Duplicate shapes an octave apart (e.g. open vs. 12th-fret versions) are automatically filtered out, and the remaining shapes are sorted by their lowest fretted position so the sequence moves up the neck.
- Add UI controls for switching between variations and showing the fret where the shape starts (number placed left of the board).
- Chord list is generated from available data; empty chords show a placeholder message.

---

The copilot-instructions.md in `.github` contains the project scaffold checklist.