import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_projects/Music/AudioHandler.dart';
import 'package:test_projects/Network/MusicBox.dart';
import 'package:test_projects/Widgets/AlbumsPages/AlbumsMusicList.dart';
import 'package:test_projects/Widgets/Animation/Routes/ScaleRoute.dart';

class AlbumsSilverList extends StatefulWidget{

  final AudioPlayerHandler audioHandler;
  final void Function(dynamic value) updateAlbumsList;
  final MusicBox userMusic;

  const AlbumsSilverList({Key? key, required this.userMusic, required this.updateAlbumsList,required this.audioHandler}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AlbumsSilverList();
}

class _AlbumsSilverList extends State<AlbumsSilverList> {

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
            childCount: 10,
              (BuildContext context, int index) {
                return Container(
                  margin: const EdgeInsets.all(5),
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.purple[100 * (index % 9 + 1)]!,
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    // image: DecorationImage(
                    //   image: NetworkImage(widget.userMusic.findMusic[index].image!),
                    //   fit: BoxFit.cover,
                    // ),
                  ),

                  child: InkWell(
                    onTap: (){
                      // Navigator.push(context, ScaleRoute(page: AlbumMusicList(audioHandler: widget.audioHandler, userMusic: widget.userMusic, startIndex:  ,)));
                    },
                  ),
                );
            },
          ),
        ),
      ],
    );
  }
}