import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:test_projects/Music/AudioHandler.dart';
import 'package:test_projects/Network/MusicBox.dart';
import 'package:test_projects/Pages/MusicScreen.dart';
import 'package:test_projects/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstPage extends StatefulWidget{

  final AudioPlayerHandler audioHandler;
  final MusicBox userMusic;

  const FirstPage({Key? key,required this.audioHandler, required this.userMusic}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FirstPage();
}

class _FirstPage extends State<FirstPage>{

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<String>? users;

  Send_querry(String vk_link) async {
    if(vk_link != null || vk_link.toString() != ''){
      String answer = await widget.userMusic.newGetMusic(vk_link);
      // String answ =  await userMusic.getUserMusic(vk_link);
      await widget.audioHandler.updateQueue(widget.userMusic.mediaList);
      if(answer == 'Подключено'){
        // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => MainScreen(audioHandler)), (route) => false);
        CurrentPage = 1;
        // Navigator.pushReplacementNamed(context, "audio list");
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => MusicScreen(audioHandler: widget.audioHandler, userMusic: widget.userMusic, fromSavedMusic: false)), (route) => false);
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(answer.toString(), textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade800),),
              backgroundColor: Colors.transparent,
            )
        );
      }
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: new Text('Пустой запрос', textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade800),),
            backgroundColor: Colors.transparent,
          )
      );
    }
    return 'Подключено';
  }

  lastUsers() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      users = prefs.getStringList('users');
    });
  }

  getUserMusic(userName) async {
    List<MediaItem> loadedMusic = await widget.userMusic.loadMusicBox(userName);
    if(loadedMusic.isNotEmpty){
      await widget.audioHandler.updateQueue(loadedMusic);
      print('load_end');
    }
    return true;
  }

  @override
  initState() {
    super.initState();
    lastUsers();
  }


  @override
  Widget build(BuildContext context) {
    String new_querry = '';
    String answer;

    return Listener(
      onPointerDown: (PointerDownEvent event) => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Container(
            // color: Colors.greenAccent,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Image.asset("assets/images/main_icon.png", width: 340, height: 240),
                ),
                Container(
                    width: 360,
                    alignment: Alignment.center,
                    // padding: EdgeInsets.all(40),
                    margin: const EdgeInsets.only(top:30),
                    child:
                    TextField(
                      // autofocus: true,
                      onChanged: (value){
                        new_querry = value.toString();
                        print(new_querry);
                      },
                      onSubmitted: (value)  {
                        Send_querry(value.toString());
                      },
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black, fontSize: 24),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        suffixIconColor: Colors.black,
                        hintStyle: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 18),
                        hintText: 'Ссылка на страницу вк или id',
                        contentPadding: const EdgeInsets.fromLTRB(34, 0, 0, 0),
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey, width: 1), borderRadius: BorderRadius.circular(20.0),),
                        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color:Colors.black, width: 1), borderRadius: BorderRadius.circular(20.0)),
                        suffixIcon:
                        IconButton(
                            color: Colors.black,
                            onPressed:() async {
                              Send_querry(new_querry);
                            },
                            icon: const Icon(Icons.search)
                        ),
                      ),
                    )
                ),
                Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      // margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width, vertical: MediaQuery.of(context).size.height,),
                      // color: Colors.pink,
                      child: Container(
                        // color: Colors.blue,
                        width: MediaQuery.of(context).size.width/2,
                        height: MediaQuery.of(context).size.height/4,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          // itemCount: 6,
                          itemCount: users?.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              // color: Colors.grey,
                              height: 50,
                              child: InkWell(
                                onTap:()async {
                                  if(await getUserMusic(users![index]) == true){
                                    // Navigator.pushReplacementNamed(context, "audio list");
                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => MusicScreen(audioHandler: widget.audioHandler, userMusic: widget.userMusic, fromSavedMusic: true)), (route) => false);
                                  }
                                  else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Ошибка загрузки данных", textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade800),),
                                          backgroundColor: Colors.transparent,
                                        )
                                    );
                                    }
                                  },
                                child: Ink(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 5),
                                          height: 35,
                                          width: 35,
                                          color: Colors.blue,
                                        ),
                                        // Text(index.toString()),
                                        Text(users![index]),
                                      ],
                                    )

                                  )

                                )

                              )
                            );
                          }
                        ),
                      ),
                    )
                ),
                // Expanded(
                //   child: Container(
                //     alignment: Alignment.bottomCenter,
                //     child: GestureDetector(
                //       onTap: () async {
                //         // CurrentPage = 1;
                //         await userMusic.newGetMusic();
                //         // await userMusic.demoMusic();
                //         await audioHandler.updateQueue(userMusic.mediaList);
                //         Navigator.pushReplacementNamed(context, "audio list");
                //       },
                //       child: Container(
                //         height: 40,
                //         width: 100,
                //         decoration: const BoxDecoration(
                //             gradient: LinearGradient(
                //               stops: [0, 0.3, 0.6, 1],
                //               colors: [Colors.green, Colors.orange, Colors.yellow, Colors.purple],
                //               begin: Alignment.centerLeft,
                //               end: Alignment.centerRight,
                //             ),
                //             // borderRadius: BorderRadius.circular(10.0)
                //         ),
                //         alignment: Alignment.center,
                //         child: const Text( "DEMO", style: TextStyle(color: Colors.deepPurple, fontSize: 24, fontWeight: FontWeight.bold),),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}