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

  const FretboardDiagram({super.key, required this.positions, this.fingers});

  @override
  Widget build(BuildContext context) {
    // compute the lowest fretted note (non-zero and >0) to determine start.
    final fretted = positions.where((f) => f > 0);
    final startFret =
        fretted.isEmpty ? 1 : fretted.reduce((a, b) => a < b ? a : b);
    const labels = ['E', 'A', 'D', 'G', 'B', 'E'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 2 / 3,
                  child: CustomPaint(
                    painter: _FretboardPainter(
                        positions: positions, fingers: fingers),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 24,
                  child: Stack(
                    children: List.generate(labels.length, (i) {
                      final alignment = Alignment(-1.0 + 0.4 * i, 0);
                      return Align(
                        alignment: alignment,
                        child: Text(labels[i],
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 4.0),
            child: Text('Fret $startFret',
                style: const TextStyle(fontWeight: FontWeight.bold)),
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
    const nutHeight = 10.0;
    final nutPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    for (int f = 0; f <= fretCount; f++) {
      final y = f * fretSpacing;
      final isNut = (f == 0 && minFret == 1);
      if (isNut) {
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, nutHeight), nutPaint);
      } else {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      }
    }

    // draw finger dots with increased radius
    const double dotRadius = 14;
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
