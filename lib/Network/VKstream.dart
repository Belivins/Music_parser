import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:test_projects/Music/music.dart';
import 'dart:convert';

class VKstream{

  Map<String, String> headers = {
    // 'accept': 'text/html',
    // 'accept-encoding': 'deflate, gzip',
    // 'accept-language': 'ru-RU,ru;q=0.9',
    "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36",
    'Connection': 'keep-alive'
  };

  // static List<Music> podcastsList = [];
  String localIP = 'http://192.168.1.104:5000/';


  setMusic(body){
    try {
      List<Music> podcastsList = [];
      List<dynamic> parsedListJson = jsonDecode(body);
      for (final musicData in parsedListJson) {
        podcastsList.add(Music(musicData['artist'], musicData['title'],
            musicData['duration'].toString(),
            musicData['url'], musicData['track_covers'].isEmpty
                ? ""
                : musicData['track_covers'][1]));
      }
      return podcastsList;
    }
    catch (e) {
      print('Ошибка парсинга музыки $e');
      return <Music>[];
    }
  }

  getVKstream(String userLink) async {
    var request = http.Request('GET', Uri.parse('${localIP}user?user_id=$userLink'));
    request.headers.addAll(headers);
    try {
      http.StreamedResponse response = await request.send().timeout(const Duration(seconds: 60));
      // http.StreamedResponse response = await request.send();
      dynamic body = await response.stream.bytesToString();
      return await setMusic(body);
    }
    catch (e) {
      // return 'Долгое ожидание ответа от сервера';
      print('Ошибка подключения к серверу музыки $e');
      return <Music>[];
    }
    return 'Подключено';
  }

  pumpUP() async {
    var request = http.Request('GET', Uri.parse('${localIP}pumpup'));
    request.headers.addAll(headers);
    try {
      // http.StreamedResponse response = await request.send().timeout(const Duration(seconds: 60));
      http.StreamedResponse response = await request.send();
      dynamic body = await response.stream.bytesToString();
      return await setMusic(body);
    }
    catch (e) {
      print('Ошибка докачи музыки $e');
      return <Music>[];
    }
  }
}