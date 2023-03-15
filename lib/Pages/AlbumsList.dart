import 'package:flutter/material.dart';
import 'package:test_projects/Widgets/MusicBar/CustomMusicBottomBar.dart';

import '../Music/AudioHandler.dart';

/// The main screen.
class AlbumScreen extends StatelessWidget {
  const AlbumScreen(this.audioHandler, {Key? key}) : super(key: key);

  final AudioPlayerHandler audioHandler;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // CustomSilverList(audioHandler),
          MusicBottomBar(audioHandler),
        ],
      ),
    );
  }
}