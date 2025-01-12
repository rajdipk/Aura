import 'api_service.dart';
import '../config/api_keys.dart';

class SearchService {
  final ApiService _apiService = ApiService();
  final String baseUrl = 'https://www.googleapis.com/customsearch/v1';

  Future<Map<String, dynamic>> search(String query) async {
    final url = '$baseUrl?q=$query&key=${ApiKeys.googleCustomSearch}&cx=${ApiKeys.googleSearchEngineId}';
    return await _apiService.getRequest(url);
  }
}
