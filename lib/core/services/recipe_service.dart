import 'api_service.dart';
import '../config/api_keys.dart';

class RecipeService {
  final ApiService _apiService = ApiService();
  final String baseUrl = 'https://api.spoonacular.com/recipes';

  Future<Map<String, dynamic>> getRecipe(String query) async {
    final url =
        '$baseUrl/complexSearch?query=$query&apiKey=${ApiKeys.spoonacular}';
    return await _apiService.getRequest(url);
  }
}
