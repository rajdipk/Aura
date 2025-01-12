import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiService {
  Future<Map<String, dynamic>> getRequest(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}

// Adding the missing provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
