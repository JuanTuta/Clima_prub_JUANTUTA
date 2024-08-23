import 'package:flutter/material.dart';

class ForecastScreen extends StatefulWidget {
  final Map<String, dynamic> forecast; // Datos del pronóstico del clima

  ForecastScreen({required this.forecast}); // Constructor que recibe los datos del pronóstico

  @override
  _ForecastScreenState createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  late PageController _pageController; // Controlador para la paginación
  int _currentPage = 0; // Página actual en el PageView

  @override
  void initState() {
    super.initState();
    _pageController = PageController(); // Inicializa el controlador de la página
  }

  @override
  void dispose() {
    _pageController.dispose(); // Limpia el controlador de la página
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> forecastPages = []; // Lista de páginas para mostrar los datos del pronóstico

    // Calcula el número de días de pronóstico (3 días) basándose en los datos recibidos
    int forecastLength = (widget.forecast['list'].length / 8).floor();

    // Genera las páginas de pronóstico
    for (int i = 0; i < forecastLength && i < 3; i++) {
      var dayForecast = widget.forecast['list'][i * 8]; // Obtiene el pronóstico para el día actual
      var date = DateTime.parse(dayForecast['dt_txt']); // Obtiene la fecha del pronóstico
      var tempMin = dayForecast['main']['temp_min']; // Temperatura mínima
      var tempMax = dayForecast['main']['temp_max']; // Temperatura máxima
      var description = dayForecast['weather'][0]['description']; // Descripción del clima
      var iconUrl = 'https://openweathermap.org/img/wn/${dayForecast['weather'][0]['icon']}@2x.png'; // URL del ícono del clima

      forecastPages.add(
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(iconUrl), // Muestra el ícono del clima
              Text(
                "${date.day}/${date.month}/${date.year}",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(description),
              Text("Min: $tempMin°C, Max: $tempMax°C"),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
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
          // Página de pronósticos desplazables
          PageView(
            controller: _pageController, // Asocia el controlador con el PageView
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index; // Actualiza la página actual cuando cambie
              });
            },
            children: forecastPages, // Lista de páginas de pronóstico
          ),
          // Botón de retroceso
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 30, color: Colors.white),
              onPressed: () {
                Navigator.pop(context); // Regresa a la pantalla anterior
              },
            ),
          ),
          // Indicador de navegación
          Positioned(
            bottom: 30,
            left: MediaQuery.of(context).size.width * 0.5 - 60, // Centra el indicador horizontalmente
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentPage < forecastLength - 1) ...[
                  Text(
                    "Siguiente Día",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ] else ...[
                  Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Día Anterior",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}









