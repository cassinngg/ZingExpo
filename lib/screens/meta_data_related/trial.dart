// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:zingexpo/database/database_helper.dart'; // Ensure this path is correct
// import 'package:url_launcher/url_launcher.dart';

// class ListMetaData extends StatefulWidget {
//   @override
//   _ListMetaDataState createState() => _ListMetaDataState();
// }

// class _ListMetaDataState extends State<ListMetaData> {
//   List<Map<String, dynamic>> _images = [];

//   @override
//   void initState() {
//     super.initState();
//     requestPermissions().then((_) {
//       _fetchImages();
//     });
//   }

//   Future<void> _fetchImages() async {
//     DatabaseHelper dbHelper = DatabaseHelper();
//     List<Map<String, dynamic>> images = await dbHelper.getAllImages();

//     // Log the retrieved images
//     print('Retrieved Images: $images');

//     setState(() {
//       _images = images;
//     });
//   }

//   Future<void> requestPermissions() async {
//     var status = await Permission.storage.status;
//     if (!status.isGranted) {
//       await Permission.storage.request();
//     }
//   }

//   Future<void> _downloadImage(String imagePath) async {
//     final directory = await getExternalStorageDirectory();
//     final targetPath = '${directory!.path}/${imagePath.split('/').last}';
//     final imageFile = File(imagePath);

//     if (await imageFile.exists()) {
//       await imageFile.copy(targetPath);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Image downloaded to $targetPath')),
//       );

//       // Open the directory where the image is saved
//       await _openFileExplorer(directory.path);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Image not found')),
//       );
//     }
//   }

//   Future<void> _openFileExplorer(String path) async {
//     final url = 'file://$path';
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Could not open file explorer')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Saved Images'),
//       ),
//       body: _images.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: _images.length,
//               itemBuilder: (context, index) {
//                 final image = _images[index];
//                 return Card(
//                   margin: EdgeInsets.all(10),
//                   child: ListTile(
//                     leading: Image.file(
//                       File(image['image_path']),
//                       width: 50,
//                       height: 50,
//                       fit: BoxFit.cover,
//                     ),
//                     title: Text(image['image_name']),
//                     subtitle: Text(
//                         'Lat: ${image['latitude']}, Lon: ${image['longitude']}'),
//                     trailing: IconButton(
//                       icon: Icon(Icons.download),
//                       onPressed: () {
//                         print(
//                             'Downloading image from path: ${image['image_path']}');
//                         _downloadImage(image['image_path']);
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zingexpo/database/database_helper.dart'; // Ensure this path is correct
import 'package:permission_handler/permission_handler.dart';
// import 'package:dio/dio.dart';

class ListandDownloadMetaData extends StatefulWidget {
  @override
  _ListandDownloadMetaDataState createState() =>
      _ListandDownloadMetaDataState();
}

class _ListandDownloadMetaDataState extends State<ListandDownloadMetaData> {
  List<Map<String, dynamic>> _images = [];

  @override
  void initState() {
    super.initState();
    requestPermissions().then((_) {
      _fetchImages();
    });
  }

  Future<void> requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> _fetchImages() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> images = await dbHelper.getAllImages();

    print('Retrieved Images: $images');

    setState(() {
      _images = images;
    });
  }

  Future<void> _downloadImage(String imageUrl) async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/${imageUrl.split('/').last}';

      // Download the image
      // Dio dio = Dio();
      // await dio.download(imageUrl, tempPath);

      print('Image downloaded to $tempPath');

      await _saveImageToGallery(tempPath);
    } catch (e) {
      print('Error downloading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading image')),
      );
    }
  }

  Future<void> _saveImageToGallery(String imagePath) async {
    final imageFile = File(imagePath);

    if (await imageFile.exists()) {
      final directory = await getExternalStorageDirectory();
      final targetPath =
          '${directory!.path}/Pictures/${imageFile.uri.pathSegments.last}';

      final picturesDir = Directory('${directory.path}/Pictures');
      if (!await picturesDir.exists()) {
        await picturesDir.create(recursive: true);
      }

      await imageFile.copy(targetPath);
      print('Image saved to $targetPath');

      await Process.run('am', [
        'broadcast',
        '-a',
        'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
        '-d',
        'file://$targetPath'
      ]);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to gallery')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Images'),
      ),
      body: _images.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final image = _images[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.file(
                      File(image['image_path']),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(image['image_name']),
                    subtitle: Text(
                        'Lat: ${image['latitude']}, Lon: ${image['longitude']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.download),
                      onPressed: () {
                        print(
                            'Downloading image from URL: ${image['image_url']}');
                        _downloadImage(image['image_url']);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
