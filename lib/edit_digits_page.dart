import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sudoku_solver_client_2/solution_screen.dart';
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
    // Inizializza la lista con i dati ricevuti dal server
    updatedDigits = List<int>.from(widget.digits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recognized Digits'),
        backgroundColor: Theme.of(context).cardColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Grid centrato per visualizzare i 81 numeri
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 9, // 9 colonne nella griglia
                  childAspectRatio: 1,
                ),
                itemCount: 81,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.65),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 1,
                      ),
                    ),
                    child: TextFormField(
                      initialValue: updatedDigits[index].toString(),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        if (RegExp(r'^[0-9]$').hasMatch(value)) {
                          updatedDigits[index] = int.parse(value);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Invia i dati aggiornati al server
                sendDigitsToServer(updatedDigits, context);
              },
              child: const Text('Submit Corrections'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendDigitsToServer(
      List<int> correctedDigits, BuildContext context) async {
    try {
      final url = Uri.parse(
          'https://sudoku-solver-from-image.onrender.com/solve-sudoku'); // Endpoint per risolvere il Sudoku
      // Converti la lista di cifre in una stringa di 81 caratteri (senza separatori)
      final digitsString = correctedDigits.join('');

      // Controllo opzionale: assicurarsi che la stringa abbia esattamente 81 caratteri
      if (digitsString.length != 81) {
        print(digitsString.length);
        print(digitsString);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Il puzzle deve contenere esattamente 81 cifre.')),
        );
        return;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': digitsString}),
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData.containsKey('solution')) {
          // La soluzione è una stringa di 81 cifre: dividiamola in singoli caratteri e convertiamoli in int
          final solution = decodedData['solution']
              .toString()
              .split('')
              .map((e) => int.parse(e))
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