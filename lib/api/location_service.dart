import 'package:geolocator/geolocator.dart';

class LocationService {
  // Método para obtener la ubicación actual del dispositivo
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si los servicios de ubicación están habilitados.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Si los servicios de ubicación están deshabilitados, retorna un error.
      return Future.error('Los servicios de ubicación están deshabilitados.');
    }

    // Verifica el permiso de ubicación.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Si el permiso de ubicación es denegado, solicita el permiso.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Si el permiso sigue siendo denegado después de la solicitud, retorna un error.
        return Future.error('Los permisos de ubicación están denegados');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Si el permiso de ubicación está denegado permanentemente, retorna un error.
      return Future.error('Los permisos de ubicación están permanentemente denegados.');
    }

    // Si los servicios y permisos están en orden, obtiene la ubicación actual del dispositivo.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high); // Usa alta precisión para obtener la ubicación.
  }
}

