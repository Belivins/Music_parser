import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test_projects/Music/AudioHandler.dart';
import 'package:test_projects/Music/music.dart';
import 'package:test_projects/Pages/MainScreen.dart';
import 'package:test_projects/Widgets/CustomSliverList.dart';
import 'package:test_projects/Widgets/MusicBar/ControlButtons.dart';
import 'package:test_projects/Widgets/MusicBar/CustomSeekBar.dart';
import 'package:test_projects/Widgets/ShowModalBottomSheet.dart';
import 'package:test_projects/main.dart';

bool isOpen_ModalBottomSheet = false;
bool isOpen_BottomBar = true;

class MusicBottomBar extends StatefulWidget{

  final AudioPlayerHandler audioHandler;

  const MusicBottomBar(this.audioHandler, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MusicBottomBar();
}

class _MusicBottomBar extends State<MusicBottomBar> {

  void _showModalBottomSheet() {
    setState(() {
      // isOpen_ModalBottomSheet = (currentIndex == -1) ? true : false;
      isOpen_ModalBottomSheet = !isOpen_ModalBottomSheet;
      isOpen_BottomBar = !isOpen_BottomBar;
    });

    // showModalBottomSheet<void>();
    Future<void> future = showModalBottomSheet<void>(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return CustomModalBottomSheet(widget.audioHandler);
        }
    );
    future.then((void value) => setState(() {
      isOpen_ModalBottomSheet = !isOpen_ModalBottomSheet;
      isOpen_BottomBar = !isOpen_BottomBar;
    }));
  }


  @override
  Widget build(BuildContext context) {
      return Positioned(
        bottom: 0,
        child: Column(
          children: [
            StreamBuilder<QueueState>(
              stream: widget.audioHandler.queueState,
              builder: (context, snapshot) {
                final queueState = snapshot.data ?? QueueState.empty;
                return         Visibility(
                    visible: isOpen_ModalBottomSheet,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white12.withOpacity(0.9),
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey.withOpacity(0.9),
                            width: 1,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      // height: 100,
                      child: InkWell(
                        onTap: () {
                          _showModalBottomSheet();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StreamBuilder<PlaybackState>(
                              stream: widget.audioHandler.playbackState,
                              builder: (context, snapshot) {
                                final playbackState = snapshot.data;
                                final processingState = playbackState?.processingState;
                                final playing = playbackState?.playing;
                                if (processingState == AudioProcessingState.loading ||
                                    processingState == AudioProcessingState.buffering) {
                                  return Container(
                                    margin: const EdgeInsets.all(8.0),
                                    width: 32.0,
                                    height: 32.0,
                                    child: const CircularProgressIndicator(),
                                  );
                                } else if (playing != true) {
                                  return IconButton(
                                    icon: const Icon(Icons.play_arrow),
                                    iconSize: 32.0,
                                    onPressed: widget.audioHandler.play,
                                  );
                                } else {
                                  return IconButton(
                                    icon: const Icon(Icons.pause),
                                    iconSize: 32.0,
                                    onPressed: widget.audioHandler.pause,
                                  );
                                }
                              },
                            ),
                            StreamBuilder<QueueState>(
                              stream: widget.audioHandler.queueState,
                              builder: (context, snapshot) {
                                return SizedBox(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width - 96,
                                  child: OverflowBox(
                                    maxHeight: 50,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(widget.audioHandler.mediaItem.value?.title ?? 'Not found', overflow: TextOverflow.visible, style: TextStyle(fontSize: 14), textAlign: TextAlign.center,),
                                        Text(widget.audioHandler.mediaItem.value?.artist ?? 'Not found', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  )
                                );
                              },
                            ),
                            IconButton(
                                onPressed:() {
                                  setState(() {
                                    isOpen_ModalBottomSheet = false;
                                    widget.audioHandler.stop();
                                    widget.audioHandler.seek(Duration.zero);
                                    currentIndex = -1;
                                    // myVoidCallback('');
                                  });
                                },
                                iconSize: 32.0,
                                icon: Icon(Icons.close)
                            ),
                          ],
                        ),
                      ),
                    )
                );
              },
            ),
            Visibility(
              visible: isOpen_BottomBar,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, 0.1, 0.9, 1],
                      colors: [
                        Colors.grey.withOpacity(1),
                        Colors.white10.withOpacity(1),
                        Colors.white10.withOpacity(1),
                        Colors.grey.withOpacity(1),
                      ],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width / 2,
                      child: InkWell(
                        onTap: () {
                          if (CurrentPage != 1) {
                            CurrentPage = 1;
                            Navigator.pushReplacementNamed(context, "audio list");
                          }
                        },
                        child: Icon(Icons.queue_music,)
                      ),
                    ),
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width / 2,
                      child: InkWell(
                        onTap: (){
                          if (CurrentPage != 2) {
                            CurrentPage = 2;
                            Navigator.pushReplacementNamed(context, "albums list");
                          }
                        },
                        child: Icon(Icons.library_music_rounded),
                      ),
                    )
                  ],
                ),
              )
            )
          ],
        )
      );
  }
}
//
// class SmallMusicBottomBar extends StatelessWidget {
//   final AudioPlayerHandler audioHandler;
//
//   const SmallMusicBottomBar(this.audioHandler, {Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         StreamBuilder<PlaybackState>(
//           stream: audioHandler.playbackState,
//           builder: (context, snapshot) {
//             final playbackState = snapshot.data;
//             final processingState = playbackState?.processingState;
//             final playing = playbackState?.playing;
//             if (processingState == AudioProcessingState.loading ||
//                 processingState == AudioProcessingState.buffering) {
//               return Container(
//                 margin: const EdgeInsets.all(8.0),
//                 width: 32.0,
//                 height: 32.0,
//                 child: const CircularProgressIndicator(),
//               );
//             } else if (playing != true) {
//               return IconButton(
//                 icon: const Icon(Icons.play_arrow),
//                 iconSize: 32.0,
//                 onPressed: audioHandler.play,
//               );
//             } else {
//               return IconButton(
//                 icon: const Icon(Icons.pause),
//                 iconSize: 32.0,
//                 onPressed: audioHandler.pause,
//               );
//             }
//           },
//         ),
//         StreamBuilder<QueueState>(
//           stream: audioHandler.queueState,
//           builder: (context, snapshot) {
//             final queueState = snapshot.data ?? QueueState.empty;
//             return Container(
//               height: MediaQuery.of(context).size.height,
//               width: MediaQuery.of(context).size.width - 96,
//               alignment: Alignment.center,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(audioHandler.mediaItem.value?.title ?? 'Not found', textAlign: TextAlign.center,),
//                   Text(audioHandler.mediaItem.value?.artist ?? 'Not found'),
//                 ],
//               ),
//             );
//           },
//         ),
//         IconButton(
//             onPressed:() {
//               isOpen_ModalBottomSheet = false;
//               print('close');
//             },
//             iconSize: 32.0,
//             icon: Icon(Icons.close)
//         ),
//       ],
//     );
//   }
// }

// child: PageView(
//   children: [
//     Container(
//       // height: MediaQuery.of(context).size.height,
//       // width: MediaQuery.of(context).size.height,
//       child: Column(
//         children: [
//           Container(
//             height: MediaQuery.of(context).size.height / 2 - 180,
//             width: MediaQuery.of(context).size.height / 2,
//             margin: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
//             color: Colors.blue.withOpacity(0.8),
//           ),
//           Container(
//             alignment: Alignment.bottomCenter,
//             height: 40,
//             width:  400,
//             child: StreamBuilder<PositionData>(
//               stream: _positionDataStream,
//               builder: (context1, snapshot1) {
//                 final positionData = snapshot1.data;
//                 return SeekBar(
//                   duration: positionData?.duration ?? Duration.zero,
//                   position: positionData?.position ?? Duration.zero,
//                   bufferedPosition:
//                   positionData?.bufferedPosition ?? Duration.zero,
//                   onChangeEnd: widget.audioHandler.seek,
//                 );
//               },
//             ),
//           ),
//           Container(
//            child: Text(widget.audioHandler.mediaItem.value!.title),
//           ),
//           Container(
//             child: Text(widget.audioHandler.mediaItem.value!.artist!),
//           ),
//           ControlButtons(widget.audioHandler),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Icon(Icons.circle, size: 7,),
//               Icon(Icons.list, size: 14,),
//             ],
//           ),
//         ],
//       ),
//     ),
//     Container(),
//   ],
// ),
// child
//
//
//
//                     //
//                     // Container(
//                     //   child: StreamBuilder<QueueState>(
//                     //     stream: streamMusicList,
//                     //     builder: (context, snapshot2) {
//                     //       final queueState = snapshot2.data ?? QueueState.empty;
//                     //       final queue = queueState.queue;
//                     //       // pageController.
//                     //       return ReorderableListView.builder(
//                     //         onReorder: (int oldIndex, int newIndex) {
//                     //           // setState(() {
//                     //           if (oldIndex < newIndex) newIndex--;
//                     //           widget.audioHandler.moveQueueItem(oldIndex, newIndex);
//                     //
//                     //           // });
//                     //         },
//                     //         itemCount: queue.length,
//                     //         itemBuilder: (BuildContext context, int index) {
//                     //           return Card(
//                     //             // key: ValueKey(queue[index].title),
//                     //             key: ValueKey(index),
//                     //             color: index == queueState.queueIndex
//                     //                 ? Colors.grey.shade300
//                     //                 : null,
//                     //             child:
//                     //             ListTile(
//                     //               title: Text(queue[index].title),
//                     //               // onTap: () => CurrentPlay(index),
//                     //               // onTap: () => _audioHandler.skipToQueueItem(index),
//                     //             ),
//                     //           );
//                     //         },
//                     //       );
//                     //     },
//                     //   ),
//                     // ),
//                     // Container(
//                     //   child: StreamBuilder<QueueState>(
//                     //     stream: widget.audioHandler.queueState.asBroadcastStream(),
//                     //     builder: (context, snapshot) {
//                     //       final queueState = snapshot.data ?? QueueState.empty;
//                     //       final queue = queueState.queue;
//                     //       // return ReorderableListView(
//                     //       //   onReorder: (int oldIndex, int newIndex) {
//                     //       //     if (oldIndex < newIndex) newIndex--;
//                     //       //     widget.audioHandler.moveQueueItem(oldIndex, newIndex);
//                     //       //   },
//                     //       //   children: [
//                     //       //     for (var i = 0; i < queue.length; i++)
//                     //       //       Dismissible(
//                     //       //         key: ValueKey(i),
//                     //       //         background: Container(
//                     //       //           color: Colors.redAccent,
//                     //       //           alignment: Alignment.centerRight,
//                     //       //           child: const Padding(
//                     //       //             padding: EdgeInsets.only(right: 8.0),
//                     //       //             child: Icon(Icons.delete, color: Colors.white),
//                     //       //           ),
//                     //       //         ),
//                     //       //         onDismissed: (dismissDirection) {
//                     //       //           setState(() {
//                     //       //             widget.audioHandler.removeQueueItemAt(i);
//                     //       //           });
//                     //       //           // widget.audioHandler.removeQueueItemAt(i);
//                     //       //         },
//                     //       //         child: Card(
//                     //       //           color: i == queueState.queueIndex
//                     //       //               ? Colors.grey.shade300
//                     //       //               : null,
//                     //       //           child: ListTile(
//                     //       //             title: Text(queue[i].title),
//                     //       //             onTap: () => widget.audioHandler.skipToQueueItem(i),
//                     //       //           ),
//                     //       //         ),
//                     //       //       ),
//                     //       //   ],
//                     //       // );
//                     //       return ReorderableListView.builder(
//                     //         onReorder: (int oldIndex, int newIndex) {
//                     //           // setState(() {
//                     //           if (oldIndex < newIndex) newIndex--;
//                     //           widget.audioHandler.moveQueueItem(oldIndex, newIndex);
//                     //           // });
//                     //         },
//                     //         itemCount: queue.length,
//                     //         itemBuilder: (BuildContext context, int index) {
//                     //           return Card(
//                     //             // key: ValueKey(queue[index].title),
//                     //             key: ValueKey(index),
//                     //             color: index == queueState.queueIndex
//                     //                 ? Colors.grey.shade300
//                     //                 : null,
//                     //             child:
//                     //             ListTile(
//                     //               title: Text(queue[index].title),
//                     //               // onTap: () => CurrentPlay(index),
//                     //               // onTap: () => _audioHandler.skipToQueueItem(index),
//                     //             ),
//                     //           );
//                     //         },
//                     //       );
//                     //     },
//                     //   ),
//                     // ),