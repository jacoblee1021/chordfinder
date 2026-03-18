import 'package:flutter/material.dart';

import 'chord_data.dart';
import 'widgets/fretboard_diagram.dart';

void main() {
  runApp(const ChordFinderApp());
}

class ChordFinderApp extends StatelessWidget {
  const ChordFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chord Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedChord = 'C Major';
  int _variationIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<List<int>> get _currentVariations {
    final raw = chordVariations[_selectedChord] ?? [];
    // remove duplicates that are 12 frets apart (e.g. open shape repeated at 12th)
    final seen = <String>{};
    final filtered = <List<int>>[];
    for (final v in raw) {
      final key =
          v.map((f) => f <= 0 ? f.toString() : (f % 12).toString()).join(',');
      if (!seen.contains(key)) {
        seen.add(key);
        filtered.add(v);
      }
    }
    // sort by first fretted position (ascending) to follow neck progression
    filtered.sort((a, b) {
      int minA = a.where((f) => f > 0).fold<int>(999, (x, y) => x < y ? x : y);
      int minB = b.where((f) => f > 0).fold<int>(999, (x, y) => x < y ? x : y);
      return minA.compareTo(minB);
    });
    return filtered;
  }

  int get _variationCount => _currentVariations.length;

  List<String> get _recommendedChords {
    final all = chordVariations.keys.toList();
    final others = all.where((c) => c != _selectedChord).toList();
    if (others.length <= 6) return others;
    return others
        .take(8)
        .toList(); // show up to 8 recommendations, minimum 6 if available
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            // Title (h1)
            const Text(
              'Chord Finder',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 28, // Smaller size for compact look
                fontWeight: FontWeight.bold, // 700
                color: Color(0xFF171717), // #171717
                height: 1.1,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Subtitle (p)
            const Text(
              'Discover chord variations across the fretboard',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14, // Slightly smaller for compact look
                fontWeight: FontWeight.w400, // Normal
                color: Color(0xFF525252), // #525252
                height: 1.2,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 68),
            // Chord name (h2)
            if (_variationCount > 0)
              Center(
                child: Text(
                  _selectedChord,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 24, // 1.875rem
                    fontWeight: FontWeight.w600, // 600
                    color: Color(0xFF171717), // #171717
                    height: 1.1,
                    letterSpacing: 0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            // ...existing code for diagram, etc...
            const SizedBox(height: 18),

            Expanded(
              flex: 0,
              child: _variationCount > 0
                  ? Center(
                      child: Card(
                        color: Colors.white,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        shadowColor: Colors.black.withOpacity(0.10),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 36, right: 36, top: 0, bottom: 12),
                          child: SizedBox(
                            width: 380, // Increased width
                            height: 360, // Slightly increased height
                            child: Center(
                              child: SizedBox(
                                width: 220,
                                height:
                                    260, // Increased height to prevent overflow
                                child: PageView.builder(
                                  controller: _pageController,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _variationCount,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _variationIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return FretboardDiagram(
                                      positions: _currentVariations[index],
                                      showFretLabelRight: false,
                                      showFretLabelAbove: false,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text('No chord data available',
                          textAlign: TextAlign.center),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_variationCount > 0)
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: List.generate(_variationCount, (i) {
                      final activeVariation = i == _variationIndex;
                      return SizedBox(
                        height: 36,
                        width: 36,
                        child: TextButton(
                          onPressed: () {
                            if (_pageController.hasClients) {
                              _pageController.animateToPage(
                                i,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                            setState(() {
                              _variationIndex = i;
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: activeVariation
                                ? Colors.black
                                : Colors.transparent,
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text('${i + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: activeVariation
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: activeVariation
                                    ? Colors.white
                                    : Colors.grey.shade500,
                              )),
                        ),
                      );
                    }),
                  ),
                const SizedBox(height: 18),
                if (_variationCount > 0)
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recommendedChords.length,
                      itemBuilder: (context, index) {
                        final chord = _recommendedChords[index];
                        final selected = chord == _selectedChord;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(chord,
                                style: TextStyle(
                                  fontSize: selected ? 16 : 14,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: selected ? Colors.blue : Colors.black,
                                )),
                            selected: selected,
                            selectedColor: Colors.transparent,
                            backgroundColor: Colors.transparent,
                            side: BorderSide(
                                color: selected ? Colors.blue : Colors.grey,
                                width: selected ? 2.0 : 1.0),
                            onSelected: (_) {
                              setState(() {
                                _selectedChord = chord;
                                _variationIndex = 0;
                              });
                              if (_pageController.hasClients) {
                                _pageController.jumpToPage(0);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
