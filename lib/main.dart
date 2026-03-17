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
      appBar: AppBar(
        title: const Text('Chord Finder'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_variationCount > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    _selectedChord,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              Expanded(
                child: _variationCount > 0
                    ? PageView.builder(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _variationCount,
                        onPageChanged: (index) {
                          setState(() {
                            _variationIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Center(
                            child: SizedBox(
                              width: 220,
                              height: 260,
                              child: FretboardDiagram(
                                positions: _currentVariations[index],
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text('No chord data available',
                            textAlign: TextAlign.center),
                      ),
              ),
            ],
          ),
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
                                ? Colors.grey.shade400
                                : Colors.grey.shade200,
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text('${i + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
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
