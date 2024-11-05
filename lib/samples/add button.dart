import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zingexpo/database/database.dart';
// Uncomment the next line if you actually need to use DatabaseService
// import 'package:zingexpo/database/database.dart';

class sam extends StatefulWidget {
  const sam({super.key});

  @override
  State<sam> createState() => _samState();
}

class _samState extends State<sam> {
  final TextEditingController gingerName = TextEditingController();
  // Uncomment the next line if you actually need to use DatabaseService
  // final DatabaseService _databaseService = DatabaseService.instance;
  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    try {
      await LocalDatabase().database;
      print('Database initialized successfully');
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                child: TextFormField(
                  controller: gingerName,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        borderSide: BorderSide.none),
                    prefix: const Icon(Icons.g_mobiledata),
                    hintText: 'Ginger Name',
                    fillColor: Colors.green.withOpacity(.2),
                    contentPadding:
                        const EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),
                    filled: true,
                  ),
                ),
              ),
              Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                      onPressed: () async {
                        if (gingerName.text.isNotEmpty) {
                          //     await LocalDatabase().addZing(
                          //         name: gingerName.text, text: "Some default text"
                          //          species: speciesController.text,
                          // quadrat: quadratController.text,
                          //         );
                          final data = await LocalDatabase().readData();
                          setState(() {
                            alldatalist = data;
                          });
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Success!"),
                                content: Text("Ginger Successfully Added"),
                                actions: <Widget>[
                                  ElevatedButton(
                                    child: Text("OK"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Error"),
                                content: Text("Please Enter a Ginger Name"),
                                actions: <Widget>[
                                  ElevatedButton(
                                    child: Text("OK"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: Text(
                        'Save To Database',
                        style: GoogleFonts.poppins(),
                      ))),
              ListView.builder(
                  shrinkWrap: true,
                  controller: ScrollController(),
                  itemCount: alldatalist
                      .length, // Ensure AllDataList is accessible here
                  itemBuilder: (context, index) {
                    return Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        height: 90,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(alldatalist[index]['Name']),
                            // Text(AllDataList[index]['Text']),
                          ],
                        ));
                  }),
            ],
          ),
        ),
      )),
      // body: Container(
      //   child: SingleChildScrollView(
      //     child: Column(
      //       children: [
      //         Container(
      //           child: Row(
      //             children: [
      //               TextFormField(
      //                 controller: gingerName,
      //                 decoration: InputDecoration(
      //                   border: OutlineInputBorder(
      //                       borderRadius: BorderRadius.circular(50.0),
      //                       borderSide: BorderSide.none),
      //                   suffixIcon: const Icon(Icons.search_outlined),
      //                   hintText: 'Ginger Name',
      //                   fillColor: Colors.green.withOpacity(.2),
      //                   contentPadding:
      //                       const EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),
      //                   filled: true,
      //                 ),
      //                 style: GoogleFonts.poppins(
      //                   fontSize: 14,
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      // child: ListView.builder(
      //   shrinkWrap: true,
      //   controller: ScrollController(),
      //   itemCount: AllDataList.length, // Ensure AllDataList is accessible here
      //   itemBuilder: (context, index) {
      //     return Container(
      //       margin: EdgeInsets.symmetric(horizontal: 20),
      //       height: 90,
      //       width: double.infinity,
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           Text(AllDataList[index]['Name']), // Corrected trailing comma
      //         ],
      //       ),
      //     );
      //     FloatingActionButton.small(onPressed: () {});
      //   },
      // ),

      // Uncomment and define _addZingButton if needed
      // floatingActionButton: _addZingButton(),
    );
  }
}
