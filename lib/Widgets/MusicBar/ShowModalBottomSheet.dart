import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test_projects/Music/AudioHandler.dart';
import 'package:test_projects/Network/MusicBox.dart';
import 'package:test_projects/Widgets/MusicBar/ControlButtons.dart';
import 'package:test_projects/Widgets/MusicBar/CustomSeekBar.dart';
import 'package:test_projects/main.dart';

class CustomModalBottomSheet extends StatefulWidget{

  final AudioPlayerHandler audioHandler;
  final void Function(dynamic value)  updateMusicList;
  final MusicBox userMusic;

  const CustomModalBottomSheet({Key? key, required this.userMusic, required this.updateMusicList, required this.audioHandler}) : super(key: key);

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
          physics: const NeverScrollableScrollPhysics(),
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
                        // color: Colors.white10.withOpacity(0.8),
                        color: Colors.white,
                        border: Border.all(
                          width: 0,
                          color: Colors.grey,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20))
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {Navigator.pop(context);},
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            height: MediaQuery.of(context).size.height * 0.01,
                            width: MediaQuery.of(context).size.height * 0.1,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                            ),
                          ),
                        ),
                        Expanded(
                            child: PageView(
                              children: [
                                MusicBarWidget(audioHandler: widget.audioHandler, positionData: positionData, widget.updateMusicList),
                                SmallPlaylistWidget(audioHandler: widget.audioHandler, userMusic: widget.userMusic,),
                              ],
                            ),
                        )
                      ],
                    )
                  );
                }
            );
          }
      ),
    );
  }
}

class MusicBarWidget extends StatefulWidget{
  const MusicBarWidget(this.updateMusicList, {Key? key, required this.audioHandler,required this.positionData}) : super(key: key);

  final AudioPlayerHandler audioHandler;
  final PositionData? positionData;
  final void Function(dynamic value)  updateMusicList;

  @override
  State<StatefulWidget> createState()  => _MusicBarWidget();

}

class _MusicBarWidget extends State<MusicBarWidget> {

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 2 - 40,
          width: MediaQuery.of(context).size.height * 0.8 / 2,
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          decoration: BoxDecoration(
            // color: Colors.blue.withOpacity(0.8),
            image: DecorationImage(
              image: widget.audioHandler.mediaItem.value!.artUri.toString().isEmpty ? const AssetImage("assets/images/note_img.png") as ImageProvider : NetworkImage(widget.audioHandler.mediaItem.value!.artUri.toString()),
              fit: BoxFit.cover,
            ),
          ),
          // child: Image.network(widget.audioHandler.mediaItem.value!.artUri.toString(), fit: BoxFit.cover,),
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
        SizedBox(
          width: MediaQuery.of(context).size.width - 60,
          child: Text(widget.audioHandler.mediaItem.value!.title, textAlign: TextAlign.center,),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              var value = widget.audioHandler.mediaItem.value!.artist!;
              widget.updateMusicList(value);
              Navigator.pop(context);
            });
          },
          child: Text(widget.audioHandler.mediaItem.value!.artist!, style: const TextStyle(color: Colors.blue),),
        ),
        ControlButtons(widget.audioHandler),
        Align(
          alignment: Alignment.bottomCenter,
          child:
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(Icons.circle, size: 7,),
                Icon(Icons.list, size: 14,),
              ],
            ),
        ),
      ],
    );
  }

}

class SmallPlaylistWidget extends StatefulWidget{
  const SmallPlaylistWidget({Key? key, required this.audioHandler, required this.userMusic}) : super(key: key);

  final AudioPlayerHandler audioHandler;
  final MusicBox userMusic;

  @override
  State<StatefulWidget> createState()  => _SmallPlaylistWidget();

}

class _SmallPlaylistWidget extends State<SmallPlaylistWidget> {

  onTapped(int index){
    // isOpen_ModalBottomSheet = true;
    if(widget.userMusic.currentIndex != index) {
      CurrentPlay(index);
    }
    setState(() {
      if (widget.audioHandler.playbackState.value.playing != true || index != widget.userMusic.currentIndex) {
        widget.audioHandler.play();
      } else if (widget.audioHandler.playbackState.value.processingState != ProcessingState.completed &&
          index == widget.userMusic.currentIndex) {
        widget.audioHandler.pause();
      } else {
        widget.audioHandler.seek(Duration.zero);
      }
      // isVisible = true;
      widget.userMusic.currentIndex = index;
    });
  }

  CurrentPlay(int index) async {
    await widget.audioHandler.skipToQueueItem(index);
    await widget.audioHandler.play();
  }

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
    //   child: ReorderableListView.builder(
    //       onReorder: (int oldIndex, int newIndex) {
    //         setState(() {
    //           if (oldIndex < newIndex) newIndex--;
    //           // widget.audioHandler.moveQueueItem(oldIndex, newIndex);
    //           var music = widget.userMusic.smallPlaylist[oldIndex];
    //           widget.userMusic.smallPlaylist.remove(widget.userMusic.smallPlaylist[oldIndex]);
    //           widget.userMusic.smallPlaylist.insert(newIndex, music);
    //         });
    //       },
    //       // itemExtent: 50,
    //       itemCount: widget.userMusic.smallPlaylist.length,
    //       itemBuilder: (BuildContext context, int index) {
    //         var ImageContainer;
    //         final playbackState = widget.audioHandler.playbackState;
    //         final processingState = playbackState.value.processingState;
    //         final playing = playbackState.value.playing;
    //         if (widget.audioHandler.mediaItem.value?.id == widget.userMusic.findMusic[index].link){
    //           if (playing == true ) {
    //             ImageContainer =  Container(
    //                 alignment: Alignment.center,
    //                 child: const Icon(
    //                   Icons.pause, size: 20, color: Colors.white70,)
    //             );
    //           } else {
    //             ImageContainer =  const Icon(
    //               Icons.play_arrow, size: 20.0, color: Colors.white70,);
    //           }
    //         }
    //         else {
    //           ImageContainer =  Container();
    //         }
    //
    //         return Card(
    //           key: ValueKey(index),
    //           // color: index == widget.userMusic.currentIndex ? Colors.grey.shade300 : null,
    //           color: widget.userMusic.smallPlaylist[index].link == widget.audioHandler.mediaItem.value?.id ? Colors.grey.shade300 : null,
    //           child: Container(
    //             alignment: Alignment.centerLeft,
    //             height: 50,
    //             width: MediaQuery.of(context).size.width - 120,
    //             child: GestureDetector(
    //               onTap: () {
    //                 onTapped(index);
    //               },
    //               child: SingleChildScrollView(
    //                 physics: const NeverScrollableScrollPhysics(),
    //                 child: Row(
    //                   children: [
    //                     Container(
    //                       margin: const EdgeInsets.symmetric(horizontal: 5),
    //                       // padding: const EdgeInsets.all(10),
    //                       width: 35,
    //                       height: 35,
    //                       decoration: BoxDecoration(
    //                         color: Colors.purple[100 * (index % 9 + 1)]!,
    //                         borderRadius: const BorderRadius.all(Radius.circular(10)),
    //                         image: DecorationImage(
    //                           image: widget.userMusic.smallPlaylist[index].image!.isEmpty ? const AssetImage("assets/images/note_img.png") as ImageProvider : NetworkImage(widget.userMusic.smallPlaylist[index].image!),
    //                           // image: NetworkImage(widget.userMusic.smallPlaylist[index].image!),
    //                           fit: BoxFit.cover,
    //                         ),
    //                       ),
    //                       child: ImageContainer,
    //                       // child: Icon(Icons.music_video_sharp, color: Colors.black,),
    //                     ),
    //                     Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         mainAxisAlignment: MainAxisAlignment.center,
    //                         children: [
    //                           SizedBox(
    //                             width: MediaQuery.of(context).size.width - 80,
    //                             child: Text(
    //                               widget.userMusic.smallPlaylist[index].name!.trim(),
    //                               textAlign: TextAlign.left,
    //                               maxLines: 1,
    //                               overflow: TextOverflow.ellipsis,
    //                               style: const TextStyle(fontSize: 16),
    //                             ),
    //                           ),
    //                           SizedBox(
    //                             width: MediaQuery.of(context).size.width - 80,
    //                             child: Text(
    //                               widget.userMusic.smallPlaylist[index].author!.trim(),
    //                               // textAlign: TextAlign.left,
    //                               maxLines: 1,
    //                               overflow: TextOverflow.ellipsis,
    //                               style: const TextStyle(fontSize: 14),
    //                             ),
    //                           )
    //                         ]
    //                     ),
    //                   ],
    //                 )
    //               )
    //             )
    //           ),
    //         );
    //       },
    //     ),
    // );

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 40),
      margin: const EdgeInsets.only(bottom: 40),
      child: StreamBuilder(
        stream: widget.audioHandler.queue,
        builder: (BuildContext context, AsyncSnapshot<List<MediaItem>> snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const CircularProgressIndicator();
          }
          else {
            return ReorderableListView.builder(
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) newIndex--;
                widget.audioHandler.moveQueueItem(oldIndex, newIndex);
              });
            },
            // itemExtent: 50,
            itemCount: snapshot.data!.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              var ImageContainer;
              final playbackState = widget.audioHandler.playbackState;
              final processingState = playbackState.value.processingState;
              final playing = playbackState.value.playing;
              if (widget.audioHandler.playbackState.value.queueIndex == index){
                if (playing == true ) {
                  ImageContainer =  Container(
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.pause, size: 20, color: Colors.white70,)
                  );
                } else {
                  ImageContainer =  const Icon(
                    Icons.play_arrow, size: 20.0, color: Colors.white70,);
                }
              }
              else {
                ImageContainer =  Container();
              }

              return Card(
                key: ValueKey(index),
                // color: index == widget.userMusic.currentIndex ? Colors.grey.shade300 : null,
                color: widget.audioHandler.playbackState.value.queueIndex == index ? Colors.grey.shade300 : null,
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
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  // padding: const EdgeInsets.all(10),
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.purple[100 * (index % 9 + 1)]!,
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                    image: DecorationImage(
                                      image: snapshot.data![index].artUri.toString()!.isEmpty ? const AssetImage("assets/images/note_img.png") as ImageProvider : NetworkImage(snapshot.data![index].artUri.toString()!),
                                      // image: NetworkImage(widget.userMusic.smallPlaylist[index].image!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: ImageContainer,
                                  // child: Icon(Icons.music_video_sharp, color: Colors.black,),
                                ),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width - 80,
                                        child: Text(
                                          snapshot.data![index]!.title,
                                          // widget.userMusic.smallPlaylist[index].name!.trim(),
                                          textAlign: TextAlign.left,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width - 80,
                                        child: Text(
                                          snapshot.data![index].artist!,
                                          // textAlign: TextAlign.left,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      )
                                    ]
                                ),
                              ],
                            )
                        )
                    )
                ),
              );
            },
          );
          }
        },
      ),
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


