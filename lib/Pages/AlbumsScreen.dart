import 'package:flutter/material.dart';
import 'package:test_projects/Network/MusicBox.dart';
import 'package:test_projects/Widgets/AlbumsPages/AlbumsMusicList.dart';
import 'package:test_projects/Widgets/Animation/Routes/ScaleRoute.dart';
import 'package:test_projects/Widgets/MusicBar/MusicBottomBar.dart';
import 'package:test_projects/main.dart';

import '../Music/AudioHandler.dart';
import '../Widgets/Old/AlbumsSilverList.dart';

class AlbumScreen extends StatefulWidget{

  final AudioPlayerHandler audioHandler;
  final MusicBox userMusic;

  const AlbumScreen({Key? key, required this.userMusic, required this.audioHandler}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AlbumScreen();
}

class _AlbumScreen extends State<AlbumScreen>{

  late void Function(dynamic value) func_updateFilter;
  // late void Function(dynamic value) func_smallPlaylist;

  initState() {         // this is called when the class is initialized or called for the first time
    super.initState();  //  this is the material super constructor for init state to link your instance initState to the global initState context
    // Load_more();
    func_updateFilter = (value) {
      // _runFilter(value);
      // updateFilter(value);
      // Добавить функцию закрытия плеера при поиске
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color.fromARGB(255, 206, 203, 203),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // CustomSilverList(audioHandler),
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
                          // controller: textController,
                          // onChanged: (value) => _runFilter(value),
                          decoration: InputDecoration(
                            labelText: widget.userMusic.user_name,
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
                  childCount: widget.userMusic.allMusic.length ~/ 20,
                  (BuildContext context, int index) {
                    return InkWell(
                      onTap: (){
                        CurrentPage = -1;
                        Navigator.push(context, ScaleRoute(page: AlbumMusicList(audioHandler: widget.audioHandler, userMusic: widget.userMusic, startIndex: 20 * index,)));
                      },
                      child: Container(
                        margin: index == widget.userMusic.allMusic.length ~/ 20-1 ? const EdgeInsets.only(bottom: 55, left: 5, right: 5, top: 5) : const EdgeInsets.only(bottom: 5, left: 5, right: 5, top: 5),
                        padding: const EdgeInsets.all(10),
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 2,
                              offset: Offset(0,2), // Shadow position
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 240,
                              decoration: BoxDecoration(
                                color: Colors.purple[100 * (index % 9 + 1)]!,
                                borderRadius: const BorderRadius.all(Radius.circular(30)),
                                image: DecorationImage(
                                  image: NetworkImage(widget.userMusic.allMusic[index * 20].image!),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: null,
                              ),
                            ),
                            SizedBox(
                              child: Text(
                                widget.userMusic.findMusic[index].name!.trim(),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            SizedBox(
                              child: Text(
                                widget.userMusic.findMusic[index].author!.trim(),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                    return Container(
                      margin: index == 10-1 ? const EdgeInsets.only(bottom: 55) : const EdgeInsets.only(bottom: 5),
                      // padding: const EdgeInsets.only(bottom: 550),
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.purple[100 * (index % 9 + 1)]!,
                        borderRadius: const BorderRadius.all(Radius.circular(30)),
                        image: DecorationImage(
                          image: NetworkImage(widget.userMusic.allMusic[index * 10].image!),
                          fit: BoxFit.cover,
                        ),
                      ),

                      child: InkWell(
                        onTap: (){
                          Navigator.push(context, ScaleRoute(page: AlbumMusicList(audioHandler: widget.audioHandler, userMusic: widget.userMusic, startIndex: 10 * index,)));
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          MusicBottomBar(userMusic: widget.userMusic, audioHandler: widget.audioHandler, updateMusicList: func_updateFilter,/* updateSmallPlaylist: func_smallPlaylist,*/),
        ],
      ),
    );
  }
}