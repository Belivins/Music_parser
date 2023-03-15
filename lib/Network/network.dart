import 'dart:convert';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:test_projects/Music/music.dart';

class Network{

  Map<String, String> headers = {
    'accept': 'text/html',
    'accept-encoding': 'deflate, gzip',
    'accept-language': 'ru-RU,ru;q=0.9',
    "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"
  };

  static String local_IP = 'http://192.168.1.100:5000';
  static String url_api = '$local_IP/api?link=';
  static String vk_download = 'https://downloadmusicvk.ru';
  static String audio_list = 'https://downloadmusicvk.ru/audio/list?page=';
  static String authoriz = 'https://downloadmusicvk.ru/site/auth?link=';

  late dom.Document document;
  static List<Music> music_list = [];
  String user_name = '';
  bool all_load = false;

  getMusic(){
    return music_list;
  }

  getLocalIP(){
    return local_IP;
  }

  checkAccess(){
    user_name = document.getElementsByTagName('h1')?.first.text ?? "Unknow";
    if(document.getElementById('w5') != null /*|| document.getElementById('w4') != null*/){
      return false;
    }
    return true;
  }

  getToken(){
    var now = new DateTime.now();
    String token = sha256.convert(utf8.encode(now.minute.toString())).toString();
    return token;
  }

  Future GetHeaders(String vk_link) async{
    try {
      http.Response response = await http.get(
          Uri.parse('${url_api + vk_link}&token=${getToken()}')).timeout(const Duration(seconds: 3));
      var get_date = await response.body;
      Map<String, dynamic> decoded_date = jsonDecode(get_date);

      if(decoded_date.keys.first.toString() == 'cookie') {
        headers['cookie'] = decoded_date[decoded_date.keys.first];
        // print(headers);
        return true;
      }
    }
    catch (e) {
      return false;
    }
    // print(response.request?.url.toString());
  }

  Future<String> GetBody(String vk_link) async{
    if (await GetHeaders(vk_link) == true) {
      var request = http.Request('GET', Uri.parse(authoriz + vk_link));
      request.headers.addAll(headers);
      // request.followRedirects = true;
      print(Uri.parse(authoriz + vk_link));
      try {
        http.StreamedResponse response = await request.send().timeout(const Duration(seconds: 3));
        dynamic body = await response.stream.bytesToString();
        // if(body == 'bad token')
        //   return null;
        document = await parser.parse(body);
      }
      catch(e){
        print('long');
        return 'Долгое ожидание ответа от сервера';
      }
      // await addMusicList(document);

      if(checkAccess() == true) {
        // print('have access');
        // await parseAllPages();
        await parsePage();
        return 'Подключено';
      }
      else
        return 'Ошибка доступа к аудиозаписям';
    }
    return 'Ошибка получения заголовков сервера';
  }

  getPagination(){
    var elements = document.getElementsByClassName('last');
    // print(elements.last.children.last.attributes['data-page']);
    // print(elements.last.attributes['data-page']);
    var number = int.parse(elements.last.children.last.attributes['data-page']!);
    print(number);
    return number! + 1;
  }

  parsePage() async {
    try {
      await addMusicList(document);
    }
    catch (e) {
      print('long');
      print(e);
      return null;
    }
  }

  parseAllPages() async {
    var page_number = await getPagination();
    // page_number = 2;
    for (var i = 2; i <= page_number; i++) {
      print(Uri.parse(audio_list + (i).toString()));
      try {
        final responce = await http.get(Uri.parse(
            'https://downloadmusicvk.ru/audio/list?page=${(i).toString()}'),
            headers: headers);
        dom.Document t_doc = parser.parse(responce.body);
        await addMusicList(t_doc);
      }
      catch (e) {
        print('long');
        print(e);
        return null;
      }
    }
    all_load = true;
  }

  addMusicList(var docs){
    // dynamic elements = document.getElementsByClassName('row audio vcenter').first.text;
    dynamic elements = docs.getElementsByClassName('row audio vcenter');
    var another = docs.getElementsByClassName('col-lg-2 col-md-3 col-sm-4 col-xs-5');
    // print(another.last.children);
    var links = docs.getElementsByClassName('btn btn-primary btn-xs download');
    // links.text
    // print(links.first);
    // links.forEach((i)=>print(i.attributes['href']));
    String name = '';
    String time = '';
    String? download = '';
    // print(another.length);
    for (var i = 0; i < elements.length; i++) {
      // Добавить отлов исключений а также проверку нулевых ссылок при передаче в плеер
      try {
        // print(another[i].children.length);
        if(another[i].children.length > 1)
          download = another[i].children.last.attributes['href']?.replaceFirst('pre', '')!;
        // print(download);
        //   download = links[i].attributes['href']?.replaceFirst('pre', '')!;
        else
          download = '0';
      }
      catch(e){
        print(e);
        download = '0';
      }
      if(download == '0' || download == '')
        continue;
      List<String> split = elements[i].text.split('\n');
      for (final st in split){
        String new_str = st.replaceAll(' ','');
        if(new_str.replaceAll(RegExp(r"[:0-9]"), '') != '') {
          name = st;
        } else if(new_str != '')
          time = st.replaceAll(RegExp(r"[^:0-9]"), '');
      }
      List<String> mylist = name.split(' - ');
      //requestDownload(vk_download + download!);
      music_list.add(Music(mylist.first.trim(), mylist.last.trim(), time.trim(), (vk_download + download!)));
      // music_list.add(Music(mylist.last.trim(), mylist.first.trim(), time.trim(), (vk_download + download!)));
    }
    // music_list.forEach((i)=>i.display());
    // document.remove();
  }
}

Map<String, String> headers = {
  'accept': 'text/html',
  'accept-encoding': 'deflate, gzip',
  'accept-language': 'ru-RU,ru;q=0.9',
  "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"
};

// String local_IP = 'http://192.168.1.100:5000';
// String url_api = '$local_IP/api?link=';
// late dom.Document document;
// List<Music> music_list = [];
// String vk_download = 'https://downloadmusicvk.ru';
// String audio_list = 'https://downloadmusicvk.ru/audio/list?page=';
// String authoriz = 'https://downloadmusicvk.ru/site/auth?link=';
// String user_name = '';
// bool all_load = false;
//
// getMusic(){
//   return music_list;
// }
//
// getLocalIP(){
//   return local_IP;
// }
//
// checkAccess(){
//   user_name = document.getElementsByTagName('h1')?.first.text ?? "Unknow";
//   if(document.getElementById('w5') != null /*|| document.getElementById('w4') != null*/){
//     return false;
//   }
//   return true;
// }
//
// getToken(){
//   var now = new DateTime.now();
//   String token = sha256.convert(utf8.encode(now.minute.toString())).toString();
//   return token;
// }
//
// Future GetHeaders(String vk_link) async{
//   try {
//     http.Response response = await http.get(
//         Uri.parse('${url_api + vk_link}&token=${getToken()}')).timeout(const Duration(seconds: 3));
//     var get_date = await response.body;
//     Map<String, dynamic> decoded_date = jsonDecode(get_date);
//
//     if(decoded_date.keys.first.toString() == 'cookie') {
//       headers['cookie'] = decoded_date[decoded_date.keys.first];
//       // print(headers);
//       return true;
//     }
//   }
//   catch (e) {
//     return false;
//   }
//   // print(response.request?.url.toString());
// }
//
// Future<String> GetBody(String vk_link) async{
//   if (await GetHeaders(vk_link) == true) {
//     var request = http.Request('GET', Uri.parse(authoriz + vk_link));
//     request.headers.addAll(headers);
//     // request.followRedirects = true;
//     print(Uri.parse(authoriz + vk_link));
//     try {
//       http.StreamedResponse response = await request.send().timeout(const Duration(seconds: 3));
//       dynamic body = await response.stream.bytesToString();
//       // if(body == 'bad token')
//       //   return null;
//       document = await parser.parse(body);
//     }
//     catch(e){
//       print('long');
//       return 'Долгое ожидание ответа от сервера';
//     }
//     // await addMusicList(document);
//
//     if(checkAccess() == true) {
//       // print('have access');
//       // await parseAllPages();
//       await parsePage();
//       return 'Подключено';
//     }
//     else
//       return 'Ошибка доступа к аудиозаписям';
//   }
//   return 'Ошибка получения заголовков сервера';
// }
//
// getPagination(){
//   var elements = document.getElementsByClassName('last');
//   // print(elements.last.children.last.attributes['data-page']);
//   // print(elements.last.attributes['data-page']);
//   var number = int.parse(elements.last.children.last.attributes['data-page']!);
//   print(number);
//   return number! + 1;
// }
//
// parsePage() async {
//   try {
//     await addMusicList(document);
//   }
//   catch (e) {
//     print('long');
//     print(e);
//     return null;
//   }
// }
//
// parseAllPages() async {
//   var page_number = await getPagination();
//   // page_number = 2;
//   for (var i = 2; i <= page_number; i++) {
//     print(Uri.parse(audio_list + (i).toString()));
//     try {
//       final responce = await http.get(Uri.parse(
//           'https://downloadmusicvk.ru/audio/list?page=${(i).toString()}'),
//           headers: headers);
//       dom.Document t_doc = parser.parse(responce.body);
//       await addMusicList(t_doc);
//     }
//     catch (e) {
//       print('long');
//       print(e);
//       return null;
//     }
//   }
//   all_load = true;
// }
//
// addMusicList(var docs){
//   // dynamic elements = document.getElementsByClassName('row audio vcenter').first.text;
//   dynamic elements = docs.getElementsByClassName('row audio vcenter');
//   var another = docs.getElementsByClassName('col-lg-2 col-md-3 col-sm-4 col-xs-5');
//   // print(another.last.children);
//   var links = docs.getElementsByClassName('btn btn-primary btn-xs download');
//   // links.text
//   // print(links.first);
//   // links.forEach((i)=>print(i.attributes['href']));
//   String name = '';
//   String time = '';
//   String? download = '';
//   // print(another.length);
//   for (var i = 0; i < elements.length; i++) {
//     // Добавить отлов исключений а также проверку нулевых ссылок при передаче в плеер
//     try {
//       // print(another[i].children.length);
//       if(another[i].children.length > 1)
//         download = another[i].children.last.attributes['href']?.replaceFirst('pre', '')!;
//       // print(download);
//       //   download = links[i].attributes['href']?.replaceFirst('pre', '')!;
//       else
//         download = '0';
//     }
//     catch(e){
//       print(e);
//       download = '0';
//     }
//     if(download == '0' || download == '')
//       continue;
//     List<String> split = elements[i].text.split('\n');
//     for (final st in split){
//       String new_str = st.replaceAll(' ','');
//       if(new_str.replaceAll(RegExp(r"[:0-9]"), '') != '') {
//         name = st;
//       } else if(new_str != '')
//         time = st.replaceAll(RegExp(r"[^:0-9]"), '');
//     }
//     List<String> mylist = name.split(' - ');
//     //requestDownload(vk_download + download!);
//     music_list.add(Music(mylist.first.trim(), mylist.last.trim(), time.trim(), (vk_download + download!)));
//     // music_list.add(Music(mylist.last.trim(), mylist.first.trim(), time.trim(), (vk_download + download!)));
//   }
//   // music_list.forEach((i)=>i.display());
//   // document.remove();
// }