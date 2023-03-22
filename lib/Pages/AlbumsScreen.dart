import 'package:flutter/material.dart';
import 'package:test_projects/Network/MusicBox.dart';
import 'package:test_projects/Widgets/MusicBar/MusicBottomBar.dart';

import '../Music/AudioHandler.dart';

class AlbumScreen extends StatefulWidget{

  final AudioPlayerHandler audioHandler;
  final MusicBox userMusic;

  const AlbumScreen({Key? key, required this.userMusic, required this.audioHandler}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AlbumScreen();
}

class _AlbumScreen extends State<AlbumScreen>{

  late void Function(dynamic value) myVoidCallback;

  initState() {         // this is called when the class is initialized or called for the first time
    super.initState();  //  this is the material super constructor for init state to link your instance initState to the global initState context
    // Load_more();
    myVoidCallback = (value) {
      // _runFilter(value);
      // updateFilter(value);
      // Добавить функцию закрытия плеера при поиске
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // CustomSilverList(audioHandler),
          MusicBottomBar(myVoidCallback, userMusic: widget.userMusic, audioHandler: widget.audioHandler,),
        ],
      ),
    );
  }
}