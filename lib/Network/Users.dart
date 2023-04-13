import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class User{

  String? userName;
  String? userID;
  String? userIMG;

  User(this.userName, this.userID, this.userIMG,);



  factory User.fromJson(Map<String, dynamic> jsonData) {
    return User(jsonData['userName'], jsonData['userID'], jsonData['userIMG']);
  }

  static Map<String, dynamic> toMap(User music) => {'userName': music.userName, 'userID': music.userID, 'userIMG': music.userIMG};

  static String encodeMusics(List<User> musics) => json.encode(
    musics
        .map<Map<String, dynamic>>((music) => User.toMap(music))
        .toList(),
  );

  static List<User> decodeMusics(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<User>((item) => User.fromJson(item))
          .toList();

  static List<User> decodeUsers(String users) {
    if(users != ''){
      return (json.decode(users) as List<dynamic>)
          .map<User>((item) => User.fromJson(item))
          .toList();
    }
    else{
      return <User>[];
    }
  }


  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<File> writeFile(String nameFile, String data) async {
    final path = await _localPath;
    print(path);
    final file =  File('$path/$nameFile.json');
    return file.writeAsString(data);
  }

  static Future<String> readFile(String nameFile) async {
    final path = await _localPath;
    try {
      final file =  File('$path/$nameFile.json');
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      // print('no file');
      return '';
    }
  }

}