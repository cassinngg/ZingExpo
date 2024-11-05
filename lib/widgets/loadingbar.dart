// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class AnimatedLoadingBar extends StatefulWidget {
//   final double progress;
//   final Color color;

//   const AnimatedLoadingBar({this.progress = 0.5, this.color = Colors.blue});

//   @override
//   _AnimatedLoadingBarState createState() => _AnimatedLoadingBarState();
// }

// class _AnimatedLoadingBarState extends State<AnimatedLoadingBar>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _animation = Tween<double>(begin: 0, end: widget.progress).animate(_controller);
//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TweenAnimationBuilder(
//       controller: _controller,
//       tween: Tween<double>(begin: 0, end: widget.progress),
//       duration: const Duration(milliseconds: 500),
//       builder: (context, value, child) {
//         return LinearProgressIndicator(
//           value: value,
//           backgroundColor: Colors.grey[200],
//           color: widget.color,
//         );
//       },
//     );
//   }
// }
