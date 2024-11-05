import 'dart:async';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:circular_reveal_animation/circular_reveal_animation.dart';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:circular_reveal_animation/circular_reveal_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zingexpo/database/database.dart';
import 'package:zingexpo/screens/BottomNavigationBars/camera_identify.dart';
import 'package:zingexpo/screens/BottomNavigationBars/share_quadrat.dart';
import 'package:zingexpo/screens/add_quadrats.dart';
import 'package:zingexpo/screens/edit_screens/edit_project.dart';
import 'package:zingexpo/screens/home.dart';
import 'package:zingexpo/widgets/card_quadrat.dart';
import 'package:zingexpo/widgets/heading_page.dart';
// import 'package:lanarsnavbarflutter/theme/app_theme.dart';
// import 'package:lanarsnavbarflutter/theme/custom_colors_theme.dart';

class FloatingSample extends StatefulWidget {
  final Map<String, dynamic> allData;
  final int projectID;
  final VoidCallback onDelete; // Callback for deletion

  const FloatingSample({
    super.key,
    required this.allData,
    required this.projectID,
    required this.onDelete,
  });

  @override
  State<FloatingSample> createState() => _FloatingSampleState();
}

class _FloatingSampleState extends State<FloatingSample>
    with TickerProviderStateMixin {
  // final controller = Get.put(NavigationController());
  late final int projectID;

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
      isLoading = false; // Loading done
    });
    _loadData();
  }

  // final autoSizeGroup = AutoSizeGroup();
  var _bottomNavIndex = 0; //default index of a first screen

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

  void _shareProject() {
    // Create a string representation of the project and its quadrats
    String projectDetails = "Project: ${widget.allData['project_name']}\n";
    projectDetails +=
        "Description: ${widget.allData['project_description']}\n\n";
    projectDetails += "Quadrats:\n";

    for (var quadrat in quadratData) {
      projectDetails +=
          "- Quadrant ID: ${quadrat['quadrat_id']}, Details: ${quadrat['details']}\n"; // Adjust according to your data structure
    }

    // Use the share_plus package to share the project details
    Share.share(projectDetails, subject: 'Check out this project!');
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
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Are you sure to delete Project?',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'This action cannot be undone.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Text('All Quadrats will be Deleted'),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              color: Colors.blue,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text(
                            'Confirm',
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () async {
                            await LocalDatabase()
                                .deleteProject(projectid: widget.projectID);

                            widget
                                .onDelete(); // Call the callback to notify the parent
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
                        allData: widget.allData, projectID: projectID),
                  ),
                );
                // Handle the edit action here
                // For example, you can navigate to an edit screen or show a form
                // print('Edit Quadrat selected');
              } else if (value == 'shareproject') {
                _shareProject();
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => ShareQuadrat(
                //               projectID: widget.projectID,
                //             )));
              }
            },
          )
        ],
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
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
                  SizedBox(height: 13),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Species Found",
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                  ),

                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   child: Row(
                  //     children: allData.map((info) {
                  //       return CircularPlant(
                  //         title: info['genus_name'] ??
                  //             'Unknown Genus', // Default value if 'genus_name' is missing
                  //         imageUrl: info['imageUrl'] ?? '',
                  //         plantId: info['plantId'] ?? '',

                  //         // Default empty string if 'i,mageUrl' is missing
                  //       );
                  //     }).toList(),
                  //   ),
                  // ),
                  SizedBox(height: 18),
                  Text(
                    "Quadrats",
                    style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 18),
                  quadratData.isNotEmpty
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
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
                              quadratID: quadratData[index]['quadrat_id'],
                              onDelete: () {
                                _fetchQuadrats(); // Fetch the updated list
                              },
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            "No Quadrats created for this project",
                            style: GoogleFonts.poppins(fontSize: 9),
                          ),
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
              isActive ? Color.fromARGB(255, 18, 155, 23) : Colors.white;

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
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => AddQuadrat(
                                      allData: widget.allData,
                                      projectID: widget.projectID,
                                      onAdd: _fetchQuadrats,
                                    )),
                          );
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
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    const RealtimeCamScreen()),
                          );
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
        shadow: BoxShadow(
          offset: Offset(0, 1),
          blurRadius: 12,
          spreadRadius: 0.5,
          color: const Color.fromARGB(255, 8, 82, 10),
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
}

class NavigationScreen extends StatefulWidget {
  final IconData iconData;

  NavigationScreen(this.iconData) : super();

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;

  @override
  void didUpdateWidget(NavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.iconData != widget.iconData) {
      _startAnimation();
    }
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
    super.initState();
  }

  _startAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final colors = Theme.of(context).extension<CustomColorsTheme>()!;
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: ListView(
        children: [
          SizedBox(height: 64),
          Center(
            child: CircularRevealAnimation(
              animation: animation,
              centerOffset: Offset(80, 80),
              maxRadius: MediaQuery.of(context).size.longestSide * 1.1,
              child: Icon(
                widget.iconData,
                color: Colors.blue,
                size: 160,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
