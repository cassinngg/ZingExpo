import 'package:flutter/material.dart';

class TabBarWidget extends StatefulWidget {
  @override
  _TabBarWidgetState createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Projects'),
            Tab(text: 'Archived'),
          ],
          indicatorColor: Colors.green,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Content for Projects tab
          Center(child: Text('Projects Tab')),
          // Content for Archived tab
          Center(child: Text('Archived Tab')),
        ],
      ),
    );
  }
}
