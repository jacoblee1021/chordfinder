/// Returns the chord shapes for a given root and type, transposed from C-based shapes.
library chord_data;

List<List<int>> getChordShapes(String root, String type) {
  final baseShapes = baseChordShapes[type];
  if (baseShapes == null) return [];

  int semitoneOffset = chromaticScale.indexOf(root);

  return baseShapes.map((shape) {
    return shape.map((fret) {
      if (fret == -1) return -1;
      return fret + semitoneOffset;
    }).toList();
  }).toList();
}

/// Base chord shapes defined in the key of C.
/// These will be transposed to other roots dynamically.
/// Each shape is a 6-element list (low E → high E)
/// -1 = mute, 0 = open

const Map<String, List<List<int>>> baseChordShapes = {
  'Major': [
    [-1, 3, 2, 0, 1, 0], // C shape (open)
    [3, 3, 5, 5, 5, 3], // A shape
    [8, 10, 10, 9, 8, 8], // E shape
    [10, 12, 12, 12, 10, 10], // D shape
    [7, 10, 10, 9, 8, 7], // G shape
  ],
  'Minor': [
    [-1, 3, 5, 5, 4, 3], // Cm shape
    [3, 5, 5, 3, 3, 3], // Am shape
    [8, 10, 10, 8, 8, 8], // Em shape
    [10, 12, 12, 10, 10, 10], // Dm shape
    [7, 10, 10, 8, 8, 7], // Gm shape
  ],
  '7': [
    [-1, 3, 2, 3, 1, 0], // C7 open
    [3, 3, 5, 3, 5, 3],
    [8, 10, 8, 9, 8, 8],
    [10, 12, 10, 12, 10, 10],
    [7, 10, 8, 9, 8, 7],
  ],
  'Maj7': [
    [-1, 3, 2, 0, 0, 0],
    [3, 3, 5, 4, 5, 3],
    [8, 10, 9, 9, 8, 8],
    [10, 12, 12, 12, 12, 10],
    [7, 10, 9, 9, 8, 7],
  ],
  'm7': [
    [-1, 3, 5, 3, 4, 3],
    [3, 5, 3, 3, 3, 3],
    [8, 10, 8, 8, 8, 8],
    [10, 12, 10, 10, 10, 10],
    [7, 10, 8, 8, 8, 7],
  ],
  'Sus2': [
    [-1, 3, 0, 0, 1, 3],
    [3, 3, 5, 5, 3, 3],
    [8, 10, 10, 10, 8, 8],
    [10, 12, 12, 12, 10, 10],
    [7, 10, 10, 10, 8, 7],
  ],
  'Sus4': [
    [-1, 3, 3, 0, 1, 1],
    [3, 3, 5, 5, 6, 3],
    [8, 10, 10, 10, 11, 8],
    [10, 12, 12, 12, 13, 10],
    [7, 10, 10, 10, 11, 7],
  ],
  'Add9': [
    [-1, 3, 2, 0, 3, 0],
    [3, 3, 5, 5, 3, 3],
    [8, 10, 10, 9, 10, 8],
    [10, 12, 12, 12, 10, 10],
    [7, 10, 10, 9, 10, 7],
  ],
};

/// Chromatic scale (use sharps only for simplicity)
const List<String> chromaticScale = [
  'C',
  'C#',
  'D',
  'D#',
  'E',
  'F',
  'F#',
  'G',
  'G#',
  'A',
  'A#',
  'B'
];
