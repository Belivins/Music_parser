import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:test_projects/Music/AudioHandler.dart';
import 'package:test_projects/Network/MusicBox.dart';
import 'package:test_projects/Widgets/MusicBar/MusicBottomBar.dart';

class AlbumMusicList extends StatefulWidget{

  final AudioPlayerHandler audioHandler;
  final MusicBox userMusic;
  final int startIndex;

  const AlbumMusicList({Key? key, required this.userMusic, required this.audioHandler, required this.startIndex}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AlbumMusicList();
}

class _AlbumMusicList extends State<AlbumMusicList>{

  late void Function(dynamic value) func_updateFilter;
  // late void Function(dynamic value) func_smallPlaylist;
  // late void Function(dynamic value) myVoidCallback;
  late ScrollController _scrollController;
  double _AppBarPadding = 0;
//----------
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    func_updateFilter = (value) {};
    // _scrollController = ScrollController();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _AppBarPadding = _isSliverAppBarExpanded ? 50 : 0;
        });
      });
  }
//----------
  bool get _isSliverAppBarExpanded {
    // print('AppBar conection');
    return _scrollController.hasClients &&
        _scrollController.offset > (200 - kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black,),
                  onPressed: () {
                    Navigator.pop(context);
                  }
                ),
                expandedHeight: MediaQuery.of(context).size.height/3,
                // expandedHeight: 220.0,
                // floating: true,
                pinned: true,
                // snap: true,
                elevation: 10,
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  // centerTitle: true,
                  // titlePadding: const EdgeInsets.symmetric(horizontal:10),
                  titlePadding: EdgeInsets.only(left: _AppBarPadding),
                  title: Visibility(
                    visible: _isSliverAppBarExpanded,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      height: 56,
                      width: MediaQuery.of(context).size.width,
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: widget.userMusic.user_name,
                          suffixIcon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                  background: Container(
                    padding: const EdgeInsets.only(bottom: 10, top: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width - MediaQuery.of(context).size.width/4,
                          height: MediaQuery.of(context).size.height/5,
                          decoration: BoxDecoration(
                            // color: Colors.purple[100 * (index % 9 + 1)]!,
                            borderRadius: const BorderRadius.all(Radius.circular(30)),
                            image: DecorationImage(
                              image: NetworkImage(widget.userMusic.allMusic[widget.startIndex].image!),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: null,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - MediaQuery.of(context).size.width/4,
                          height: MediaQuery.of(context).size.height/15,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(widget.userMusic.allMusic[widget.startIndex].name!, style: TextStyle(fontSize: 16), textAlign: TextAlign.center,),
                              Text(widget.userMusic.allMusic[widget.startIndex].author!, style: TextStyle(fontSize: 14), textAlign: TextAlign.center,),
                            ],
                          )
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Card(
                              color: Colors.white38, // Backgrond color
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                splashColor: Colors.grey, // Splash color
                                onTap: () {},
                                child: Container(
                                  // padding: const EdgeInsets.symmetric(horizontal: 5),
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width * 2 / 5,
                                  height: 30,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.play_arrow, color: Colors.deepPurple,size: 24,),
                                      Text('Слушать все',),
                                    ],
                                  )

                                ),
                              ),
                            ),
                            Card(
                              color: Colors.white38, // Backgrond color
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                splashColor: Colors.grey, // Splash color
                                onTap: () {},
                                child: Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width * 2 / 5,
                                  height: 30,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.shuffle, color: Colors.deepPurple,size: 20,),
                                      Text('Перемешать все',),
                                    ],
                                  )
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: 20,
                      (BuildContext context, int index) {
                    return Container(
                        margin: index == 20 - 1 ? const EdgeInsets.only(bottom: 48) : const EdgeInsets.only(bottom: 0),
                        color: index == widget.userMusic.currentIndex ? Colors.grey.shade300 : Colors.white,
                        height: 60,
                        alignment: Alignment.centerLeft,
                        child:
                        InkWell(
                          onTap: () {
                            // onTapped(index);
                          },
                          child: Row(
                            children: [
                              Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    // color: Colors.purple[100 * (index % 9 + 1)]!,
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                    image: DecorationImage(
                                      image: NetworkImage(widget.userMusic.findMusic[widget.startIndex + index].image!),
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
                                          (widget.userMusic.findMusic[widget.startIndex + index].name == widget.audioHandler.mediaItem.value!.title &&
                                              widget.userMusic.findMusic[widget.startIndex + index].author == widget.audioHandler.mediaItem.value!.artist)){
                                        return Container(
                                          width: 30.0,
                                          height: 30.0,
                                          child: const CircularProgressIndicator(color: Colors.white70,),
                                        );
                                      } else if (playing == true &&
                                          (widget.userMusic.findMusic[widget.startIndex + index].name == widget.audioHandler.mediaItem.value!.title &&
                                              widget.userMusic.findMusic[widget.startIndex + index].author == widget.audioHandler.mediaItem.value!.artist)) {
                                        return Container(
                                            alignment: Alignment.center,
                                            child: const Icon(Icons.pause, size: 45, color: Colors.white70,)
                                        );
                                      } else if (widget.startIndex + index == widget.userMusic.currentIndex) {
                                        return const Icon(Icons.play_arrow, size: 45.0, color: Colors.white70,);
                                      }
                                      else return Container();
                                    },
                                  )
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 70,
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.userMusic.findMusic[widget.startIndex + index].name!.trim(),
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      Text(
                                        widget.userMusic.findMusic[widget.startIndex + index].author!,
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
                    return Container(
                      margin: index == 20-1 ? const EdgeInsets.only(bottom: 55) : const EdgeInsets.only(bottom: 5),
                      height: 50,
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
                          // Navigator.push(context, ScaleRoute(page: AlbumMusicList(audioHandler: widget.audioHandler, userMusic: widget.userMusic)));
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // MusicBottomBar(userMusic: widget.userMusic, audioHandler: widget.audioHandler,),
          MusicBottomBar(userMusic: widget.userMusic, audioHandler: widget.audioHandler, updateMusicList: func_updateFilter, /*updateSmallPlaylist: func_smallPlaylist,*/),
        ],
      ),
    );
  }
}