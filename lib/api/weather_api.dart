import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherApi {
  final String apiKey = '6ae4f256d4feb34268aa5f83c510b851'; // Clave API para autenticar las solicitudes a OpenWeatherMap
  final String baseUrl = 'https://api.openweathermap.org/data/2.5'; // URL base para las solicitudes a la API de OpenWeatherMap

  // Método para obtener el clima basado en las coordenadas geográficas
  Future<Map<String, dynamic>> fetchWeatherByCoordinates(double lat, double lon) async {
    // Construye la URL de solicitud con las coordenadas y la clave API
    final response = await http.get(Uri.parse('$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric'));

    // Verifica el estado de la respuesta
    if (response.statusCode == 200) {
      // Si la respuesta es exitosa (código de estado 200), decodifica el cuerpo de la respuesta en formato JSON y lo retorna
      return jsonDecode(response.body);
    } else {
      // Si la respuesta no es exitosa, lanza una excepción
      throw Exception('Failed to load weather data');
    }
  }
}


