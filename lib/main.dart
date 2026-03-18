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
        scaffoldBackgroundColor: Color(0xFFF8F8F8), // Offwhite gray
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
  // Helper for new chord selection controls
  static const List<String> _rootNotes = [
    'C',
    'C# / Db',
    'D',
    'D# / Eb',
    'E',
    'F',
    'F# / Gb',
    'G',
    'G# / Ab',
    'A',
    'A# / Bb',
    'B',
  ];
  static const List<String> _types = [
    'Major',
    'Minor',
    'Sus2',
    'Sus4',
    '7',
    'Maj7',
    'm7',
    'Add9',
  ];
  String _selectedRoot = 'C';
  String _selectedType = 'Major';

  int _variationIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  List<List<int>> get _currentVariations {
    // Use getChordShapes to get the transposed chord shapes for the selected root and type
    String normalizedRoot = _selectedRoot.split(' ')[0];
    return getChordShapes(normalizedRoot, _selectedType);
  }

  int get _variationCount => _currentVariations.length;

  String get _currentChordName => '$_selectedRoot $_selectedType';
  String get _selectedChord => _currentChordName;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
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

              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _variationCount > 0
                    ? Center(
                        child: Card(
                          color: Colors.white,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          shadowColor: Colors.black.withOpacity(0.25),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 24, right: 24, top: 24, bottom: 12),
                            child: SizedBox(
                              width: 348,
                              height: 300, // Keep height proportional
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
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
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
                const SizedBox(height: 10),
                // New chord selection controls (Root Note and Type only)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      // Root Note selector
                      DropdownButton<String>(
                        value: _selectedRoot,
                        items: _rootNotes
                            .map((note) => DropdownMenuItem(
                                  value: note,
                                  child: Text(note),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedRoot = val;
                              _variationIndex = 0;
                            });
                          }
                        },
                      ),
                      // Type selector
                      DropdownButton<String>(
                        value: _selectedType,
                        items: _types
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedType = val;
                              _variationIndex = 0;
                            });
                          }
                        },
                      ),
                    ],
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
