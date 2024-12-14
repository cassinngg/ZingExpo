import 'dart:async';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:circular_reveal_animation/circular_reveal_animation.dart';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:circular_reveal_animation/circular_reveal_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/sample/backups/add_quadratsample.dart';
import 'package:zingexpo/screens/BottomNavigationBars/camera_identify.dart';
import 'package:zingexpo/screens/BottomNavigationBars/share_quadrat.dart';
import 'package:zingexpo/screens/bottom_sheets/add_quadrats.dart';
import 'package:zingexpo/screens/edit_screens/edit_project.dart';
import 'package:zingexpo/screens/homepage_screens/home.dart';
import 'package:zingexpo/screens/identify/identify_camera.dart';
import 'package:zingexpo/screens/shannon/shannon.dart';
import 'package:zingexpo/widgets/specific_project/card_quadrat.dart';
import 'package:zingexpo/widgets/specific_project/circular_plant.dart';
import 'package:zingexpo/widgets/heading_page.dart';
// import 'package:lanarsnavbarflutter/theme/app_theme.dart';
// import 'package:lanarsnavbarflutter/theme/custom_colors_theme.dart';

class SpecificProjectsPage extends StatefulWidget {
  Map<String, dynamic> allData;
  final int projectID;
  final VoidCallback onDelete;
  final VoidCallback onProjectUpdated;

  SpecificProjectsPage({
    super.key,
    required this.allData,
    required this.projectID,
    required this.onDelete,
    required this.onProjectUpdated,
    // required this.onProjectUpdated,
  });

  @override
  State<SpecificProjectsPage> createState() => _SpecificProjectsPageState();
}

class _SpecificProjectsPageState extends State<SpecificProjectsPage>
    with TickerProviderStateMixin {
  // final controller = Get.put(NavigationController());
  late final int projectID;
  int _counter = 0;
  int _currentIndex = 0;
  List<Widget> body = [
    Icon(Icons.add),
    Icon(Icons.home),
    Icon(Icons.camera_alt_outlined),
    Icon(Icons.screen_share_outlined)
  ];
  List<Map<String, dynamic>> allData = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> quadratData = [];
  bool isLoading = true;

  Future<void> _loadData() async {
    try {
      final data = await LocalDatabase().readData();
      setState(() {
        allData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error (show dialog, log, etc.)
    }
  }

  void _onFetchUpdated(Map<String, dynamic> updatedData) {
    setState(() {
      widget.allData = updatedData; // Update the project data
    });
    _fetchQuadrats(); // Fetch the updated quadrat data
  }

  Future<void> _fetchQuadrats() async {
    final projectID =
        widget.allData['project_id']; // Get the selected project ID
    if (projectID != null) {
      // Fetch quadrats using the project ID
      quadratData =
          await LocalDatabase().getQuadratsByProjectID(projectID as int);
      _loadData();
    }
    setState(() {
      isLoading = false;
    });
    _loadData();
  }

  // final autoSizeGroup = AutoSizeGroup();
  var _bottomNavIndex = 0;

  late AnimationController _fabAnimationController;
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> fabAnimation;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation fabCurve;
  late CurvedAnimation borderRadiusCurve;
  late AnimationController _hideBottomBarAnimationController;

  final iconList = <IconData>[
    PhosphorIconsBold.plus,
    PhosphorIconsBold.house,
    PhosphorIconsBold.camera,
    PhosphorIconsBold.shareFat,
  ];

  @override
  void initState() {
    super.initState();

    _loadData();
    _fetchQuadrats();

    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _borderRadiusAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    fabCurve = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
    borderRadiusCurve = CurvedAnimation(
      parent: _borderRadiusAnimationController,
      curve: Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    fabAnimation = Tween<double>(begin: 0, end: 1).animate(fabCurve);
    borderRadiusAnimation = Tween<double>(begin: 0, end: 1).animate(
      borderRadiusCurve,
    );

    _hideBottomBarAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    Future.delayed(
      Duration(seconds: 1),
      () => _fabAnimationController.forward(),
    );
    Future.delayed(
      Duration(seconds: 1),
      () => _borderRadiusAnimationController.forward(),
    );
  }

  bool onScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification &&
        notification.metrics.axis == Axis.vertical) {
      switch (notification.direction) {
        case ScrollDirection.forward:
          _hideBottomBarAnimationController.reverse();
          _fabAnimationController.forward(from: 0);
          break;
        case ScrollDirection.reverse:
          _hideBottomBarAnimationController.forward();
          _fabAnimationController.reverse(from: 1);
          break;
        case ScrollDirection.idle:
          break;
      }
    }
    return false;
  }

  void showAddQuadratBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddQuadratForm(
          projectID: widget.projectID,
          onAdd: _fetchQuadrats,
        );
      },
    );
  }

  void _shareProject() {
    String projectDetails = "Project: ${widget.allData['project_name']}\n";
    projectDetails +=
        "Description: ${widget.allData['project_description']}\n\n";
    projectDetails += "Quadrats:\n";

    for (var quadrat in quadratData) {
      projectDetails +=
          "- Quadrant ID: ${quadrat['quadrat_id']}, Details: ${quadrat['details']}\n";
    }

    // Share.share(projectDetails, subject: 'Check out this project!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 58, 56, 56),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon:
                const PhosphorIcon(PhosphorIconsBold.dotsThreeOutlineVertical),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Text('Refresh Page'),
              ),
              const PopupMenuItem(
                value: 'shannonindex',
                child: Text('Calculate Shannon Index'),
              ),
              const PopupMenuItem(
                value: 'shareproject',
                child: Text('Share Project'),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit Project'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Project'),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Are you sure to delete Project?',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      content: const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'This action cannot be undone.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text('All Quadrats will be Deleted'),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.red,
                            ),
                          ),
                          onPressed: () async {
                            await LocalDatabase()
                                .deleteProject(projectid: widget.projectID);

                            widget.onDelete();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const Home()),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              } else if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProject(
                      allData: widget.allData,
                      projectID: widget.projectID,
                      onUpdate: (updatedData) {
                        _onFetchUpdated(updatedData);
                      },
                    ),
                  ),
                );

                // print('Edit Quadrat selected');
              } else if (value == 'shareproject') {
                _shareProject();
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => ShareQuadrat(
                //               projectID: widget.projectID,
                //             )));
              } else if (value == 'shannonindex') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShannonIndexCalculator(
                      projectId: widget.projectID,
                    ),
                  ),
                );
              } else if (value == 'refresh') {
                _refreshData();
                _fetchQuadrats();
              }
            },
          )
        ],
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: HeadingText(
                        title: widget.allData['project_name'] ?? 'N/A',
                        description:
                            widget.allData['project_description'] ?? 'N/A',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // body: NotificationListener<ScrollNotification>(
      //   onNotification: onScrollNotification,
      //   child: NavigationScreen(iconList[_bottomNavIndex]),
      // ),
      body: NotificationListener<ScrollNotification>(
        onNotification: onScrollNotification,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // body[_currentIndex],
                  const SizedBox(height: 13),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Species Found",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  SizedBox(
                      // height: 100, // Set a fixed height for the SizedBox
                      child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        // Set a fixed width for each CircleInfoPage
                        CircleInfoPage(
                          projectId: widget.projectID,
                          allData: widget.allData,
                        ),
                      ],
                    ),
                  )),

                  // return quadratData.isEmpty
                  //     ? CircleInfoPage(
                  //         projectId: widget
                  //             .projectID, // Ensure consistent naming
                  //         allData: widget.allData,
                  //       );
                  // : Container(
                  //     width: MediaQuery.of(context).size.width,
                  //     height: MediaQuery.of(context).size.height *
                  //         0.05, //
                  //     child: Padding(
                  //       padding: const EdgeInsets.only(top: 8.0),
                  //       child: const Center(
                  //         child: Text(
                  //           "No Quadrats created for this project",
                  //           style: TextStyle(
                  //             fontFamily: 'Poppins',
                  //             fontSize: 6,
                  //             fontWeight: FontWeight.w100,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   );

                  const SizedBox(height: 18),
                  const Text(
                    "Quadrats",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 18),
                  quadratData.isNotEmpty
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: quadratData.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: .65,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return QuadratCard(
                              allData: quadratData[index],
                              projectID: widget.projectID,
                              quadratID: quadratData[index]['quadrat_id'],
                              onDelete: () {
                                _fetchQuadrats(); // Fetch the updated list
                              },
                            );
                          },
                        )
                      : const Column(
                          children: [
                            Center(
                              child: Text(
                                "No Quadrats created for this project",
                                style: TextStyle(
                                    fontFamily: 'Poppins', fontSize: 9),
                              ),
                            ),
                            Text(
                              "Add Quadrats To Start.",
                              style:
                                  TextStyle(fontFamily: 'Poppins', fontSize: 5),
                            ),
                          ],
                        )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color =
              isActive ? const Color.fromARGB(255, 18, 155, 23) : Colors.white;

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Tooltip(
                message: _getTooltipText(index),
                showDuration: Duration.zero,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _bottomNavIndex = index;
                      });
                      switch (_bottomNavIndex) {
                        case 0:
                          showAddQuadratBottomSheet(context);

                          // Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //       builder: (context) => AddQuadrat(
                          //             allData: widget.allData,
                          //             projectID: widget.projectID,
                          //             onAdd: _fetchQuadrats,
                          //           )),
                          // );
                          break;
                        case 1:
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const Home(),
                            ),
                            (route) => false,
                          );
                          break;
                        case 2:
                          // Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //       builder: (context) => ImageIdentify()),
                          // );
                          break;
                        case 3:
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ShareQuadrat(
                                      projectID: widget.projectID,
                                    )),
                          );
                          break;
                      }
                    },
                    child: Icon(
                      iconList[index],
                      size: 30,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        backgroundColor: const Color.fromARGB(255, 8, 82, 10),
        activeIndex: _bottomNavIndex,
        splashColor: Colors.white,
        notchAndCornersAnimation: borderRadiusAnimation,
        splashSpeedInMilliseconds: 500,
        notchSmoothness: NotchSmoothness.defaultEdge,
        gapLocation: GapLocation.none,
        // leftCornerRadius: 32,
        // rightCornerRadius: 32,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        hideAnimationController: _hideBottomBarAnimationController,
        shadow: const BoxShadow(
          offset: Offset(0, 1),
          blurRadius: 12,
          spreadRadius: 0.5,
          color: Color.fromARGB(255, 8, 82, 10),
        ),
      ),
    );
  }

  String _getTooltipText(int index) {
    switch (iconList[index]) {
      case Icons.add:
        return 'Add Quadrat';
      case Icons.home:
        return 'Home';
      case Icons.camera:
        return 'Camera';
      case Icons.share:
        return 'Share';
      default:
        return 'Unknown';
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _refreshData() {
    setState(() {
      _counter = 0; // Resetting the counter as an example
    });
  }
}
