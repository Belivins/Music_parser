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

  const MusicScreen({Key? key,required this.audioHandler, required this.userMusic}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MusicScreen();
}

class _MusicScreen extends State<MusicScreen>{

  final TextEditingController textController = TextEditingController();
  late void Function(dynamic value) myVoidCallback;

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
    }
    print('Загрузка завершена');
  }

  initState() {
    super.initState();
    Load_more();
    myVoidCallback = (value) {
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

  _runFilter(String value) {
    setState((){
      if(value.isNotEmpty){
        widget.userMusic.findMusic = widget.userMusic.allMusic.where(
                (music) => music.name!.toLowerCase().contains(value.toLowerCase()) ||
                music.author!.toLowerCase().contains(value.toLowerCase())
        ).toList();
      }
      else if(value.isEmpty){
        widget.userMusic.findMusic = widget.userMusic.allMusic;
      }
    });
  }

  onTapped(int index){
    if(widget.userMusic.currentIndex != index) {
      CurrentPlay(index);
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

  CurrentPlay(int index) async {
    await widget.audioHandler.skipToQueueItem(index);
    await widget.audioHandler.play();
  }

  @override
  Widget build(BuildContext context) {

    update(new_index){
      setState(() {
        widget.userMusic.currentIndex = new_index;
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          CustomScrollView(
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
                          labelText: widget.userMusic.currentUser.userName,
                          suffixIcon: const Icon(Icons.search),
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
                  return Container(
                      margin: index == widget.userMusic.findMusic.length-1 ? const EdgeInsets.only(bottom: 48) : const EdgeInsets.only(bottom: 0),
                      color: index == widget.userMusic.currentIndex ? Colors.grey.shade300 : Colors.white,
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
                                child: StreamBuilder<PlaybackState>(
                                  stream: widget.audioHandler.playbackState,
                                  builder: (context, snapshot) {
                                    final playbackState = snapshot.data;
                                    final processingState = playbackState?.processingState;
                                    final playing = playbackState?.playing;
                                    if ((processingState == AudioProcessingState.loading ||
                                        processingState == AudioProcessingState.buffering) &&
                                        (widget.userMusic.findMusic[index].name == widget.audioHandler.mediaItem.value!.title &&
                                            widget.userMusic.findMusic[index].author == widget.audioHandler.mediaItem.value!.artist)){
                                      widget.userMusic.currentIndex = index;
                                      return Container(
                                        // margin: const EdgeInsets.all(8.0),
                                        width: 30.0,
                                        height: 30.0,
                                        child: const CircularProgressIndicator(color: Colors.white70,),
                                      );
                                    } else if (playing == true &&
                                        (widget.userMusic.findMusic[index].name == widget.audioHandler.mediaItem.value!.title &&
                                            widget.userMusic.findMusic[index].author == widget.audioHandler.mediaItem.value!.artist)) {
                                      return Container(
                                          // width: 45.0,
                                          // height: 45.0,
                                          alignment: Alignment.center,
                                          child: const Icon(Icons.pause, size: 45, color: Colors.white70,)
                                      );
                                    } else if (index == widget.userMusic.currentIndex) {
                                      return const Icon(Icons.play_arrow, size: 45.0, color: Colors.white70,);
                                    }
                                    else return Container();
                                  },
                                )
                              // child: Icon(Icons.music_video_sharp, color: Colors.black,),
                            ),


                            SizedBox(
                              width: MediaQuery.of(context).size.width - 70,
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
                          ],
                        ),
                      )
                  );
                },
              ),
            ),
          ],
        ),
          // MusicSilverList(audioHandler),
          // MusicBottomBar(myVoidCallback, userMusic: widget.userMusic, audioHandler: widget.audioHandler),
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