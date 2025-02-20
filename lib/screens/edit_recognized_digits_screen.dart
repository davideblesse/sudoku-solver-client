import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'sudoku_solution_screen.dart';

// Change this to true when testing locally on macOS/iOS Simulator (http://127.0.0.1:8000)
// or on Android emulator using http://10.0.2.2:8000.
const bool useLocalServer = false;

// Local Docker server address (assuming you exposed port 8000 in your container).
// If you're using the Android emulator, replace '127.0.0.1' with '10.0.2.2'.
const String localApi = "http://192.168.1.248:8000";

// Existing online server URL:
const String remoteApi = 'https://sudoku-solver-from-image.onrender.com/solve-sudoku';

class EditRecognizedDigitsScreen extends StatefulWidget {
  final List<int> digits;

  const EditRecognizedDigitsScreen({Key? key, required this.digits})
      : super(key: key);

  @override
  _EditRecognizedDigitsScreenState createState() =>
      _EditRecognizedDigitsScreenState();
}

class _EditRecognizedDigitsScreenState
    extends State<EditRecognizedDigitsScreen> with SingleTickerProviderStateMixin {
  late List<int> updatedDigits;
  bool _isProcessing = false;
  late final AnimationController _backgroundAnimationController;
  late final Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();

    // Background gradient animation
    _backgroundAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _backgroundAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.deepPurpleAccent,
    ).animate(
      CurvedAnimation(
        parent: _backgroundAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _backgroundAnimationController.forward();

    // Ensure exactly 81 digits
    updatedDigits = List<int>.filled(81, 0);
    for (int i = 0; i < widget.digits.length && i < 81; i++) {
      updatedDigits[i] = widget.digits[i];
    }
  }

  Future<void> _submitCorrections() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    // Decide which server URL to use
    final Uri url = Uri.parse(useLocalServer ? localApi : remoteApi);

    // Convert digits to string
    final String digitsString = updatedDigits.map((e) => e.toString()).join('');

    if (updatedDigits.length != 81 || digitsString.length != 81) {
      _showErrorSnackBar('Error: Sudoku grid must contain exactly 81 digits.');
      setState(() => _isProcessing = false);
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"message": digitsString}),
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData.containsKey('solution')) {
          final solution = decodedData['solution']
              .toString()
              .split('')
              .map((e) => int.parse(e))
              .toList();

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SudokuSolutionScreen(solution: solution),
            ),
          );
        } else {
          _showErrorSnackBar('Failed to retrieve solution.');
        }
      } else {
        _showErrorSnackBar('Error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to send digits: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _backgroundAnimation.value ?? Colors.black,
                  Colors.deepPurple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          );
        },
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'Edit Recognized Digits',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Make any corrections before solving!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Sudoku Grid using nested subgrids
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.7), width: 2),
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
                                    // Subtle border to distinguish each subgrid
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
                                        child: TextFormField(
                                          initialValue: updatedDigits[fullIndex] == 0
                                              ? ''
                                              : updatedDigits[fullIndex].toString(),
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          maxLength: 1,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          decoration: const InputDecoration(
                                            counterText: '',
                                            border: InputBorder.none,
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              if (value.isEmpty ||
                                                  !RegExp(r'^[1-9]$').hasMatch(value)) {
                                                updatedDigits[fullIndex] = 0;
                                              } else {
                                                updatedDigits[fullIndex] = int.parse(value);
                                              }
                                            });
                                          },
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

            // Submit Button
            _isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: _submitCorrections,
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          'Confirm & Solve',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.3),
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
