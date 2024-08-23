import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'forecast_screen.dart'; 

void main() {
  runApp(MyApp()); // Inicializa la aplicación
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          secondary: Colors.orange,
        ),
        textTheme: TextTheme(
          headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: WeatherScreen(), // Define la pantalla principal
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> with SingleTickerProviderStateMixin {
  Future<Map<String, dynamic>>? _weatherData; // Variable para almacenar los datos del clima
  late AnimationController _animationController; // Controlador de animaciones

  @override
  void initState() {
    super.initState();
    _weatherData = checkConnectivityAndGetLocation(); // Inicializa la carga de datos del clima
    
    // Configura el controlador de animaciones
    _animationController = AnimationController(
      duration: const Duration(seconds: 10), // Duración de la animación
      vsync: this, // El objeto que provee la sincronización con la animación
    )..repeat(); // Repite la animación indefinidamente
  }

  @override
  void dispose() {
    _animationController.dispose(); // Limpia el controlador de animaciones
    super.dispose();
  }

  // Verifica la conectividad y obtiene la ubicación
  Future<Map<String, dynamic>> checkConnectivityAndGetLocation() async {
    var connectivityResult = await (Connectivity().checkConnectivity()); // Verifica la conectividad
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception("No hay conexión a internet"); // Lanza una excepción si no hay conexión
    }

    return await checkPermissionsAndGetLocation(); // Llama al método para verificar permisos y obtener ubicación
  }

  // Verifica permisos de ubicación y obtiene la ubicación
  Future<Map<String, dynamic>> checkPermissionsAndGetLocation() async {
    LocationPermission permission = await Geolocator.checkPermission(); // Verifica permisos de ubicación
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(); // Solicita permisos si están denegados
      if (permission == LocationPermission.denied) {
        throw Exception("Permiso de ubicación denegado"); // Lanza una excepción si el permiso es denegado
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Permiso de ubicación denegado permanentemente"); // Lanza una excepción si el permiso es denegado permanentemente
    }

    return await getLocation(); // Obtiene la ubicación si los permisos están otorgados
  }

  // Obtiene la ubicación actual del dispositivo
  Future<Map<String, dynamic>> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high); // Obtiene la ubicación con alta precisión
    return await getWeather(position.latitude, position.longitude); // Obtiene el clima para la ubicación actual
  }

  // Obtiene los datos del clima desde la API
  Future<Map<String, dynamic>> getWeather(double latitude, double longitude) async {
    String apiKey = '6ae4f256d4feb34268aa5f83c510b851';
    String currentWeatherUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';
    String forecastUrl =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric&cnt=24';

    try {
      final weatherResponse = await http.get(Uri.parse(currentWeatherUrl)); // Obtiene los datos actuales del clima
      final forecastResponse = await http.get(Uri.parse(forecastUrl)); // Obtiene los datos del pronóstico

      if (weatherResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
        var weatherData = jsonDecode(weatherResponse.body); // Decodifica la respuesta del clima
        var forecastData = jsonDecode(forecastResponse.body); // Decodifica la respuesta del pronóstico

        return {
          'weather': weatherData,
          'forecast': forecastData,
          'weatherIconUrl': 'https://openweathermap.org/img/wn/${weatherData['weather'][0]['icon']}@2x.png',
        };
      } else {
        throw Exception("Error en la respuesta de la API"); // Lanza una excepción si la respuesta de la API no es exitosa
      }
    } catch (e) {
      throw Exception("Error al obtener los datos: $e"); // Lanza una excepción si ocurre un error al obtener los datos
    }
  }

  // Actualiza los datos del clima cuando se presiona el botón de refrescar
  void _refreshWeatherData() {
    setState(() {
      _weatherData = checkConnectivityAndGetLocation(); // Vuelve a cargar los datos del clima
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _weatherData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Muestra un indicador de carga mientras se obtienen los datos
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", textAlign: TextAlign.center, style: TextStyle(color: Colors.white))); // Muestra un mensaje de error si ocurre un problema
          } else if (snapshot.hasData) {
            var weather = snapshot.data!['weather']; // Obtiene los datos del clima
            var forecast = snapshot.data!['forecast']; // Obtiene los datos del pronóstico
            var weatherIconUrl = snapshot.data!['weatherIconUrl']; // Obtiene la URL del ícono del clima

            return Stack(
              alignment: Alignment.center,
              children: [
                // Fondo degradado
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF28A8F1), Color(0xFF3AA2E9), Color(0xFF106EC5)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                // Círculo blanco giratorio
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animationController.value * 2.0 * 3.14159,
                      child: Container(
                        width: 320, // Tamaño de la circunferencia blanca
                        height: 320, // Tamaño de la circunferencia blanca
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 8, // Ancho del borde (circunferencia blanca)
                            color: Colors.white,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
                // Círculo gris encima del blanco, con efecto de tratar de completarse
                CustomPaint(
                  size: Size(340, 340), // Tamaño del círculo gris
                  painter: GrayCirclePainter(_animationController), // Dibuja el círculo gris con el efecto de progreso
                ),
                // Contenido dentro del círculo
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(weatherIconUrl), // Muestra el ícono del clima
                        Text(
                          "Clima: ${weather['weather'][0]['description']}\n"
                          "Temperatura: ${weather['main']['temp']}°C",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForecastScreen(forecast: forecast)), // Navega a la pantalla de pronóstico
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: Text('Ver Pronóstico'),
                        ),
                      ],
                    ),
                  ),
                ),
                // Botón de refrescar en la esquina superior derecha
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: Icon(Icons.refresh, size: 30, color: Colors.white),
                    onPressed: _refreshWeatherData, // Refresca los datos del clima al presionar
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text("Presiona el botón para obtener el clima", textAlign: TextAlign.center, style: TextStyle(color: Colors.white))); // Mensaje cuando no hay datos
          }
        },
      ),
    );
  }
}

// Clase que pinta el círculo gris en el fondo
class GrayCirclePainter extends CustomPainter {
  final AnimationController animationController; // Controlador de animaciones

  GrayCirclePainter(this.animationController) : super(repaint: animationController);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Color(0xFFD9D9D9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = (size.width - paint.strokeWidth) / 2;

    final double progress = animationController.value;

    final Rect rect = Rect.fromCircle(center: Offset(centerX, centerY), radius: radius);
    final double startAngle = -3.14159 / 2;
    final double sweepAngle = 2 * 3.14159 * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint); // Dibuja el arco gris que representa el progreso
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Indica que el pintor debe repintar cada vez que el controlador de animaciones cambie
  }
}

























