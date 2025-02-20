import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Toggle between local Docker server and online server
const bool useLocalServer = true;

/// Local Docker server address (assuming it's running on port 8000)
/// If you're on an Android emulator, replace '127.0.0.1' with '10.0.2.2'
const String localBaseUrl = "http://192.168.1.248:8000";

/// Existing online server address
const String remoteBaseUrl = "https://sudoku-solver-from-image.onrender.com";

/// Helper function to generate the full URL
String getBaseUrl() {
  return useLocalServer ? localBaseUrl : remoteBaseUrl;
}

class SudokuApiService {
  // This method uploads the image and returns a processed Sudoku solution if successful
  Future<List<int>?> sendImageForProcessing(String imagePath) async {
    try {
      final url = Uri.parse('${getBaseUrl()}/process-image');

      // Create a multipart request to send the image file
      final request = http.MultipartRequest('POST', url)
        ..files.add(
          await http.MultipartFile.fromPath(
            'file', 
            imagePath,
            contentType: MediaType('image', 'jpeg'), // Ensure correct content type
          ),
        );

      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);

        if (decodedData.containsKey('solution')) {
          final solution = decodedData['solution'];

          // ✅ Handle both string and list formats
          if (solution is String) {
            return solution.split('').map((e) => int.parse(e)).toList();
          } else if (solution is List) {
            return List<int>.from(solution);
          }
        }
      } else {
        print("Error: Server returned status code ${response.statusCode}");
      }
    } catch (e) {
      print("Error in sendImageForProcessing: $e");
    }

    return null; // Return null if there's an error or no solution
  }
}
