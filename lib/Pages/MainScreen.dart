import 'package:rxdart/rxdart.dart';
import 'package:test_projects/Music/AudioHandler.dart';
import 'package:test_projects/Widgets/CustomSliverList.dart';
import 'package:test_projects/Widgets/ExpandedBottomBar/ExpandedBottomBarController.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:test_projects/Widgets/MusicBar/ControlButtons.dart';
import 'package:test_projects/Widgets/ExpandedBottomBar/CustomFloatingActionButtomForExpanded.dart';
import 'package:test_projects/Widgets/ExpandedBottomBar/ExpandedBottomBar.dart';
import 'package:test_projects/Widgets/MusicBar/CustomMusicBottomBar.dart';
import 'package:test_projects/Widgets/ShowModalBottomSheet.dart';

import '../Widgets/MusicBar/CustomSeekBar.dart';

/// The main screen.
class MainScreen extends StatelessWidget {
  const MainScreen(this.audioHandler, {Key? key}) : super(key: key);

  final AudioPlayerHandler audioHandler;

  Stream<Duration> get _bufferedPositionStream => audioHandler.playbackState
      .map((state) => state.bufferedPosition)
      .distinct();
  Stream<Duration?> get _durationStream =>
      audioHandler.mediaItem.map((item) => item?.duration).distinct();
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          AudioService.position,
          _bufferedPositionStream,
          _durationStream,
              (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          CustomSilverList(audioHandler),
          MusicBottomBar(audioHandler),
        ],
      ),
    );
  }
}


// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     resizeToAvoidBottomInset: false,
//     // resizeToAvoidBottomPadding: false,
//     // backgroundColor: Colors.transparent,
//     // extendBodyBehindAppBar: true,
//
//     // extendBody: true,
//     // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     // floatingActionButton: CustomFloatingActionButton(),
//     // bottomNavigationBar: BottomExpandableAppBar(
//     //   // horizontalMargin: 16,
//     //   shape: AutomaticNotchedShape(
//     //       RoundedRectangleBorder(), StadiumBorder(side: BorderSide())),
//     //   expandedBackColor: Colors.white12.withOpacity(0.9),
//     //   bottomAppBarColor: Colors.white10.withOpacity(0.9),
//     //   expandedHeight: MediaQuery.of(context).size.height * 0.8 - MediaQuery.of(context).padding.vertical,
//     //   expandedBody:  CustomModalBottomSheet(audioHandler),
//     //   bottomAppBarBody: Padding(
//     //     padding: const EdgeInsets.all(0),
//     //     // padding: const EdgeInsets.all(8.0),
//     //     child: Row(
//     //       mainAxisSize: MainAxisSize.max,
//     //       children: <Widget>[
//     //         Expanded(
//     //           child: ControlButtons(audioHandler),
//     //         ),
//     //       ],
//     //     ),
//     //   ),
//     // ),
//     body: Stack(
//       children: [
//         GestureDetector(
//           onPanDown: (details) {
//             print(details.localPosition);
//             DefaultBottomBarController.of(context).close();
//           },
//           onTap: () => DefaultBottomBarController.of(context).close(),
//           child: CustomSilverList(audioHandler),
//         ),
//         // CustomSilverList(_audioHandler),
//         MusicBottomBar(audioHandler),
//       ],
//     ),
//   );
// }