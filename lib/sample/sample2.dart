// import 'package:flutter/material.dart';
// import 'package:zingexpo/database/database.dart';

// class sample2 extends StatefulWidget {
//   const sample2({super.key});

//   @override
//   State<sample2> createState() => _sample2State();
// }

// class _sample2State extends State<sample2> {
//   List<Map<String, dynamic>> _allData = [];

//   Future<void> _loadData() async {
//     final data = await LocalDatabase().readData();
//     setState(() {
//       _allData = data;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           ListView.builder(
//             itemCount: _allData.length,
//             itemBuilder: (context, index) {
//               return Card(
//                 child: ListTile(
//                   leading: _allData[index]["Image"] != null
//                       ? Image.memory(_allData[index]["Image"])
//                       : Icon(Icons.image),
//                   title: Text(_allData[index]["Name"]),
//                   subtitle: Text(
//                       "Species: ${_allData[index]["Species"]}\nQuadrat: ${_allData[index]["Quadrat"]}"),
//                 ),
//               );
//             },
//           ),
//           // ListView.builder(
//           //     shrinkWrap: true,
//           //     controller: ScrollController(),
//           //     itemCount:
//           //         alldatalist.length, // Ensure AllDataList is accessible here
//           //     itemBuilder: (context, index) {
//           //       return Container(
//           //           margin: EdgeInsets.symmetric(horizontal: 20),
//           //           height: 90,
//           //           width: double.infinity,
//           //           child: Row(
//           //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           //             children: [
//           //               Text(alldatalist[index]['Name']),
//           //               // Text(AllDataList[index]['Text']),
//           //             ],
//           //           ));
//           //     }),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:zingexpo/database/database.dart';

class sample2 extends StatefulWidget {
  const sample2({super.key});

  @override
  State<sample2> createState() => _sample2State();
}

class _sample2State extends State<sample2> {
  List<Map<String, dynamic>> _allData = [];
  bool _isLoading = true;

  Future<void> _loadData() async {
    try {
      final data = await LocalDatabase().readData();
      setState(() {
        _allData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error (show dialog, log, etc.)
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sample 2')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allData.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: _allData[index]["Image"] != null
                        ? Image.memory(_allData[index]["Image"])
                        : Icon(Icons.image),
                    title: Text(_allData[index]["Name"]),
                    subtitle: Text(
                        "Species: ${_allData[index]["Species"]}\nQuadrat: ${_allData[index]["Quadrat"]}"),
                  ),
                );
              },
            ),
    );
  }
}
