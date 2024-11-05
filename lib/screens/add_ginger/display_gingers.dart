import 'package:flutter/material.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/screens/add_ginger/add.dart';

class DisplayGinger extends StatefulWidget {
  const DisplayGinger({super.key});

  @override
  State<DisplayGinger> createState() => _DisplayGingerState();
}

class _DisplayGingerState extends State<DisplayGinger> {
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
      appBar: AppBar(title: Text('Saved Gingers')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: LocalDatabase().readDataGinger(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> ginger = snapshot.data![index];
              return ListTile(
                title: Text(ginger['ginger_name'] ?? 'N/A'),
                subtitle: Text(
                    ginger['ginger_description'].substring(0, 50) + '...' ??
                        'N/A'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddGingerPage()),
          );
        },
        child: Icon(
          Icons.add,
          color: const Color.fromARGB(255, 8, 82, 10),
        ),
      ),
    );
  }
}
