import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Music{

  String? author;
  String? name;
  String? time;
  String? link;
  String? image;

  Music(this.author, this.name, this.time, this.link, [this.image]);
  // Music(String n, String a, String t, String l, [String? img]) {this.name = n;this.author = a;this.time = t;this.time = l;}

  void display(){
    print("Author: $author name: $name time: $time Dowlnload: $link");
  }

  factory Music.fromJson(Map<String, dynamic> jsonData) {
    return Music(jsonData['author'], jsonData['name'], jsonData['time'], jsonData['link']);
  }

  static Map<String, dynamic> toMap(Music music) => {'author': music.author, 'name': music.name, 'time': music.time, 'link': music.link,};

  static String encodeMusics(List<Music> musics) => json.encode(
    musics
        .map<Map<String, dynamic>>((music) => Music.toMap(music))
        .toList(),
  );

  static List<Music> decodeMusics(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<Music>((item) => Music.fromJson(item))
          .toList();

}

class MusicStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print(path);
    return File('$path/counter.txt');
  }

  Future<String> readCounter() async {
    try {
      final file = await _localFile;
      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      print('no file');
      return '';
    }
  }

  Future<File> writeCounter(String data) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(data);
  }

  Future<File> writeFile(String nameFile, String data) async {
    final path = await _localPath;
    print(path);
    final file =  File('$path/$nameFile');
    return file.writeAsString(data);
  }

  Future<String> readFile(String nameFile) async {
    final path = await _localPath;
    try {
      final file =  File('$path/$nameFile');
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      print('no file');
      return '';
    }
  }
}

class SavedFiles {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> writeFile(String nameFile, String data) async {
    final path = await _localPath;
    print(path);
    final file =  File('$path/$nameFile');
    return file.writeAsString(data);
  }

  Future<String> readFile(String nameFile) async {
    final path = await _localPath;
    try {
      final file =  File('$path/$nameFile');
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      print('no file');
      return '';
    }
  }
}
