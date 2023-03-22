import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:test_projects/Music/music.dart';

class ScienceFriday{

  Map<String, String> headers = {
    'accept': 'text/html',
    'accept-encoding': 'deflate, gzip',
    'accept-language': 'ru-RU,ru;q=0.9',
    "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"
  };

  late dom.Document document;
  static List<Music> podcastsList = [];
  String user_name = '';
  bool all_load = false;
  int currentLoadedPage = -1;
  late int allPages;

  getPodcasts(){
    return podcastsList;
  }

  parseSciFriday() async {
    var request = http.Request('GET', Uri.parse('https://www.sciencefriday.com/radio/'));
    request.headers.addAll(headers);
    try {
      http.StreamedResponse response = await request.send().timeout(
          const Duration(seconds: 3));
      dynamic body = await response.stream.bytesToString();
      document = await parser.parse(body);
      allPages = int.parse(document.getElementsByClassName('wp-pagenavi').last.children.last.attributes['href']!.replaceAll('?sf_paged=', ''));
      currentLoadedPage = 1;
      // getInfoFromPage(document);
      await getPagesSciFriday(currentLoadedPage, 5);
    }
    catch (e) {
      return 'Долгое ожидание ответа от сервера';
    }
    return 'Подключено';
  }

  getPagesSciFriday(int start, int end) async {
    for(int index = start; index <= end; index++){
      try {
        final responce = await http.get(Uri.parse(
            'https://www.sciencefriday.com/radio/?sf_paged=${(index).toString()}'),
            headers: headers);
        dom.Document t_doc = parser.parse(responce.body);
        await getInfoFromPage(t_doc);
      }
      catch (e) {
        print('long');
        print(e);
        return null;
      }
    }
  }

  getInfoFromPage(dom.Document docs){
    var elements = docs.getElementsByClassName('cb-thumb-contain img-ratio-md')/*.first.children*/;
    var another =  docs.getElementsByClassName('cb-content col-twoThirds');
    for(int i = 0; i < elements.length; i++){
      String? img = elements[i].children.first.children.first.attributes['data-src'];
      String time = another[i].children[2].text;
      String? name = another[i].children[5].attributes['title'];
      String? id = another[i].children[5].attributes['href']; // 'data-audio'
      podcastsList.add(Music('Science Friday', name, time, id, img));
    }
  }
}