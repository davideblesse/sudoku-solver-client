import 'package:flutter/material.dart';

class SolutionScreen extends StatelessWidget {
  final List<dynamic> solution;

  const SolutionScreen({Key? key, required this.solution}) : super(key: key);

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Sudoku Solution'),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // AppBar background color from theme
    ),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Background color from theme
    body: Column(
      children: [
        // Centered grid and text container
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add the new text just above the grid
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Try Again With a Harder One',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary, // Text color from theme (Yellow)
                    fontSize: 18, // Font size
                    fontWeight: FontWeight.bold, // Font weight
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Sudoku solution grid
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary, // Border color from theme (Yellow)
                      width: 2,
                    ),
                  ),
                  child: GridView.builder(
                    itemCount: 81,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 9, // 9 columns for the Sudoku grid
                      crossAxisSpacing: 1, // Spacing between columns
                      mainAxisSpacing: 1, // Spacing between rows
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor, // Cell background color from theme (Beige)
                          border: Border.all(
                            color: Colors.black12, // Thin border around cells
                          ),
                        ),
                        child: Text(
                          solution[index].toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Text color for digits (black)
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}