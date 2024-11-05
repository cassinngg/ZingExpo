// project_carousel.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:zingexpo/design/card_design.dart';

class ProjectCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> projects;
  final bool isSearching;

  const ProjectCarousel({
    Key? key,
    required this.projects,
    required this.isSearching,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: projects.length,
      // isSearching ? projects.length : projects.length,
      itemBuilder: (context, index, realIndex) {
        return CardDesign(
          allData: projects[index],
          projectID: projects[index]['project_id'],
         
        );
      },
      options: CarouselOptions(
        height: 320,
        autoPlay: false,
        aspectRatio: 3.0,
        viewportFraction: 0.63,
        enableInfiniteScroll: false,
      ),
    );
  }
}
