// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:test_projects/Music/AudioHandler.dart';
// import 'package:test_projects/Music/music.dart';
// import 'package:test_projects/Network/network.dart';
// import 'package:test_projects/Widgets/MusicBar/CustomMusicBottomBar.dart';
// import 'package:test_projects/main.dart';
// import 'package:test_projects/Provider.dart';
//
// // late void Function(dynamic value) myVoidCallback;
//
// class MusicSilverList extends StatefulWidget{
//
//   final AudioPlayerHandler audioHandler;
//
//   const MusicSilverList(this.audioHandler, {Key? key}) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() => _MusicSilverList();
// }
//
// class _MusicSilverList extends State<MusicSilverList>{
//
//   TextEditingController textController = TextEditingController();
//
//   Load_more() async {
//     if(all_load == true) return true;
//     await parseAllPages();
//     await updateMusicList(getMusic());
//     List<MediaItem> mediaList = [];
//     for(final music in allMusic){
//       mediaList.add(
//           MediaItem(
//             id: '${getLocalIP()}/music?link=${music.link!}',
//             // id: music.link!,
//             // album: "Science Friday",
//             title: music.name!,
//             artist: music.author!,
//             duration: Duration(minutes: int.parse(music.time!.split(':').first), seconds: int.parse(music.time!.split(':').last)),
//             artUri: Uri.parse('https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
//           )
//       );
//     }
//     await widget.audioHandler.updateQueue(mediaList);
//     setState(() {
//       updateMusicList(getMusic());
//     });
//   }
//
//   initState() {         // this is called when the class is initialized or called for the first time
//     super.initState();  //  this is the material super constructor for init state to link your instance initState to the global initState context
//     // Load_more();
//     // myVoidCallback = (value) {
//     //   _runFilter(value);
//     //   updateFilter(value);
//     //   // Добавить функцию закрытия плеера при поиске
//     // };
//   }
//
//   updateFilter(value){
//     setState(() {
//       textController.text = value;
//     });
//   }
//
//   _runFilter(String value) {
//     setState((){
//       if(value.isNotEmpty){
//         findMusic = allMusic.where(
//                 (music) => music.name!.toLowerCase().contains(value.toLowerCase()) ||
//                 music.author!.toLowerCase().contains(value.toLowerCase())
//         ).toList();
//       }
//       else if(value.isEmpty){
//         findMusic = allMusic;
//       }
//     });
//   }
//
//   onTapped(int index){
//     GlobalData.changeModalBottomSheet();
//     // isOpen_ModalBottomSheet = true;
//     if(currentIndex != index) {
//       CurrentPlay(index);
//     }
//     setState(() {
//       if (widget.audioHandler.playbackState.value.playing != true || index != currentIndex) {
//         widget.audioHandler.play();
//         print(widget.audioHandler.mediaItem.value!.id);
//       } else if (widget.audioHandler.playbackState.value.processingState != ProcessingState.completed &&
//           index == currentIndex) {
//         widget.audioHandler.pause();
//       } else {
//         widget.audioHandler.seek(Duration.zero);
//       }
//       // isVisible = true;
//       currentIndex = index;
//     });
//   }
//
//   CurrentPlay(int index) async {
//     await widget.audioHandler.skipToQueueItem(index);
//     await widget.audioHandler.play();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     return CustomScrollView(
//       slivers: [
//         SliverAppBar(
//           pinned: false,
//           floating: true,
//           backgroundColor: Colors.white,
//           actions: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   height: 56,
//                   width: 50,
//                   child: InkWell(
//                     onTap: (){},
//                     child: Icon(Icons.account_circle,color: Colors.black,),
//                   ),
//                 ),
//                 Container(
//                   height: 56,
//                   width: MediaQuery.of(context).size.width - 50,
//                   child: TextField(
//                     controller: textController,
//                     onChanged: (value) => _runFilter(value),
//                     decoration: InputDecoration(
//                       labelText: user_name,
//                       suffixIcon: Icon(Icons.search),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ],
//         ),
//         SliverList(
//           delegate: SliverChildBuilderDelegate(
//             childCount: findMusic.length,
//                 (BuildContext context, int index) {
//               return Card(
//                 // margin: EdgeInsets.all(15),
//                 child: Container(
//                   margin: index == findMusic.length-1 ? const EdgeInsets.only(bottom: 48) : const EdgeInsets.only(bottom: 0),
//                   color: index == currentIndex ? Colors.grey.shade300 : Colors.white,
//                   height: 60,
//                   alignment: Alignment.centerLeft,
//                   child:
//                       InkWell(
//                         onTap: () {
//                           onTapped(index);
//                         },
//                         child: Row(
//                           children: [
//                             Container(
//                               alignment: Alignment.center,
//                               decoration: BoxDecoration(
//                                 color: Colors.purple[100 * (index % 9 + 1)]!,
//                                 borderRadius: BorderRadius.all(Radius.circular(10))
//                               ),
//                               margin: EdgeInsets.symmetric(horizontal: 5),
//                               // padding: EdgeInsets.all(10),
//                               width: 45,
//                               height: 45,
//                                 child: StreamBuilder<PlaybackState>(
//                                   stream: widget.audioHandler.playbackState,
//                                   builder: (context, snapshot) {
//                                     final playbackState = snapshot.data;
//                                     final processingState = playbackState?.processingState;
//                                     final playing = playbackState?.playing;
//                                     if ((processingState == AudioProcessingState.loading ||
//                                         processingState == AudioProcessingState.buffering) &&
//                                         (findMusic[index].name == widget.audioHandler.mediaItem.value!.title ||
//                                             findMusic[index].author == widget.audioHandler.mediaItem.value!.artist)){
//                                       return Container(
//                                         // margin: const EdgeInsets.all(8.0),
//                                         width: 30.0,
//                                         height: 30.0,
//                                         child: const CircularProgressIndicator(color: Colors.white70,),
//                                       );
//                                     } else if (playing == true &&
//                                         (findMusic[index].name == widget.audioHandler.mediaItem.value!.title ||
//                                             findMusic[index].author == widget.audioHandler.mediaItem.value!.artist)) {
//                                       return Container(
//                                         width: 30.0,
//                                         height: 30.0,
//                                         alignment: Alignment.center,
//                                         child: Icon(Icons.pause, size: 30, color: Colors.white70,)
//                                       );
//                                     } else if (index == currentIndex) {
//                                       return Icon(Icons.play_arrow, size: 30.0, color: Colors.white70,);
//                                     }
//                                     else return Container();
//                                   },
//                                 )
//                               // child: Icon(Icons.music_video_sharp, color: Colors.black,),
//                             ),
//                             SizedBox(
//                               width: MediaQuery.of(context).size.width - 70,
//                               child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       findMusic[index].name!.trim(),
//                                       textAlign: TextAlign.left,
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(fontSize: 18),
//                                     ),
//                                     Text(
//                                       findMusic[index].author!,
//                                       // textAlign: TextAlign.left,
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(fontSize: 14),
//                                     ),
//                                   ]
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

//
// class CustomSearchDelegate extends SearchDelegate {
//
//   late List<Music> users_songs;
//   List<String?> nameSongs = allMusic.map((song) => song.name!.toLowerCase()).toList();
//   List<String?> authorSongs = allMusic.map((song) => song.author!.toLowerCase()).toList();
//
//   CustomSearchDelegate(music){
//     users_songs = music;
//   }
//
//   @override
//   List<Widget>? buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       )
//     ];
//   }
//
//   @override
//   Widget? buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//   }
//
//   @override
//   Widget buildResults(BuildContext context) {
//     List<Music> matchQuery = [];
//     for(var music in users_songs){
//       if(music.name!.toLowerCase().contains(query.toLowerCase()) || music.author!.toLowerCase().contains(query.toLowerCase())){
//         matchQuery.add(music);
//       }
//     }
//     return ListView.builder(
//         itemCount: matchQuery.length,
//         itemBuilder: (context, index) {
//           var result = matchQuery[index].name;
//           return ListTile(
//             title: Text(result!),
//           );
//         }
//     );
//   }
//
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     List<Music> matchQuery = [];
//     for(var music in users_songs){
//       if(music.name!.toLowerCase().contains(query.toLowerCase()) || music.author!.toLowerCase().contains(query.toLowerCase())){
//         matchQuery.add(music);
//       }
//     }
//     return ListView.builder(
//         itemCount: matchQuery.length,
//         itemBuilder: (context, index) {
//           var result = matchQuery[index].name;
//           return ListTile(
//             title: Text(result!),
//           );
//         }
//     );
//   }
//
// }