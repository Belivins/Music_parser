import 'dart:convert';
import 'package:audio_service/audio_service.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_projects/Music/Albums.dart';
import 'package:test_projects/Music/music.dart';
import 'package:test_projects/Network/Users.dart';
// import 'package:test_projects/Widgets/Old/ScienceFriday.dart';
import 'package:test_projects/Network/VKstream.dart';
// import 'package:test_projects/Network/network.dart';

class MusicBox {

  VKstream vk_stream = VKstream();

  // Network network = Network();
  List<Album> allAlbums = [];
  List<Music> allMusic = [];
  List<Music> findMusic = [];
  List<MediaItem> mediaList = [];
  List<Music> smallPlaylist = [];
  int currentIndex = -1;
  late User currentUser;

  // MusicBox() {}

  getUser(String userName) async {
    currentUser = await vk_stream.getUserInfo(userName);
    return currentUser;
  }

  saveMusicBox(){
    Music.writeFile(currentUser.userID!, Music.encodeMusics(allMusic));
  }

  fillMediaList(newMusicList){
    List<MediaItem> newMediaList = [];
    for (final music in newMusicList) {
      newMediaList.add(
          MediaItem(
            id: music.link!,
            title: music.name!,
            artist: music.author!,
            duration: Duration(seconds: int.parse(music.time!)),
            artUri: Uri.parse(music.image!),
          )
      );
    }
    return newMediaList;
  }

  loadMusicBox(String userName) async {
    await addMusicList(Music.decodeMusics(await Music.readFile(userName)));
    print('load_start');
    mediaList.addAll(fillMediaList(allMusic));
    return mediaList;
  }

  // saveUser() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final List<String>? users = prefs.getStringList('users');
  //   if (users != null){
  //     if(!users.contains(user_name)) {
  //       users.insert(0, user_name);
  //       await prefs.setStringList('users', users);
  //     }
  //   }
  //   else{
  //     await prefs.setStringList('users', <String>[user_name]);
  //   }
  //   print('saved user');
  //   saveMusicBox();
  // }

  addMusicList(List<Music> newMusic) {
    allMusic.addAll(newMusic);
    findMusic.addAll(newMusic);
    smallPlaylist = List.from(findMusic);
  }

  getMusicFromAlbum() async{
    for (final album in allAlbums){
      album.musics = await vk_stream.getAlbumsMusic(album.id, album.owner_id, album.access_hash);
      print(album.title);
    }
    print('loaded music album');
  }

  getAlbums(String vk_link) async {
    allAlbums = await vk_stream.getUserAlbums(vk_link);
    if(allAlbums.isEmpty) {
      print('нет альбомов');
      // return <MediaItem>[];
    }
    ///////////////////////////////

  }

  pumpage() async {
    List<Music> newMusic = await vk_stream.pumpUP();
    if(newMusic.isEmpty) {
      print('null music - - vk_stream pumpage');
      return <MediaItem>[];
    }
    await addMusicList(newMusic);
    saveMusicBox();
    List<MediaItem> addingMediaList = fillMediaList(newMusic);
    mediaList.addAll(addingMediaList);
    return addingMediaList;
  }

  newGetMusic(String vk_link) async{
    List<Music> newMusic = await vk_stream.getVKstream(vk_link);
    if(newMusic.isEmpty) {
      // print('null music - - vk_stream pumpage');
      return 'Ошибка подключения к серверу музыки';
    }
    await addMusicList(newMusic);
    // saveUser();
    mediaList = fillMediaList(newMusic);
    // for(final music in newMusic){
    //   mediaList.add(
    //       MediaItem(
    //         id: music.link!,
    //         // id: music.link!, https://s3.amazonaws.com/scifri-segments/scifri202303032.mp3
    //         // album: "Science Friday",
    //         title: music.name!,
    //         artist: music.author!,
    //         duration: Duration(seconds: int.parse(music.time!)),
    //         artUri: Uri.parse(music.image!),
    //       )
    //   );
    // }
    return 'Подключено';
  }
}

  // getUserMusic(String vk_link) async {
  //   String answer = await network.GetBody(vk_link);
  //   await updateMusicList(network.getMusic());
  //   for(final music in allMusic){
  //     mediaList.add(
  //         MediaItem(
  //           id: '${network.getLocalIP()}/music?link=${music.link!}',
  //           // id: music.link!,
  //           // album: "Science Friday",
  //           title: music.name!,
  //           artist: music.author!,
  //           duration: Duration(minutes: int.parse(music.time!.split(':').first), seconds: int.parse(music.time!.split(':').last)),
  //           artUri: Uri.parse('https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
  //         )
  //     );
  //   }
  //   return answer;
  // }

