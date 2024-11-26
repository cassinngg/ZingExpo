// import 'dart:math';
// import 'package:flutter/material.dart';

// class ShannonIndexCalculator extends StatefulWidget {
//   @override
//   _ShannonIndexCalculatorState createState() => _ShannonIndexCalculatorState();
// }

// class _ShannonIndexCalculatorState extends State<ShannonIndexCalculator> {
//   final TextEditingController _controller = TextEditingController();
//   List<int> _speciesCounts = [];
//   double _shannonIndex = 0;

//   void calculate() {
//     setState(() {
//       _shannonIndex = calculateShannonIndex(_speciesCounts);
//     });
//   }

//   double calculateShannonIndex(List<int> speciesCounts) {
//     double total = speciesCounts.reduce((a, b) => a + b).toDouble();
//     List<double> proportions =
//         speciesCounts.map((count) => count.toDouble() / total).toList();
//     return -proportions.map((p) => p * log(p)).reduce((a, b) => a + b);
//   }

//   void addSpeciesCount(String input) {
//     if (input.isNotEmpty) {
//       int count = int.tryParse(input) ?? 0;
//       if (count > 0) {
//         setState(() {
//           _speciesCounts.add(count);
//           _controller.clear();
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Shannon Index Calculator'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 labelText: 'Enter species count',
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.add),
//                   onPressed: () => addSpeciesCount(_controller.text),
//                 ),
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 calculate();
//               },
//               child: Text('Calculate Shannon Index'),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Shannon Index: $_shannonIndex',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Species Counts: ${_speciesCounts.join(', ')}',
//               style: TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'dart:math';

class ShannonIndexCalculator extends StatefulWidget {
  final int projectId;

  const ShannonIndexCalculator({super.key, required this.projectId});
  @override
  _ShannonIndexCalculatorState createState() => _ShannonIndexCalculatorState();
}

class _ShannonIndexCalculatorState extends State<ShannonIndexCalculator> {
  final TextEditingController projectIdController = TextEditingController();
  final List<int> speciesCounts = [];
  double shannonIndex = 0.0;

  // Predefined species counts for demonstration based on projectId
  final Map<String, List<int>> projectSpeciesData = {
    'project1': [10, 20, 30],
    'project2': [5, 15, 25, 10],
    'project3': [1, 1, 1, 1, 1],
  };

  void fetchSpeciesCounts(String projectId) {
    // Simulating fetching species counts based on projectId
    if (projectSpeciesData.containsKey(projectId)) {
      setState(() {
        speciesCounts.clear(); // Clear previous counts
        speciesCounts.addAll(projectSpeciesData[projectId]!); // Add new counts
        calculateShannonIndex(); // Recalculate Shannon Index based on new data
      });
    } else {
      // Handle case when projectId is not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No data found for project ID: $projectId')),
      );
    }
  }

  void calculateShannonIndex() {
    if (speciesCounts.isEmpty) return;

    int totalSpeciesCount = speciesCounts.reduce((a, b) => a + b);
    double index = 0.0;

    for (int count in speciesCounts) {
      double proportion = count / totalSpeciesCount;
      if (proportion > 0) {
        index -= proportion * log(proportion) / log(2); // Log base 2
      }
    }

    setState(() {
      shannonIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Shannon Index Calculator'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: projectIdController,
              decoration: const InputDecoration(
                labelText: 'Enter Project ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                String projectId = projectIdController.text.trim();
                fetchSpeciesCounts(projectId);
              },
              child: const Text('Fetch Species Counts'),
            ),
            const SizedBox(height: 20),
            Text(
              'Species Counts: ${speciesCounts.join(', ')}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Shannon Index: $shannonIndex',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class ShannonIndexCalculator extends StatefulWidget {
//   @override
//   _ShannonIndexCalculatorState createState() => _ShannonIndexCalculatorState();
// }

// class _ShannonIndexCalculatorState extends State<ShannonIndexCalculator> {
//   List<int> _speciesCounts = [5, 10, 15]; // Example data
//   double _shannonIndex = 0;

//   double calculateShannonIndex(List<int> speciesCounts) {
//     double total = speciesCounts.reduce((a, b) => a + b).toDouble();
//     List<double> proportions =
//         speciesCounts.map((count) => count.toDouble() / total).toList();
//     return -proportions.map((p) => p * log(p)).reduce((a, b) => a + b);
//   }

//   // Change return type from List<FlSpot> to List<ScatterSpot>
//   List<ScatterSpot> getScatterData() {
//     List<ScatterSpot> spots = [];
//     for (int i = 0; i < _speciesCounts.length; i++) {
//       // Create ScatterSpot instead of FlSpot
//       spots.add(ScatterSpot(
//           i.toDouble(), calculateShannonIndex([_speciesCounts[i]])));
//     }
//     return spots;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Shannon Index Calculator'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ScatterChart(
//               ScatterChartData(
//                 scatterSpots: getScatterData(),
//                 titlesData: FlTitlesData(
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 40, // Adjust size as needed
//                       getTitlesWidget: (value, meta) {
//                         return Text(value.toString()); // Customize title widget
//                       },
//                     ),
//                   ),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 40, // Adjust size as needed
//                       getTitlesWidget: (value, meta) {
//                         return Text(value.toString()); // Customize title widget
//                       },
//                     ),
//                   ),
//                 ),
//                 borderData: FlBorderData(show: true),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
