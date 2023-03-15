import 'dart:convert';
import 'package:audio_service/audio_service.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:test_projects/Music/music.dart';
import 'package:test_projects/Network/network.dart';

class MusicBox{

  Network network = Network();
  List<Music> allMusic = [];
  List<Music> findMusic = [];
  List<MediaItem> mediaList = [];
  List<Music> smallPlaylist = [];
  int currentIndex = -1;
  String user_name = '';

  MusicBox(){
  }

  updateMusicList(List<Music> newMusic){
    allMusic = newMusic;
    findMusic = newMusic;
    smallPlaylist = List.from(findMusic);
    user_name = network.user_name;
  }

  getUserMusic(String vk_link) async {
    String answer = await network.GetBody(vk_link);
    await updateMusicList(network.getMusic());
    for(final music in allMusic){
      mediaList.add(
          MediaItem(
            id: '${network.getLocalIP()}/music?link=${music.link!}',
            // id: music.link!,
            // album: "Science Friday",
            title: music.name!,
            artist: music.author!,
            duration: Duration(minutes: int.parse(music.time!.split(':').first), seconds: int.parse(music.time!.split(':').last)),
            artUri: Uri.parse('https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
          )
      );
    }
    return answer;
  }

}