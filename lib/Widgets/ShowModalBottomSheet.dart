import 'dart:ui' as ui;
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test_projects/Music/AudioHandler.dart';
import 'package:test_projects/Widgets/CustomSliverList.dart';
import 'package:test_projects/Widgets/CustomSliverList.dart';
import 'package:test_projects/Widgets/MusicBar/ControlButtons.dart';
import 'package:test_projects/Widgets/MusicBar/CustomMusicBottomBar.dart';
import 'package:test_projects/Widgets/MusicBar/CustomSeekBar.dart';
import 'package:test_projects/main.dart';

class CustomModalBottomSheet extends StatefulWidget{

  final AudioPlayerHandler audioHandler;

  const CustomModalBottomSheet(this.audioHandler, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomModalBottomSheet();
}

class _CustomModalBottomSheet extends State<CustomModalBottomSheet> {

  Stream<Duration> get _bufferedPositionStream => widget.audioHandler.playbackState
      .map((state) => state.bufferedPosition)
      .distinct();
  Stream<Duration?> get _durationStream =>
      widget.audioHandler.mediaItem.map((item) => item?.duration).distinct();
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          AudioService.position,
          _bufferedPositionStream,
          _durationStream,
              (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width * 0.8,
      child:  ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: 1,
          itemBuilder: (BuildContext context, int index){
            return StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context, snapshot1) {
                  final positionData = snapshot1.data;
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white10.withOpacity(0.8),
                        border: Border.all(
                          width: 0,
                          color: Colors.grey,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20))
                    ),
                    child: PageView(
                      children: [
                        MusicBarWidget(audioHandler: widget.audioHandler, positionData: positionData),
                        SmallPlaylistWidget(audioHandler: widget.audioHandler),
                      ],
                    ),
                  );
                }
            );
          }
      ),
    );
  }
}

class MusicBarWidget extends StatefulWidget{
  const MusicBarWidget({Key? key, required this.audioHandler,required this.positionData}) : super(key: key);

  final AudioPlayerHandler audioHandler;
  final PositionData? positionData;
  
  @override
  State<StatefulWidget> createState()  => _MusicBarWidget();

}

class _MusicBarWidget extends State<MusicBarWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: MediaQuery.of(context).size.height,
      // width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 2 - 40,
            width: MediaQuery.of(context).size.height * 0.8 / 2,
            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            color: Colors.blue.withOpacity(0.8),
          ),
          Container(
              alignment: Alignment.bottomCenter,
              height: 40,
              width: 400,
              child: SeekBar(
                duration: widget.positionData?.duration ?? Duration
                    .zero,
                position: widget.positionData?.position ?? Duration
                    .zero,
                bufferedPosition:
                widget.positionData?.bufferedPosition ?? Duration.zero,
                onChangeEnd: widget.audioHandler.seek,
              )
          ),
          Container(
            child: Text(widget.audioHandler.mediaItem.value!.title),
          ),
          GestureDetector(
            onTap: () {
              setState((){
                var value = widget.audioHandler.mediaItem.value!.artist!;
                myVoidCallback(value);
                // isOpen_ModalBottomSheet = false;
              });
              // CurrentPage = 1;
              // Navigator.pushReplacementNamed(context, "audio list");
            },
            child: Text(widget.audioHandler.mediaItem.value!.artist!, style: TextStyle(color: Colors.blue),),
          ),
          ControlButtons(widget.audioHandler),
          Align(
            alignment: Alignment.bottomCenter,
            child:
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.circle, size: 7,),
                  Icon(Icons.list, size: 14,),
                ],
              ),
          ),
        ],
      ),
    );
  }

}

class SmallPlaylistWidget extends StatefulWidget{
  const SmallPlaylistWidget({Key? key, required this.audioHandler}) : super(key: key);

  final AudioPlayerHandler audioHandler;

  @override
  State<StatefulWidget> createState()  => _SmallPlaylistWidget();

}

class _SmallPlaylistWidget extends State<SmallPlaylistWidget> {

  onTapped(int index){
    // isOpen_ModalBottomSheet = true;
    if(currentIndex != index) {
      CurrentPlay(index);
    }
    setState(() {
      if (widget.audioHandler.playbackState.value.playing != true || index != currentIndex) {
        widget.audioHandler.play();
        print(widget.audioHandler.mediaItem.value!.id);
      } else if (widget.audioHandler.playbackState.value.processingState != ProcessingState.completed &&
          index == currentIndex) {
        widget.audioHandler.pause();
      } else {
        widget.audioHandler.seek(Duration.zero);
      }
      // isVisible = true;
      currentIndex = index;
    });
  }

  CurrentPlay(int index) async {
    await widget.audioHandler.skipToQueueItem(index);
    await widget.audioHandler.play();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
      child:
          ReorderableListView.builder(
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) newIndex--;
                // widget.audioHandler.moveQueueItem(oldIndex, newIndex);
                var music = smallPlaylist[oldIndex];
                smallPlaylist.remove(smallPlaylist[oldIndex]);
                smallPlaylist.insert(newIndex, music);
              });
            },
            itemCount: smallPlaylist.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                key: ValueKey(index),
                color: index == currentIndex ? Colors.grey.shade300 : null,
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: 50,
                  width: MediaQuery.of(context).size.width - 120,
                  child: GestureDetector(
                    onTap: () {
                      onTapped(index);
                    },
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.purple[100 * (index % 9 + 1)]!,
                                borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            padding: EdgeInsets.all(10),
                            width: 35,
                            height: 35,
                            // child: Icon(Icons.music_video_sharp, color: Colors.black,),
                          ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  smallPlaylist[index].name!.trim(),
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  smallPlaylist[index].author!.trim(),
                                  // textAlign: TextAlign.left,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ]
                          ),
                        ],
                      )
                    )
                  )
                ),
              );
            },
          ),
          // Row(
          //   mainAxisSize: MainAxisSize.min,
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: const [
          //     Icon(Icons.circle, size: 7,),
          //     Icon(Icons.list, size: 14,),
          //   ],
          // ),
      //   ],
      // ),
    );
  }
}
    //
    //
    // return ReorderableListView.builder(
    //   onReorder: (int oldIndex, int newIndex) {
    //     setState(() {
    //       if (oldIndex < newIndex) newIndex--;
    //       // widget.audioHandler.moveQueueItem(oldIndex, newIndex);
    //       var music = smallPlaylist[oldIndex];
    //       smallPlaylist.remove(smallPlaylist[oldIndex]);
    //       smallPlaylist.insert(newIndex, music);
    //     });
    //   },
    //   itemCount: smallPlaylist.length,
    //   itemBuilder: (BuildContext context, int index) {
    //     return Card(
    //       // key: ValueKey(queue[index].title),
    //       key: ValueKey(index),
    //       color: index == currentIndex
    //           ? Colors.grey.shade300
    //           : null,
    //       child: SizedBox(
    //         width: MediaQuery
    //             .of(context)
    //             .size
    //             .width - 120,
    //         child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               Text(
    //                 smallPlaylist[index].name!.trim(),
    //                 textAlign: TextAlign.left,
    //                 maxLines: 1,
    //                 overflow: TextOverflow.ellipsis,
    //                 style: TextStyle(fontSize: 18),
    //               ),
    //               Text(
    //                 smallPlaylist[index].author!,
    //                 // textAlign: TextAlign.left,
    //                 maxLines: 1,
    //                 overflow: TextOverflow.ellipsis,
    //                 style: TextStyle(fontSize: 14),
    //               ),
    //             ]
    //         ),
    //       ),
    //     );
    //   },
    // );


