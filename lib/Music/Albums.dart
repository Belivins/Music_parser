import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:test_projects/Music/music.dart';

class Album{

  String? access_hash;
  String? artist;
  String? id;
  String? image;
  String? owner_id;
  String? title;
  String? url;
  List<Music>? musics;

  Album(this.access_hash, this.artist, this.id, this.image, this.owner_id, this.title, this.url, [this.musics]);

  // void display(){
  //   print("Author: $author name: $name time: $time Dowlnload: $link");
  // }

  factory Album.fromJson(Map<String, dynamic> jsonData) {
    return Album(jsonData['access_hash'], jsonData['artist'], jsonData['id'], jsonData['image'], jsonData['owner_id'],
        jsonData['title'], jsonData['url'], jsonData['musics']);
  }

  static Map<String, dynamic> toMap(Album listAlbum) => {'access_hash': listAlbum.access_hash, 'id': listAlbum.id, 'image': listAlbum.image,
  'owner_id': listAlbum.owner_id, 'title': listAlbum.title, 'url': listAlbum.url, 'musics': listAlbum.musics};

  static String encodeMusics(List<Album> musics) => json.encode(
    musics
        .map<Map<String, dynamic>>((music) => Album.toMap(music))
        .toList(),
  );

  static List<Album> decodeMusics(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<Album>((item) => Album.fromJson(item))
          .toList();

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<File> writeFile(String nameFile, String data) async {
    final path = await _localPath;
    print(path);
    final file =  File('$path/$nameFile-album.json');
    return file.writeAsString(data);
  }

  static Future<String> readFile(String nameFile) async {
    final path = await _localPath;
    try {
      final file =  File('$path/$nameFile-album.json');
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      // print('no file');
      return '';
    }
  }

}