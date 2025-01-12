import 'api_service.dart';
import '../config/api_keys.dart';

class WeatherService {
  final ApiService _apiService = ApiService();
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Map<String, dynamic>> getWeather(String city) async {
    final url = '$baseUrl/weather?q=$city&appid=${ApiKeys.openWeatherMap}';
    return await _apiService.getRequest(url);
  }
}
