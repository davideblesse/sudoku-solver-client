import 'package:flutter/material.dart';

class SolutionScreen extends StatelessWidget {
  final List<dynamic> solution;

  const SolutionScreen({Key? key, required this.solution}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku Solution'),
        backgroundColor: Colors.blueGrey,
      ),
      backgroundColor: Colors.indigoAccent,
      body: Column(
        children: [
          // Centered grid and text container
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add the new text just above the grid
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Try Again With a Harder One',
                    style: TextStyle(
                      color: Colors.yellowAccent, // Text color
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
                      border: Border.all(color: Colors.yellowAccent, width: 2), // Yellow border
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
                            color: Colors.white, // Background color for the cells
                            border: Border.all(color: Colors.black12), // Thin border around cells
                          ),
                          child: Text(
                            solution[index].toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Text color
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
