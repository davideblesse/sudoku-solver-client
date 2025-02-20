import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'main_menu_screen.dart';

class SudokuSolutionScreen extends StatefulWidget {
  final List<int> solution;

  const SudokuSolutionScreen({Key? key, required this.solution}) : super(key: key);

  @override
  _SudokuSolutionScreenState createState() => _SudokuSolutionScreenState();
}

class _SudokuSolutionScreenState extends State<SudokuSolutionScreen> {
  // Control the visibility of each of the 81 cells for the animation
  final List<bool> _visibleCells = List.filled(81, false);

  @override
  void initState() {
    super.initState();
    _animateCells();
  }

  // Reveal each cell one by one
  void _animateCells() {
    for (int i = 0; i < _visibleCells.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted) {
          setState(() {
            _visibleCells[i] = true;
          });
        }
      });
    }
  }

  Future<void> _restartApp(BuildContext context) async {
    final cameras = await availableCameras();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            MainMenuScreen(camera: cameras.isNotEmpty ? cameras.first : null),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a similar gradient background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade700,
              Colors.deepPurpleAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'Sudoku Solution',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Try Again With a Harder One',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Sudoku grid using nested subgrids for a clear 3x3 separation
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.7),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: List.generate(3, (subgridRow) {
                        return Expanded(
                          child: Row(
                            children: List.generate(3, (subgridCol) {
                              final int startRow = subgridRow * 3;
                              final int startCol = subgridCol * 3;
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    // Subtle border to separate each subgrid
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.7),
                                      width: 2,
                                    ),
                                  ),
                                  child: GridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 1,
                                      mainAxisSpacing: 1,
                                    ),
                                    itemCount: 9,
                                    itemBuilder: (context, cellIndex) {
                                      final int subRow = cellIndex ~/ 3;
                                      final int subCol = cellIndex % 3;
                                      final int fullRow = startRow + subRow;
                                      final int fullCol = startCol + subCol;
                                      final int fullIndex = fullRow * 9 + fullCol;
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.5),
                                            width: 1,
                                          ),
                                        ),
                                        child: AnimatedOpacity(
                                          opacity: _visibleCells[fullIndex] ? 1.0 : 0.0,
                                          duration: const Duration(milliseconds: 300),
                                          child: Center(
                                            child: Text(
                                              widget.solution[fullIndex].toString(),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // "Next Puzzle" Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () => _restartApp(context),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Next Puzzle',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
