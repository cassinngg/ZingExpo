import 'package:flutter/material.dart';
import 'package:zingexpo/database/database.dart';

class GingerCard extends StatefulWidget {
  final Map<String, dynamic> allData;
  const GingerCard({super.key, required this.allData});

  @override
  State<GingerCard> createState() => _GingerCardState();
}

class _GingerCardState extends State<GingerCard> {
  List<Map<String, dynamic>> allData = [];
  // bool _isLoading = true;
  List quadratData = [];
  bool isLoading = true;

  Future<void> _loadData() async {
    try {
      final data = await LocalDatabase().readData();
      setState(() {
        allData = data;
        // _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // _isLoading = false;
      });
      // Handle error (show dialog, log, etc.)
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _fetchQuadrats();
  }

  Future<void> _fetchQuadrats() async {
    // final quadratID = widget.allData['quadrat_id'];
    final gingerID = widget.allData['species_id'];
    if (gingerID != null) {
      quadratData =
          await LocalDatabase().getGingersFromQuadrats(gingerID as int);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 220,
        height: 280,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: const Color(0xFFF0F0F0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: widget.allData['quadrat_image'] != null
                          ? Image.memory(widget.allData['quadrat_image']!,
                              width: 206, height: 160, fit: BoxFit.cover)
                          : Center(
                              child: Image.asset(
                                "assets/zingiber_zerumbet.jpg",
                                width: 206,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(10),
                    //   child: Image.asset(
                    //     widget.imageUrl,
                    //     width: 206,
                    //     height: 160,
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                    Positioned(
                      left: 5,
                      top: 5,
                      child: SizedBox(
                        width: 55,
                        height: 25,
                        child: ElevatedButton(
                          onPressed: () {
                            // print('Button pressed ...');
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.white), // Set button color to white
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Color(0xFF023C0E),
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.allData['ginger_name'],
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.allData['sub_family'],
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                  ),
                ),
                const SizedBox(
                  width: 40,
                ),
                Text(
                  widget.allData['tribe'],
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                  ),
                ),
                const Row(
                  children: [
                    Icon(
                      Icons.grass_outlined,
                      size: 20,
                      color: Color(0xFF023C0E),
                    ),
                    Text(
                      "Zingiberaceae",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
