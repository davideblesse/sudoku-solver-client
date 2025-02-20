import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'sudoku_solution_screen.dart';

class EditRecognizedDigitsScreen extends StatefulWidget {
  final List<int> digits;

  const EditRecognizedDigitsScreen({Key? key, required this.digits})
      : super(key: key);

  @override
  _EditRecognizedDigitsScreenState createState() => _EditRecognizedDigitsScreenState();
}

class _EditRecognizedDigitsScreenState extends State<EditRecognizedDigitsScreen>
    with SingleTickerProviderStateMixin {
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
      CurvedAnimation(parent: _backgroundAnimationController, curve: Curves.easeInOut),
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

    final Uri url = Uri.parse('https://sudoku-solver-from-image.onrender.com/solve-sudoku');
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
      _showErrorSnackBar('Failed to send digits.');
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
            
            // Sudoku Grid
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.7),
                        width: 2, // Same as SudokuSolutionScreen
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 9,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 1, // Matches solution screen
                            ),
                          ),
                          child: TextFormField(
                            initialValue: updatedDigits[index] == 0 ? '' : updatedDigits[index].toString(),
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
                                if (index >= 0 && index < 81) {
                                  if (value.isEmpty || !RegExp(r'^[1-9]$').hasMatch(value)) {
                                    updatedDigits[index] = 0;
                                  } else {
                                    updatedDigits[index] = int.parse(value);
                                  }
                                }
                              });
                            },
                          ),
                        );
                      },
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
