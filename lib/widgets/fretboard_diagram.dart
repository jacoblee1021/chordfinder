import 'package:flutter/material.dart';

/// Simple widget representing a fretboard diagram with six strings and dots.
///
/// This is currently a placeholder: it draws a grid of 6x4 (strings x frets)
/// and optionally shows a few example dots. Later it will be driven by
/// real chord data.
class FretboardDiagram extends StatelessWidget {
  /// Finger positions for the six strings, low E first. Use -1 for mute and
  /// 0 for open.
  final List<int> positions;

  /// Optional finger numbers in parallel with [positions]; values >=1 are
  /// drawn inside the dots. If omitted the dots are just black circles.
  final List<int>? fingers;

  /// If true, show the 'Fret x' label above the diagram instead of to the left.
  final bool showFretLabelAbove;
  /// If true, show the 'Fret x' label to the right of the diagram.
  final bool showFretLabelRight;

  const FretboardDiagram({
    super.key,
    required this.positions,
    this.fingers,
    this.showFretLabelAbove = false,
    this.showFretLabelRight = false,
  });

  @override
  Widget build(BuildContext context) {
    // Standard tuning notes for 6-string guitar (low E to high E)
    const tuningNotes = ['E', 'A', 'D', 'G', 'B', 'E'];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 210, // Increased diagram height
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding
                child: CustomPaint(
                  painter: _FretboardPainter(positions: positions, fingers: fingers),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 22,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(6, (i) =>
                Expanded(
                  child: Center(
                    child: Text(
                      tuningNotes[i],
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF525252),
                        height: 1.2,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FretboardPainter extends CustomPainter {
  final List<int> positions;
  final List<int>? fingers;

  _FretboardPainter({required this.positions, this.fingers});

  @override
  void paint(Canvas canvas, Size size) {
    // paints with uniform stroke width for strings and frets, plus border
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // determine range of frets to display based on positions
    final nonOpen = positions.where((f) => f > 0).toList();
    int minFret = nonOpen.isEmpty ? 1 : nonOpen.reduce((a, b) => a < b ? a : b);
    int maxFret = nonOpen.isEmpty ? 1 : nonOpen.reduce((a, b) => a > b ? a : b);
    final fretCount = (maxFret - minFret + 1).clamp(4, 6);

    // swap axes: strings vertical, frets horizontal
    final double stringSpacing =
        size.width / 5; // six strings => 5 spaces across width
    final double fretSpacing = size.height / fretCount;

    // draw border around the fretboard
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    // draw strings (vertical lines)
    for (int i = 0; i < 6; i++) {
      final x = i * stringSpacing;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    // draw frets (horizontal lines), nut at top if start fret is 1
    final nutPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 6; // prominent nut
    for (int f = 0; f <= fretCount; f++) {
      final y = f * fretSpacing;
      final isNut = (f == 0 && minFret == 1);
      if (isNut) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), nutPaint);
      } else {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      }
    }

    // draw finger dots with slightly smaller radius
    const double dotRadius = 11;
    final dotPaint = Paint()..color = Colors.black;
    for (int s = 0; s < 6; s++) {
      final fret = positions[s];
      if (fret <= 0) continue;
      final relative = fret - minFret; // zero-based
      final y = (relative + 0.5) * fretSpacing;
      final x = s * stringSpacing;
      canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);

      // finger number if provided
      if (fingers != null && s < fingers!.length && fingers![s] > 0) {
        final textSpan = TextSpan(
          text: '${fingers![s]}',
          style: TextStyle(color: Colors.white, fontSize: 14),
        );
        final tp = TextPainter(
            text: textSpan,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
      }
    }

    // draw open (circle) or muted (X) markers inside first fret area (top)
    final markerPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;
    final double markerY = fretSpacing * 0.2;
    for (int s = 0; s < 6; s++) {
      final fret = positions[s];
      final x = s * stringSpacing;
      if (fret == 0) {
        canvas.drawCircle(
            Offset(x, markerY), 6, Paint()..style = PaintingStyle.stroke);
      } else if (fret < 0) {
        final offset = 5.0;
        canvas.drawLine(Offset(x - offset, markerY - offset),
            Offset(x + offset, markerY + offset), markerPaint);
        canvas.drawLine(Offset(x - offset, markerY + offset),
            Offset(x + offset, markerY - offset), markerPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FretboardPainter old) {
    if (old.positions.length != positions.length) return true;
    for (int i = 0; i < positions.length; i++) {
      if (old.positions[i] != positions[i]) return true;
    }
    return false;
  }
}
