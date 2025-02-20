import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'main_menu_screen.dart';

class SudokuSolutionScreen extends StatefulWidget {
  final List<int> solution;

  const SudokuSolutionScreen({Key? key, required this.solution})
      : super(key: key);

  @override
  _SudokuSolutionScreenState createState() => _SudokuSolutionScreenState();
}

class _SudokuSolutionScreenState extends State<SudokuSolutionScreen> {
  // List to control the visibility of each number (81 total)
  final List<bool> _visibleCells = List.filled(81, false);

  @override
  void initState() {
    super.initState();
    _animateCells();
  }

  // Animate numbers one by one
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
    // Reinitialize available cameras
    final cameras = await availableCameras();

    // Navigate to MainMenuScreen and remove all previous screens
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Title
            const Text(
              'Sudoku Solution',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // Updated Subtitle
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

            // Sudoku Grid
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.7),
                        width: 2, // Reduced border thickness
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
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: 81,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 9,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 1, // Thinner inner border
                            ),
                          ),
                          child: AnimatedOpacity(
                            opacity: _visibleCells[index] ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              widget.solution[index].toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
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
