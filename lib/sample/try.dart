import 'package:flutter/material.dart';
import 'package:zingexpo/database/database.dart';

class QuadratList extends StatefulWidget {
  @override
  _QuadratListState createState() => _QuadratListState();
}

class _QuadratListState extends State<QuadratList> {
  List<Map<String, dynamic>> _quadrats = [];
  bool _isLoading = true;

  Future<void> _loadQuadrats() async {
    try {
      final data = await LocalDatabase().readDataQuadrat();
      print("Loaded quadrats: ${data.length}");
      setState(() {
        _quadrats = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading quadrats: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadQuadrats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quadrat List')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _quadrats.isEmpty
              ? Center(child: Text('No data available'))
              : ListView.builder(
                  itemCount: _quadrats.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 5,
                      margin: EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _quadrats[index]['quadrat_image'] != null
                                  ? Image.memory(
                                      _quadrats[index]['quadrat_image'],
                                      width: 100,
                                      height: 80,
                                      fit: BoxFit.cover)
                                  : Image.asset("assets/default_image.png",
                                      width: 100,
                                      height: 80,
                                      fit: BoxFit.cover),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_quadrats[index]['quadrat_name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(_quadrats[index]['quadrat_description']),
                                  Text(
                                      'Lat: ${_quadrats[index]['latitude']}, Long: ${_quadrats[index]['longitude']}')
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
