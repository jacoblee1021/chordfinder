/// Chord shape data. Each chord maps to a list of variations, where each
/// variation is simply a list of six fret numbers (low‑E to high‑E). A value of
/// -1 means mute and 0 means open. Variations are ordered roughly according to
/// the CAGED sequence: open shapes first, then moveable barre forms along the
/// neck (C, A, G, E, D positions).

const Map<String, List<List<int>>> chordVariations = {
  'C Major': [
    [-1, 3, 2, 0, 1, 0], // open C
    [3, 3, 5, 5, 5, 3], // A shape barre at 3
    [7, 10, 10, 9, 8, 7], // G shape at 7
    [8, 10, 10, 9, 8, 8], // E shape at 8
    [10, 12, 12, 12, 10, 10], // D shape at 10
  ],
  'A Minor': [
    [-1, 0, 2, 2, 1, 0], // open Am
    [5, 7, 7, 5, 5, 5], // E shape at 5
    [7, 5, 5, 5, 7, 7], // C shape at 7 (movable)
    [12, 14, 14, 13, 12, 12], // A shape at 12 (optional)
    [17, 19, 19, 17, 17, 17], // G shape at 17 (upper stretch, near 12+)
  ],
  'G Major': [
    [3, 2, 0, 0, 0, 3], // open G
    [5, 5, 4, 4, 3, 3], // E shape at 5
    [7, 10, 10, 9, 8, 7], // C shape at 7
    [10, 12, 12, 12, 10, 10], // A shape at 10
    [12, 14, 14, 12, 12, 12], // D shape at 12 (if needed)
  ],
  'E Major': [
    [0, 2, 2, 1, 0, 0], // open E
    [7, 9, 9, 9, 7, 7], // A shape at 7
    [9, 11, 11, 9, 9, 9], // D shape at 9
    [12, 14, 14, 13, 12, 12], // G shape at 12
    [17, 19, 19, 18, 17, 17], // C shape at 17
  ],
  'D Major': [
    [-1, -1, 0, 2, 3, 2], // open D
    [5, 5, 7, 7, 7, 5], // A shape at 5
    [7, 9, 9, 7, 7, 7], // E shape at 7
    [10, 12, 12, 12, 10, 10], // C shape at 10
    [12, 14, 14, 12, 12, 12], // G shape at 12
  ],
  'F Major': [
    [1, 3, 3, 2, 1, 1], // F barre open
    [3, 5, 5, 5, 3, 3], // E shape at 3: low F root
    [8, 10, 10, 10, 8, 8], // C shape at 8
    [10, 12, 12, 12, 10, 10], // A shape at 10
    [13, 15, 15, 14, 13, 13], // G shape at 13 (just above 12)
  ],
  'B Minor': [
    [-1, 2, 4, 4, 3, 2], // Bm barre open
    [7, 9, 9, 7, 7, 7], // E shape at 7
    [9, 11, 11, 10, 9, 9], // C shape at 9
    [12, 14, 14, 13, 12, 12], // A shape at 12
    [14, 16, 16, 14, 14, 14], // G shape at 14 (optional)
  ],
};
