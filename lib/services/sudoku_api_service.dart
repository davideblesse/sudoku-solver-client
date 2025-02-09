import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SudokuApiService {
  final String _baseUrl = "https://sudoku-solver-from-image.onrender.com";

  Future<List<int>?> sendImageForProcessing(String imagePath) async {
    try {
      final url = Uri.parse('$_baseUrl/process-image-test');

      // Create a multipart request to send the image file
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath(
          'file', 
          imagePath,
          contentType: MediaType('image', 'jpeg'), // Ensure correct content type
        ));

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
    return null;
  }
}
