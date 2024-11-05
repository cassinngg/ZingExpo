// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';

// class LocationService {
//   Future<void> checkAndRequestLocation() async {
//     // Check if location services are enabled
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Location services are not enabled, show a message to the user
//       print('Location services are disabled. Please enable them in settings.');
//       // Optionally, you can show a dialog to the user
//       return;
//     }

//     // Request location permission
//     var status = await Permission.location.status;
//     if (!status.isGranted) {
//       // Request permission
//       await Permission.location.request();
//     }

//     // Check if permission is granted
//     if (await Permission.location.isGranted) {
//       // Permission granted, you can now access the location
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
import 'package:location/location.dart';

class LocationService {
  Location location = Location();

  // Change the return type to PermissionStatus
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
