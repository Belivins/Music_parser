import 'package:flutter/material.dart';
import 'package:test_projects/Music/AudioHandler.dart';
import 'package:test_projects/Network/MusicBox.dart';
import 'package:test_projects/main.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key, required this.audioHandler, required this.userMusic}) : super(key: key);

  final AudioPlayerHandler audioHandler;
  final MusicBox userMusic;

  Send_querry(String vk_link) async {
    String answ =  await userMusic.getUserMusic(vk_link);
    await audioHandler.updateQueue(userMusic.mediaList);
    return answ;
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
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Image.asset("assets/images/main_icon.png", width: 340, height: 240),
                ),
                Container(
                    width: 360,
                    alignment: Alignment.center,
                    // padding: EdgeInsets.all(40),
                    margin: EdgeInsets.only(top:30),
                    child:
                    TextField(
                      // autofocus: true,
                      onChanged: (value){
                        new_querry = value.toString();
                      },
                      onSubmitted: (value) async {
                        if(value != null || value.toString() != ''){
                          answer = await Send_querry(value.toString());
                          if(answer == 'Подключено'){
                            // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => MainScreen(audioHandler)), (route) => false);
                            CurrentPage = 1;
                            Navigator.pushReplacementNamed(context, "audio list");
                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: new Text(answer.toString(), textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade800),),
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
                      },
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 24),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        suffixIconColor: Colors.black,
                        hintStyle: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 18),
                        hintText: 'Ссылка на страницу вк или id',
                        contentPadding: EdgeInsets.fromLTRB(34, 0, 0, 0),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1), borderRadius: BorderRadius.circular(20.0),),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.black, width: 1), borderRadius: BorderRadius.circular(20.0)),
                        suffixIcon:
                        IconButton(
                            color: Colors.black,
                            onPressed:() async {
                              if(new_querry != null || new_querry != ''){
                                answer = await Send_querry(new_querry);
                                if(answer == 'Подключено'){
                                  Navigator.pushReplacementNamed(context, "audio list");
                                  // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => MainScreen(audioHandler)), (route) => false);
                                }
                                else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: new Text(answer.toString(), textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade800),),
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
                            },
                            icon: Icon(Icons.search)
                        ),
                      ),
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}