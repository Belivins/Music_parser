import 'package:just_audio/just_audio.dart';
import 'package:test_projects/Music/AudioHandler.dart';
import 'package:test_projects/Network/MusicBox.dart';
import 'package:test_projects/Widgets/Old/network.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:test_projects/Widgets/MusicBar/MusicBottomBar.dart';
import 'package:test_projects/main.dart';

class MusicScreen extends StatefulWidget{

  final AudioPlayerHandler audioHandler;
  final MusicBox userMusic;
  final bool fromSavedMusic;

  const MusicScreen({Key? key,required this.audioHandler, required this.userMusic, required this.fromSavedMusic}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MusicScreen();
}

class _MusicScreen extends State<MusicScreen>{

  final TextEditingController textController = TextEditingController();
  late void Function(dynamic value) func_updateFilter;
  late void Function(dynamic value) func_smallPlaylist;
  List<MediaItem> newMediaList = [];

  Load_more()  async {
    while (true){
      List<MediaItem> moreMedia = await widget.userMusic.pumpage();
      if(moreMedia.isNotEmpty){
        print(widget.userMusic.mediaList.length);
        setState(() {
          widget.audioHandler.addQueueItems(moreMedia);
        });
      }
      else break;
      // await Future.delayed(const Duration(seconds: 3));
    }
    print('Загрузка завершена');
  }

  @override
  initState() {
    super.initState();
    if(!widget.fromSavedMusic) Load_more();
    func_updateFilter = (value) {
      _runFilter(value);
      updateFilter(value);
      // Добавить функцию закрытия плеера при поиске
    };
  }

  updateFilter(value){
    setState(() {
      textController.text = value;
    });
  }

  _runFilter(String value) async {
    setState((){
      if(value.isNotEmpty){
        widget.userMusic.findMusic = widget.userMusic.allMusic.where(
                (music) => music.name!.toLowerCase().contains(value.toLowerCase()) ||
                music.author!.toLowerCase().contains(value.toLowerCase())
        ).toList();

      }
      else if(value.isEmpty){
        widget.userMusic.findMusic = widget.userMusic.allMusic;
        // widget.userMusic.smallPlaylist = widget.userMusic.findMusic.sublist(0,widget.userMusic.findMusic.length >= 100 ? 100 : widget.userMusic.findMusic.length -1);
        // newMediaList = widget.userMusic.fillMediaList(widget.userMusic.findMusic);
      }
    });
    newMediaList = await widget.userMusic.fillMediaList(widget.userMusic.findMusic);
  }

  onTapped(int index){
    if(widget.userMusic.currentIndex != index) {
      widget.userMusic.currentIndex = index;
      choisePlay(index);
    }
    setState(() {
      if (widget.audioHandler.playbackState.value.playing != true || index != widget.userMusic.currentIndex) {
        widget.audioHandler.play();
        // print(widget.audioHandler.mediaItem.value!.id);
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

  choisePlay(int index) async {
    if(newMediaList.isNotEmpty) await widget.audioHandler.updateQueue(newMediaList);
    await widget.audioHandler.skipToQueueItem(index);
    await widget.audioHandler.play();
  }

  @override
  Widget build(BuildContext context) {

    return Listener(
      onPointerDown: (PointerDownEvent event) => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: false,
                  floating: true,
                  backgroundColor: Colors.white,
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 56,
                          width: 50,
                          child: InkWell(
                            onTap: (){},
                            child: const Icon(Icons.account_circle,color: Colors.black,),
                          ),
                        ),
                        Container(
                          height: 56,
                          width: MediaQuery.of(context).size.width - 50,
                          child: TextField(
                            controller: textController,
                            onChanged: (value) => _runFilter(value),
                            decoration: InputDecoration(
                              labelText: widget.userMusic.user_name,
                              suffixIcon: const Icon(Icons.search),

                              // suffixIcon: textController.text.isEmpty ? const Icon(Icons.search)
                              //     : IconButton(icon: const Icon(Icons.clear, color: Colors.red,), onPressed: () async {
                              //         textController.clear();
                              //         widget.userMusic.findMusic = widget.userMusic.allMusic;
                              //         newMediaList = await widget.userMusic.fillMediaList(widget.userMusic.findMusic);
                              //       },
                              // ) ,

                              // prefixIcon: Icon(
                              //   Icons.account_box,
                              //   size: 28.0,
                              // ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: widget.userMusic.findMusic.length,
                        (BuildContext context, int index) {

                      return StreamBuilder<PlaybackState>(
                          stream: widget.audioHandler.playbackState,
                          builder: (context, snapshot) {
                            StatelessWidget ImageContainer;
                            final playbackState = snapshot.data;
                            final processingState = playbackState?.processingState;
                            final playing = playbackState?.playing;
                            if (widget.audioHandler.mediaItem.value?.id == widget.userMusic.findMusic[index].link
                                && widget.userMusic.currentIndex == index){
                              if (processingState == AudioProcessingState.loading ||
                                  processingState == AudioProcessingState.buffering) {
                                ImageContainer = Container(
                                  alignment: Alignment.center,
                                  width: 30.0,
                                  height: 30.0,
                                  child: const CircularProgressIndicator(color: Colors.white70,),
                                );
                              } else if (playing == true ) {
                                ImageContainer =  Container(
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.pause, size: 45, color: Colors.white70,)
                                );
                              } else {
                                ImageContainer =  const Icon(
                                  Icons.play_arrow, size: 45.0, color: Colors.white70,);
                              }
                            }
                            else {
                              ImageContainer =  Container();
                            }

                            return Container(
                                margin: index == widget.userMusic.findMusic.length-1 ? (widget.userMusic.currentIndex != -1 ? const EdgeInsets.only(bottom: 100) : const EdgeInsets.only(bottom: 50)) : const EdgeInsets.only(bottom: 0),
                                color: (widget.audioHandler.mediaItem.value?.id == widget.userMusic.findMusic[index].link
                                    && widget.userMusic.currentIndex == index) ? Colors.grey.shade300 : Colors.white,
                                height: 60,
                                alignment: Alignment.centerLeft,
                                child:
                                InkWell(
                                  onTap: () {
                                    onTapped(index);
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          // color: Colors.purple[100 * (index % 9 + 1)]!,
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          image: DecorationImage(
                                            image: widget.userMusic.findMusic[index].image!.isEmpty ? const AssetImage("assets/images/note_img.png") as ImageProvider : NetworkImage(widget.userMusic.findMusic[index].image!),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        margin: const EdgeInsets.symmetric(horizontal: 5),
                                        // padding: EdgeInsets.all(10),
                                        width: 45,
                                        height: 45,
                                        child: ImageContainer,
                                        // child: Icon(Icons.music_video_sharp, color: Colors.black,),
                                      ),


                                      SizedBox(
                                        width: MediaQuery.of(context).size.width - 90,
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                widget.userMusic.findMusic[index].name!.trim(),
                                                textAlign: TextAlign.left,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 18),
                                              ),
                                              Text(
                                                widget.userMusic.findMusic[index].author!,
                                                // textAlign: TextAlign.left,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ]
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.only(right: 10),
                                        width: 25,
                                        child: Text(
                                          '${int.parse(widget.userMusic.findMusic[index].time!) ~/ 60}:${int.parse(widget.userMusic.findMusic[index].time!) % 60}',
                                          // textAlign: TextAlign.left,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                            );
                          }
                      );
                    },
                  ),
                ),
              ],
            ),
            // MusicSilverList(audioHandler),
            MusicBottomBar(userMusic: widget.userMusic, audioHandler: widget.audioHandler, updateMusicList: func_updateFilter,/* updateSmallPlaylist: func_smallPlaylist,*/),
          ],
        ),
      ),
    );

//     return Scaffold(
//         resizeToAvoidBottomInset: false,
//         body: Stack(
//           children: [
//             CustomScrollView(
//               slivers: [
//                 SliverAppBar(
//                   pinned: false,
//                   floating: true,
//                   backgroundColor: Colors.white,
//                   actions: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(
//                           height: 56,
//                           width: 50,
//                           child: InkWell(
//                             onTap: (){},
//                             child: const Icon(Icons.account_circle,color: Colors.black,),
//                           ),
//                         ),
//                         Container(
//                           height: 56,
//                           width: MediaQuery.of(context).size.width - 50,
//                           child: TextField(
//                             controller: textController,
//                             onChanged: (value) => _runFilter(value),
//                             decoration: InputDecoration(
//                               labelText: widget.userMusic.user_name,
//                               suffixIcon: const Icon(Icons.search),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//                 SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     childCount: widget.userMusic.findMusic.length,
//                         (BuildContext context, int index) {
//
//                       return StreamBuilder<PlaybackState>(
//                           stream: widget.audioHandler.playbackState,
//                           builder: (context, snapshot) {
//                             var ImageContainer;
//                             final playbackState = snapshot.data;
//                             final processingState = playbackState?.processingState;
//                             final playing = playbackState?.playing;
//                             if (widget.audioHandler.mediaItem.value?.id == widget.userMusic.findMusic[index].link){
//                               if (processingState == AudioProcessingState.loading ||
//                                   processingState == AudioProcessingState.buffering) {
//                                 ImageContainer = Container(
//                                   width: 30.0,
//                                   height: 30.0,
//                                   child: const CircularProgressIndicator(color: Colors.white70,),
//                                 );
//                               } else if (playing == true ) {
//                                 ImageContainer =  Container(
//                                     alignment: Alignment.center,
//                                     child: const Icon(
//                                       Icons.pause, size: 45, color: Colors.white70,)
//                                 );
//                               } else {
//                                 ImageContainer =  const Icon(
//                                   Icons.play_arrow, size: 45.0, color: Colors.white70,);
//                               }
//                             }
//                             else {
//                               ImageContainer =  Container();
//                             }
//
//                             return Container(
//                                 margin: index == widget.userMusic.findMusic.length-1 ? const EdgeInsets.only(bottom: 48) : const EdgeInsets.only(bottom: 0),
//                                 color: widget.audioHandler.mediaItem.value?.id == widget.userMusic.findMusic[index].link ? Colors.grey.shade300 : Colors.white,
//                                 height: 60,
//                                 alignment: Alignment.centerLeft,
//                                 child:
//                                 InkWell(
//                                   onTap: () {
//                                     onTapped(index);
//                                   },
//                                   child: Row(
//                                     children: [
//                                       Container(
//                                         alignment: Alignment.center,
//                                         decoration: BoxDecoration(
//                                           // color: Colors.purple[100 * (index % 9 + 1)]!,
//                                           borderRadius: const BorderRadius.all(Radius.circular(10)),
//                                           image: DecorationImage(
//                                             image: widget.userMusic.findMusic[index].image!.isEmpty ? const AssetImage("assets/images/note_img.png") as ImageProvider : NetworkImage(widget.userMusic.findMusic[index].image!),
//                                             fit: BoxFit.cover,
//                                           ),
//                                         ),
//                                         margin: const EdgeInsets.symmetric(horizontal: 5),
//                                         // padding: EdgeInsets.all(10),
//                                         width: 45,
//                                         height: 45,
//                                         child: ImageContainer,
//                                         // child: Icon(Icons.music_video_sharp, color: Colors.black,),
//                                       ),
//
//
//                                       SizedBox(
//                                         width: MediaQuery.of(context).size.width - 90,
//                                         child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             mainAxisAlignment: MainAxisAlignment.center,
//                                             children: [
//                                               Text(
//                                                 widget.userMusic.findMusic[index].name!.trim(),
//                                                 textAlign: TextAlign.left,
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                                 style: const TextStyle(fontSize: 18),
//                                               ),
//                                               Text(
//                                                 widget.userMusic.findMusic[index].author!,
//                                                 // textAlign: TextAlign.left,
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                                 style: const TextStyle(fontSize: 14),
//                                               ),
//                                             ]
//                                         ),
//                                       ),
//                                       Container(
//                                         alignment: Alignment.center,
//                                         margin: EdgeInsets.only(right: 10),
//                                         width: 25,
//                                         child: Text(
//                                           '${int.parse(widget.userMusic.findMusic[index].time!) ~/ 60}:${int.parse(widget.userMusic.findMusic[index].time!) % 60}',
//                                           // textAlign: TextAlign.left,
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                           style: const TextStyle(fontSize: 10, color: Colors.grey),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 )
//                             );
//                           }
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             // MusicSilverList(audioHandler),
//             MusicBottomBar(myVoidCallback, userMusic: widget.userMusic, audioHandler: widget.audioHandler),
//           ],
//         ),
//       );
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