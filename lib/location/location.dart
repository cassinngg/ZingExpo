// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';

// class LocationService {
//   Future<void> checkAndRequestLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       print('Location services are disabled. Please enable them in settings.');
//       return;
//     }

//     var status = await Permission.location.status;
//     if (!status.isGranted) {
//       await Permission.location.request();
//     }

//     if (await Permission.location.isGranted) {
//       _getCurrentLocation();
//     } else {
//       print('Location permission denied');
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       print('Current position: $position');
//     } catch (e) {
//       print('Error getting current position: $e');
//     }
//   }
// }
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

class LocationService {
  Location location = Location();
// Future<double> getCurrentElevation() async {
//   try {
//     Position position = await Geolocator.getCurrentPosition();
//     return await Geolocator.getAltitude(location: position);
//   } catch (e) {
//     print('Error getting elevation: $e');
//     return null;
//   }
// }
  Future<PermissionStatus> requestPermission() async {
    return await location.requestPermission();
  }

  Future<LocationData> getCurrentLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception('Location permission denied.');
      }
    }

    return await location.getLocation();
  }
}
