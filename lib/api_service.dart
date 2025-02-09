import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = "https://sudoku-solver-from-image.onrender.com";

  Future<List<int>?> sendImageToServer(String imagePath) async {
    try {
      final url = Uri.parse('$_baseUrl/process-image');
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('file', imagePath));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);

        if (decodedData.containsKey('solution')) {
          return decodedData['solution']
              .split(',')
              .map((e) => int.parse(e.trim()))
              .toList();
        }
      }
    } catch (e) {
      print("Error sending image: $e");
    }
    return null;
  }
}
