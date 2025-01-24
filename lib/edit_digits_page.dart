import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sudoku_solver_android/solution_screen.dart';
import 'package:http/http.dart' as http;

class EditDigitsPage extends StatefulWidget {
  final List<dynamic> digits;

  const EditDigitsPage({super.key, required this.digits});

  @override
  _EditDigitsPageState createState() => _EditDigitsPageState();
}

class _EditDigitsPageState extends State<EditDigitsPage> {
  late List<int> updatedDigits;

  @override
  void initState() {
    super.initState();
    updatedDigits = List.from(widget.digits); // Initialize with server data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recognized Digits'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
                childAspectRatio: 1,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                return TextFormField(
                  initialValue: updatedDigits[index].toString(),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: const InputDecoration(
                    counterText: '', // Remove counter
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // Update the digit if valid
                    if (RegExp(r'^[1-9]$').hasMatch(value)) {
                      updatedDigits[index] = int.parse(value);
                    }
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Send the updated digits to the server
              sendDigitsToServer(updatedDigits, context);
            },
            child: const Text('Submit Corrections'),
          ),
        ],
      ),
    );
  }

  Future<void> sendDigitsToServer(List<int> correctedDigits,
      BuildContext context) async {
    try {
      final url = Uri.parse(
          'https://sudoku-solver-app-v0gc.onrender.com/solve-sudoku'); // Endpoint for solving Sudoku
      // Convert digits list to a comma-separated string
      final digitsString = correctedDigits.join(',');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': digitsString}), // Send as a string
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (decodedData.containsKey('received_message')) {
          final solution = decodedData['received_message']
              .split(',')
              .map((e) => int.parse(e.trim()))
              .toList();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SolutionScreen(solution: solution),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to retrieve solution.')),
          );
        }
      } else {
        print("Failed to solve sudoku: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("Error solving sudoku: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send digits.')),
      );
    }
  }
}