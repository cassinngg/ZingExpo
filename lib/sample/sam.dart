import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zingexpo/database/database_helper.dart';

class ImageListScreen extends StatelessWidget {
  final DatabaseHelper dbHelper = DatabaseHelper();

  ImageListScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchImages() async {
    return await dbHelper.getAllImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saved Images')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchImages(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final images = snapshot.data!;
          return ListView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];
              return ListTile(
                leading: Image.file(File(image['image_path'])),
                title: Text(image['image_name']),
                subtitle: Text(
                  'Lat: ${image['latitude']}, Long: ${image['longitude']}, Elev: ${image['elevation']}\nDate: ${image['capture_date']}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:zingexpo/database/database_helper.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:permission_handler/permission_handler.dart'
//     as permission_handler;

// class ImageListScreen extends StatelessWidget {
//   final DatabaseHelper dbHelper = DatabaseHelper();

//   Future<List<Map<String, dynamic>>> _fetchImages() async {
//     return await dbHelper.getAllImages();
//   }

//   Future<bool> requestStoragePermission() async {
//     // Check if the storage permission is already granted
//     permission_handler.PermissionStatus status =
//         await permission_handler.Permission.storage.status;

//     if (status.isGranted) {
//       return true; // If granted, return true
//     }

//     // If permission is denied, request permission
//     if (status.isDenied) {
//       status = await permission_handler.Permission.storage.request();
//       if (status.isGranted) {
//         return true;
//       }
//     }

//     // If the permission is permanently denied, return error
//     if (status.isPermanentlyDenied) {
//       return Future.error(
//           'Storage permission is permanently denied. Please enable it in app settings.');
//     }

//     return false; // Return false if permission is not granted or denied
//   }

  // Future<void> _downloadImage(
  //     BuildContext context, String imagePath, String imageName) async {
  //   try {
  //     // Request storage permissions
  //     var status = await Permission.storage.request();
  //     if (status.isGranted) {
  //       // Define the path for saving the image in the Downloads folder
  //       final downloadDir = Directory('/storage/emulated/0/Download');

  //       // Ensure that the Downloads directory exists
  //       if (!downloadDir.existsSync()) {
  //         await downloadDir.create(recursive: true);
  //       }

  //       // Generate a unique file name in the Downloads folder to avoid overwriting
  //       final downloadPath =
  //           '${downloadDir.path}/$imageName-${DateTime.now().millisecondsSinceEpoch}.png';

  //       // Copy the image file to the Downloads folder
  //       final imageFile = File(imagePath);
  //       if (await imageFile.exists()) {
  //         await imageFile.copy(downloadPath);
  //         // Notify the user of success
  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //           content: Text('Image downloaded to $downloadPath'),
  //         ));
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //           content: Text('Image file not found!'),
  //         ));
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text('Storage permission denied! Unable to download image.'),
  //       ));
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Error downloading image: $e'),
  //     ));
  //   }
  // }
//   Future<void> _downloadImage(
//       BuildContext context, String imagePath, String imageName) async {
//     bool permissionGranted = await requestStoragePermission();
//     if (!permissionGranted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Storage permission not granted")),
//       );
//       return;
//     }

//     try {
//       // Access the Downloads folder or create it if it doesn't exist
//       final downloadDir = Directory('/storage/emulated/0/Download');
//       if (!downloadDir.existsSync()) {
//         await downloadDir.create(recursive: true);
//       }

//       // Define download path and copy the image
//       final downloadPath =
//           '${downloadDir.path}/$imageName-${DateTime.now().millisecondsSinceEpoch}.png';
//       final imageFile = File(imagePath);
//       if (await imageFile.exists()) {
//         await imageFile.copy(downloadPath);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Image downloaded to $downloadPath')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Image file not found!')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error downloading image: $e')),
//       );
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Saved Images')),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _fetchImages(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }
//           final images = snapshot.data!;
//           return ListView.builder(
//             itemCount: images.length,
//             itemBuilder: (context, index) {
//               final image = images[index];
//               return ListTile(
//                 leading: Image.file(File(image['image_path'])),
//                 title: Text(image['image_name']),
//                 subtitle: Text(
//                   'Lat: ${image['latitude']}, Long: ${image['longitude']}, Elev: ${image['elevation']}\nDate: ${image['capture_date']}',
//                 ),
//                 trailing: IconButton(
//                   icon: Icon(Icons.download),
//                   onPressed: () async {
//                     await _downloadImage(
//                         context, image['image_path'], image['image_name']);
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }







