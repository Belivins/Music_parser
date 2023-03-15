import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_projects/Music/AudioHandler.dart';
import 'package:test_projects/Pages/AlbumsList.dart';
import 'package:test_projects/Pages/FirstPage.dart';
import 'package:test_projects/Pages/MainScreen.dart';
import 'package:test_projects/Widgets/ExpandedBottomBar/ExpandedBottomBarController.dart';
import 'package:test_projects/Music/music.dart';
import 'package:test_projects/Network/network.dart';

// You might want to provide this using dependency injection rather than a
// global variable.
late AudioPlayerHandler _audioHandler;
late List<Music> allMusic;
List<Music> findMusic = [];
List<Music> smallPlaylist = List.from(findMusic);
int currentIndex = -1;
int CurrentPage = -1;

updateMusicList(List<Music> newMusic){
  allMusic = music_list;
  findMusic = music_list;
}

getMusicList(){
  return findMusic;
}

Future<void> main() async {
  _audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandlerImpl(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  // await getAudio();
  runApp(const MyApp());
}

/// The app widget
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Audio Service Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      // home: DefaultBottomBarController(
      //   child: MainScreen(_audioHandler),
      // ),
      // home: const MainScreen(),
      home: FirstPage(audioHandler: _audioHandler),
      routes: {
        "audio list":(context)=>MainScreen(_audioHandler),
        "albums list":(context)=>AlbumScreen(_audioHandler),
      },
    );
  }
}



// import 'package:example/theme.dart';
// import 'package:expandable_bottom_bar/expandable_bottom_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:test_projects/Widgets/ExpandedBottomBar/CustomFloatingActionButtomForExpanded.dart';
// import 'Widgets/ExpandedBottomBar/ExpandedBottomBar.dart';
// import 'Widgets/ExpandedBottomBar/ExpandedBottomBarController.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       // theme: CustomTheme.dark(),
//       home: DefaultBottomBarController(
//         child: ExamplePage(),
//       ),
//     );
//   }
// }
//
// class ExamplePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).canvasColor,
//       //
//       // Set [extendBody] to true for bottom app bar overlap body content
//       extendBody: true,
//       appBar: AppBar(
//         title: Text("Panel Showcase"),
//         backgroundColor: Theme.of(context).bottomAppBarColor,
//       ),
//       //
//       // Lets use docked FAB for handling state of sheet
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButton: CustomFloatingActionButton(),
//
//       // Actual expandable bottom bar
//       bottomNavigationBar: BottomExpandableAppBar(
//         // horizontalMargin: 16,
//         shape: AutomaticNotchedShape(
//             RoundedRectangleBorder(), StadiumBorder(side: BorderSide())),
//         expandedBackColor: Colors.grey.withOpacity(0.8),
//         bottomAppBarColor: Colors.transparent,
//         expandedBody: PageView(
//           children: [
//             Container(color: Colors.pinkAccent.withOpacity(0.8),),
//             Container(color: Colors.blue.withOpacity(0.2),),
//           ],
//         ),
//         bottomAppBarBody: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             mainAxisSize: MainAxisSize.max,
//             children: <Widget>[
//               Expanded(
//                 child: Text(
//                   "Foo",
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               Spacer(
//                 flex: 2,
//               ),
//               Expanded(
//                 child: Text(
//                   "Bar",
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           GridView.builder(
//             itemCount: 30,
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//             ),
//             itemBuilder: (context, index) => Card(
//               color: Theme.of(context).bottomAppBarColor,
//               child: Text(
//                 index.toString(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
