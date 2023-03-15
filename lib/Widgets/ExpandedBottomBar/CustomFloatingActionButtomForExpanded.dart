import 'package:flutter/material.dart';
import 'package:test_projects/Widgets/ExpandedBottomBar/ExpandedBottomBarController.dart';

class CustomFloatingActionButton extends StatefulWidget{
  const CustomFloatingActionButton({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState()  => _CustomFloatingActionButton();

}

class _CustomFloatingActionButton extends State<CustomFloatingActionButton> {

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: 16.0,
      width: 64.0,
      child: GestureDetector(
          // Set onVerticalDrag event to drag handlers of controller for swipe effect
          onVerticalDragUpdate: DefaultBottomBarController.of(context).onDrag,
          onVerticalDragEnd: DefaultBottomBarController.of(context).onDragEnd,
          child: FloatingActionButton.extended(
              label: AnimatedBuilder(
                  animation: DefaultBottomBarController.of(context).state,
                  builder: (context, child) => Row(
                    children: [
                      Container(color: Colors.white, width: 40, height: 4,),
                    ],
                  ),
              ),
              elevation: 2,
              backgroundColor: Colors.grey,
              // foregroundColor: Colors.white,
              //Set onPressed event to swap state of bottom bar
              onPressed: () => DefaultBottomBarController.of(context).swap(),
          ),
      ),
    );
  }
}





// floatingActionButton: SizedBox(
//   height: 16.0,
//   width: 64.0,
//   child: GestureDetector(
//     // Set onVerticalDrag event to drag handlers of controller for swipe effect
//     onVerticalDragUpdate: DefaultBottomBarController.of(context).onDrag,
//     onVerticalDragEnd: DefaultBottomBarController.of(context).onDragEnd,
//     child: FloatingActionButton.extended(
//       label: AnimatedBuilder(
//         animation: DefaultBottomBarController.of(context).state,
//         builder: (context, child) => Row(
//           children: [
//             Container(color: Colors.white, width: 40, height: 4,),
//           ],
//         ),
//       ),
//       elevation: 2,
//       backgroundColor: Colors.grey,
//       // foregroundColor: Colors.white,
//       //Set onPressed event to swap state of bottom bar
//       onPressed: () => DefaultBottomBarController.of(context).swap(),
//     ),
//   ),
// ),
// floatingActionButton: GestureDetector(
//   //
//   // Set onVerticalDrag event to drag handlers of controller for swipe effect
//   onVerticalDragUpdate: DefaultBottomBarController.of(context).onDrag,
//   onVerticalDragEnd: DefaultBottomBarController.of(context).onDragEnd,
//   child: FloatingActionButton.extended(
//     label: AnimatedBuilder(
//       animation: DefaultBottomBarController.of(context).state,
//       builder: (context, child) => Row(
//         children: [
//           // Text(
//           //   DefaultBottomBarController.of(context).isOpen
//           //       ? "Pull"
//           //       : "Pull",
//           // ),
//           // // const SizedBox(width: 4.0, height: 0.2,),
//           Container(color: Colors.white, width: 40, height: 4,),
//           // AnimatedBuilder(
//           //   animation: DefaultBottomBarController.of(context).state,
//           //   builder: (context, child) => Transform(
//           //     alignment: Alignment.center,
//           //     transform: Matrix4.diagonal3Values(
//           //       1,
//           //       DefaultBottomBarController.of(context).state.value * 2 -
//           //           1,
//           //       1,
//           //     ),
//           //     child: child,
//           //   ),
//           //   child: RotatedBox(
//           //     quarterTurns: 1,
//           //     child: Icon(
//           //       Icons.chevron_right,
//           //       size: 20,
//           //     ),
//           //   ),
//           // ),
//         ],
//       ),
//     ),
//     elevation: 2,
//     backgroundColor: Colors.deepOrange,
//     // foregroundColor: Colors.white,
//     //
//     //Set onPressed event to swap state of bottom bar
//     onPressed: () => DefaultBottomBarController.of(context).swap(),
//   ),
// ),
//