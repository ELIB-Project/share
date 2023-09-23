import 'package:carousel_slider/carousel_controller.dart';
import 'package:chewie/chewie.dart';
import 'package:elib_project/pages/home_page.dart';
import 'package:elib_project/pages/tool_cateory.dart';
import 'package:elib_project/pages/tool_regist_qr.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io'; //쿠키
import 'package:intl/intl.dart';
import 'package:elib_project/auth_dio.dart';
import 'package:elib_project/pages/tool_regist.dart';
import 'package:elib_project/pages/edit_default_tool.dart';
import 'package:elib_project/pages/edit_custom_tool.dart';
import 'package:elib_project/models/bottom_app_bar.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'dart:convert';

double appBarHeight = 40;
double mediaHeight(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.height - appBarHeight) * scale;
double mediaWidth(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.width) * scale;

String gettoday = getToday();
String getToday() {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd');
  String strToday = formatter.format(now);
  return strToday;
}
String today = gettoday.substring(0,4) + gettoday.substring(5,7) + gettoday.substring(8,10);

IconData listIcon = Icons.format_list_bulleted;
IconData detail = Icons.radio_button_checked;
IconData brief = Icons.radio_button_unchecked;
Color detailColor = Colors.green;
Color briefColor = Colors.grey;
double explainSize = 16;

Color tileColor = Colors.grey.shade300;
Color colorAll = Colors.green.shade300; //전체
Color colorFire = Colors.pink.shade300; //화재
Color colorEmergent = Colors.orange.shade300; //응급
Color colorQuake = Colors.yellow.shade300; //지진
Color colorSurvive = Colors.purple.shade300; //생존
Color colorWar = Colors.indigo.shade300; //전쟁
Color colorFlood = Colors.lightBlue.shade300; //수해
Color colorCustom = Colors.grey.shade300; //기타

Color lineColor = tileColor;
Color categoryText = Colors.grey;

String searchText = "";

int toolcount = 0;

const storage = FlutterSecureStorage();

class defaultTool {
  final int? id;
  final int toolId;
  final String? name;
  final List? imgUrl;
  final List? shopUrl;
  final List? videoUrl;
  final String toolExplain;
  final String? type;
  final int count;
  final String? locate;
  final String? exp;
  final String? mfd;
  final String? maker;

  defaultTool({
    required this.id,
    required this.toolId,
    required this.name,
    required this.imgUrl,
    required this.shopUrl,
    required this.videoUrl,
    required this.toolExplain,
    required this.type,
    required this.count,
    required this.locate,
    required this.exp,
    required this.mfd,
    required this.maker,
  });

  factory defaultTool.fromJson(Map<String, dynamic> json) {
    return defaultTool(
      id: json['id'],
      toolId: json['toolId'],
      name: json['name'],
      imgUrl: json['imgUrl'],
      shopUrl: json['shopUrl'],
      videoUrl: json['videoUrl'],
      toolExplain: json['toolExplain'],
      type: json['type'],
      count: json['count'],
      locate: json['locate'],
      exp: json['exp'],
      mfd: json['mfd'],
      maker: json['maker'],
    );
  }
}

class customTool {
  final int id;
  final String? name;
  final String? toolExplain;
  final int count;
  final String? locate;
  final String? exp;
  final String? mfd;

  customTool({
    required this.id,
    required this.name,
    required this.toolExplain,
    required this.count,
    required this.locate,
    required this.exp,
    required this.mfd,
  });

  factory customTool.fromJson(Map<String, dynamic> json) {
    return customTool(
      id: json['id'],
      name: json['name'],
      toolExplain: json['toolExplain'],
      count: json['count'],
      locate: json['locate'],
      exp: json['exp'],
      mfd: json['mfd'],
    );
  }
}

String apiUrl = "https://elib.elib-app-service.o-r.kr:8080/api/v1/media/qr";

class importTool {
  String? toolId;
  String? mfd;
  String? exp;
  String? locate;
  String? name;
  String? toolExplain;
  String? maker;

  importTool({
    this.toolId,
    this.mfd,
    this.exp,
    this.locate,
    this.name,
    this.toolExplain,
    this.maker,
  });

  factory importTool.fromJson(Map<String, dynamic> json) {
    return importTool(
      toolId: json['toolId'],
      mfd: json['mfd'],
      exp: json['exp'],
      locate: json['locate'],
      name: json['name'],
      toolExplain: json['toolExplain'],
      maker: json['maker'],
    );
  }
}

class checkTool {
  String? name;
  String? toolExplain;
  String? maker;

  checkTool({this.name, this.toolExplain, this.maker});

  factory checkTool.fromJson(Map<String, dynamic> json) {
    return checkTool(
      name: json['name'],
      toolExplain: json['toolExplain'],
      maker: json['maker'],
    );
  }
}

Future<void> _launchInBrowser(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
    );
  } else {
    throw '웹 호출 실패 $url';
  }
}

class toolManagePage extends StatefulWidget {
  const toolManagePage({super.key});

  @override
  State<toolManagePage> createState() => _toolManagePageState();
}

class _toolManagePageState extends State<toolManagePage> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    loadCategory = init();
    futureDefaultTool = loadDefaultTool();
    futureCustomTool = loadCustomTool();
    
    super.initState();
  }

  

  void updateCategories(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex--;
      }

      //움직이는 카테고리
      final category = toolCategories.removeAt(oldIndex);

      //카테고리의 새 위치
      toolCategories.insert(newIndex, category);
    });

    storage.write(key: 'Category_Tool', value: jsonEncode(toolCategories));
  }

  String? _output;
  int? toolId;

  Future _scan() async {
    print("runned");
    //스캔 시작 - 이때 스캔 될때까지 blocking
    String? barcode = await scanner.scan();
    //스캔 완료하면 _output 에 문자열 저장하면서 상태 변경 요청.
    setState(() => _output = barcode!);

    Map<String, dynamic> temp;
    importTool tool;

    try {
      _output = _output!.substring(apiUrl.length);
      _output = _output!.replaceAll('?', '{"');
      _output = _output!.replaceAll('=', '":"');
      _output = _output!.replaceAll('&', '","');
      _output = _output! + '"}';
      //print("output: $_output");

      temp = jsonDecode(_output!);
      tool = importTool.fromJson(temp);

          //도구 id값 있는지 통신
        final storage = FlutterSecureStorage();
        final accessToken = await storage.read(key: 'ACCESS_TOKEN');
        var dio = await authDio();
        dio.options.headers['Authorization'] = '$accessToken';

        try {
          final response = await dio.get('/api/v1/tool/${tool.toolId}');
          if (response.statusCode == 200) {
            print("query-------------------------------");
            print(response);

            checkTool check = checkTool.fromJson(response.data);
            tool.name = check.name;
            tool.toolExplain = check.toolExplain;
            tool.maker = check.maker;

            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute( 
                    builder: (context) => qrDefaultToolPage(
                          tool: tool,
                          count: 0,
                        ))).then((value) {});
          }
        } catch (e) {
          print("catch------------------------");

          showDialog(
            context: context,
            barrierDismissible: true, //바깥 영역 터치시 닫을지 여부 결정
            builder: ((context) {
              return AlertDialog(
                elevation: 0.0,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                title: Text("알림"),
                content: Container(
                  width: mediaWidth(context, 0.65),
                  child: Text(
                    'Qr을 지원하지 않는 도구입니다.',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        //color: Colors.green,
                        width: mediaWidth(context, 0.15),
                        height: 35,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); //창 닫기
                          },
                          child: Text(
                            '확인',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 255, 255, 255)),
                            shape:
                                MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          );
        } 
    } catch(e) {
      showDialog(
        context: context,
        barrierDismissible: true, //바깥 영역 터치시 닫을지 여부 결정
        builder: ((context) {
          return AlertDialog(
            insetPadding: EdgeInsets.all(0),
            elevation: 0.0,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            title: Text("알림"),
            content: Container(
              width: mediaWidth(context, 0.65),
              child: Text(
                'Qr을 지원하지 않는 도구입니다.',
                style: TextStyle(
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: mediaWidth(context, 0.15),
                    height: 35,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); //창 닫기
                      },
                      child: Text(
                        '확인',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            const Color.fromARGB(255, 255, 255, 255)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        )),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      );
    }
  }

  Future<bool> permission() async {
    Map<Permission, PermissionStatus> status =
        await [Permission.camera].request(); // [] 권한배열에 권한을 작성

    if (await Permission.camera.isGranted) {
      print("A");
      return Future.value(true);
    } else {
      print("B");
      return Future.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    fullWidth = mediaWidth(context, 1);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Color.fromARGB(255, 250, 250, 250),
          colorSchemeSeed: Color.fromARGB(0, 241, 241, 241),
          useMaterial3: true),
      home: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false, //키보드 올라올때 오버플로우 방지
          appBar: AppBar(
            title: Title(
                color: Color.fromRGBO(87, 87, 87, 1),
                child: Text(
                  '재난키트',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 5, bottom: 5),
                child: IconButton(
                  icon: Icon(
                    Icons.visibility_outlined,
                    size: 30,
                    color: Colors.grey.shade500,
                  ),
                  onPressed: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => toolCategoryPage())).then((value) {
                      setState(() {
                        loadCategory = init();
                        futureDefaultTool = loadDefaultTool();
                        futureCustomTool = loadCustomTool();
                      });
                    });
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => toolRegistPage()));
                  },
                ),
              ),
            ],
          ),
          body: Theme(
            data:
                Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
            child: SafeArea(
              top: true,
              child: Stack(
                children: [Column(
                  children: [
                    SizedBox(
                      height: mediaHeight(context, 0.01),
                    ),
                    //검색창
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Container(
                        height: mediaHeight(context, 0.06),
                        decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Theme.of(context)
                                    .shadowColor
                                    .withOpacity(0.3),
                                offset: const Offset(0, 3),
                                blurRadius: 5.0)
                          ],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0)),
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(0)),
                              borderSide: BorderSide(
                                  width: 1, color: Colors.grey.shade500),
                            ),
                            suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.qr_code_scanner,
                                ),
                                color: Colors.grey,
                                onPressed: () async{
                                  await permission();
                                  _scan();
                                }  
                              ), //검색 아이콘 추가
                            contentPadding: EdgeInsets.only(left: 10, right: 5),
                          ),
                          style: TextStyle(
                            decorationThickness: 0,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: mediaHeight(context, 0.01)
                    ), 
              
                    //카테고리
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            //color: Colors.grey.shade300,
                            height: mediaHeight(context, 1),
                            width: categoryWidth,
                            child: Column(
                              children: [
                                
                                Expanded(
                                  //height: mediaHeight(context, 1) - 10,
                                  child: FutureBuilder<void>(
                                    future: loadCategory,
                                    builder: (context, snapshot) {
                                      return ReorderableListView.builder(
                                        onReorder: (oldIndex, newIndex) =>
                                            updateCategories(oldIndex, newIndex),
                                        itemCount: toolCategories.length,
                                        itemBuilder: (context, i) {
                                          var category = toolCategories[i];
                                          
                                          if(category == selectedCategory) {
                                            tileColor = Colors.grey.shade400;
                                            categoryText = Colors.white;
                                          } else { 
                                            tileColor = Colors.white;
                                            categoryText = Colors.grey.shade400;
                                          }
                                
                                          // switch (category) {
                                          //       case "전체":
                                          //         tileColor = colorAll;
                                          //       case "화재":
                                          //         tileColor = colorFire;
                                          //       case "응급":
                                          //         tileColor = colorEmergent;
                                          //       case "지진":
                                          //         tileColor = colorQuake;
                                          //       case "생존":
                                          //         tileColor = colorSurvive;
                                          //       case "전쟁":
                                          //         tileColor = colorWar;
                                          //       case "수해":
                                          //         tileColor = colorFlood;
                                          //       case "기타":
                                          //         tileColor = colorCustom;
                                          //     }
                                
                                        return
                                            Container(
                                              //color: tileColor,
                                              //color: Colors.white,
                                              key: Key(category),
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                                                child: Container(
                                                  height: 30,
                                                    decoration: BoxDecoration(
                                                      color: tileColor,
                                                      borderRadius:
                                                          BorderRadius.circular(20),
                                                      border: Border.all(
                                                        color: categoryText,
                                                        width: 1,
                                                      ),
                                                    ),
                                                  child: Stack(
                                                    children: [
                                                      Center(
                                                        child: Text(
                                                          category,
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.normal,
                                                            color: categoryText,
                                                            fontSize: 15,
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                      ListTile(
                                                      //tileColor: tileColor,
                                                      // title: Text(
                                                      //   category,
                                                      //   style: TextStyle(
                                                      //     fontWeight: FontWeight.normal,
                                                      //     color: categoryText,
                                                      //     fontSize: 15,
                                                      //   ),
                                                      // ),
                                                      onTap: () {
                                                                  
                                                        selectedCategory = category;
                                                    
                                                        selectedDefaultLength = allDefault?.length;
                                                        selectedCustomLength = allCustom?.length;
                                                        
                                                        switch (selectedCategory) {
                                                          case "전체":
                                                            selectedLength = allDefault?.length;
                                                            defaultView = allDefault;
                                                            customView = allCustom;
                                                            //lineColor = colorAll;
                                                          case "화재":
                                                            selectedLength = fire?.length;
                                                            selectedCustomLength = 0;
                                                            defaultView = fire;
                                                            //lineColor = colorFire;
                                                          case "응급":
                                                            selectedLength = emergent?.length;
                                                            selectedCustomLength = 0;
                                                            defaultView = emergent;
                                                            //lineColor = colorEmergent;
                                                          case "지진":
                                                            selectedLength = quake?.length;
                                                            selectedCustomLength = 0;
                                                            defaultView = quake;
                                                            //lineColor = colorQuake;
                                                          case "생존":
                                                            selectedLength = survive?.length;
                                                            selectedCustomLength = 0;
                                                            defaultView = survive;
                                                            //lineColor = colorSurvive;
                                                          case "전쟁":
                                                            selectedLength = war?.length;
                                                            selectedCustomLength = 0;
                                                            defaultView = war;
                                                            //lineColor = colorWar;
                                                          case "수해":
                                                            selectedLength = flood?.length;
                                                            selectedCustomLength = 0;
                                                            defaultView = flood;
                                                            //lineColor = colorFlood;
                                                          case "기타":
                                                            selectedLength = 0;
                                                            selectedCustomLength = allCustom?.length;
                                                            customView = allCustom;
                                                            //lineColor = colorCustom;
                                                        }
                                                        print(selectedCategory);
                                                    
                                                        setState(() {
                                                        });
                                                      },
                                                    ),
                                                    ]
                                                  ),
                                                ),
                                              ),
                                            );
                                        }
                                        
                                      );
                                    }
                                  ),
                                ),
                              ],
                            ),
                          ),
              
              
                          //도구 출력
                          Expanded(
                            child: Column(
                              children: [
                                //정렬용
                                  Container(
                                      height: mediaHeight(context, 0.05),
                                      width: mediaWidth(context, 1),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: Text(
                                                '물품 ${selectedLength! + selectedCustomLength!}종류',
                                                style: TextStyle(
                                                    color: Colors.grey.shade800,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: IconButton(
                                                icon: Icon(
                                                  listIcon,
                                                  color: Colors.grey.shade600,
                                                  size: 25,
                                                ),
                                                onPressed: () async{
                                                  showModalBottomSheet (
                                                    barrierColor: Colors.black.withOpacity(0.3),
                                                    backgroundColor: Colors.transparent,
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return StatefulBuilder(builder: (BuildContext context, StateSetter bottomState) {
                                                      return Container(
                                                        color: Color.fromARGB(255, 255, 255, 255).withOpacity(1),
                                                        height: 200,
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              width: mediaWidth(context, 1),
                                                              height: 70,
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [Text(
                                                                   '조회',
                                                                    style: TextStyle(
                                                                      color: Colors.grey.shade800,
                                                                       fontSize: 20,
                                                                       fontWeight: FontWeight.w500),
                                                                  ),
                                                                ]
                                                              )
                                                            ),

                                                            InkWell(
                                                              onTap: () {
                                                                print("a");
                                                                if(detail == Icons.radio_button_checked) {
                                                                  
                                                                } else {
                                                                  detail = Icons.radio_button_checked;
                                                                  brief = Icons.radio_button_unchecked;
                                                                }
                                                                listIcon = Icons.format_list_bulleted;
                                                                bottomState(() {
                                                                  setState(() {
                                                                    brief = brief;
                                                                    detail = detail;
                                                                    listIcon = Icons.format_list_bulleted;
                                                                    explainSize = 16;
                                                                    detailColor = Colors.green;
                                                                    briefColor = Colors.grey;
                                                                  });
                                                                });
                                                              },
                                                              child: Container(
                                                                width: mediaWidth(context, 1),
                                                                height: 60,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(left: 10, right: 10,),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons.format_list_bulleted,
                                                                      ),
                                                                      Text(
                                                                       ' 자세히 보기',
                                                                        style: TextStyle(
                                                                          color: Colors.grey.shade800,
                                                                           fontSize: 20,
                                                                           fontWeight: FontWeight.w500),
                                                                      ),
                                                                
                                                                      Spacer(),
                                                                      Icon(
                                                                        detail,
                                                                        color: detailColor,
                                                                      ),
                                                                    ]
                                                                  ),
                                                                )
                                                              ),
                                                            ),

                                                            InkWell(
                                                              onTap: () {
                                                                print("b");
                                                                if(brief == Icons.radio_button_checked) {
                                                                } else {
                                                                  brief = Icons.radio_button_checked;
                                                                  detail = Icons.radio_button_unchecked;
                                                                }
                                                                bottomState(() {
                                                                  setState(() {
                                                                    brief = brief;
                                                                    detail = detail;
                                                                    listIcon = Icons.view_agenda;
                                                                    explainSize = 0;
                                                                    detailColor = Colors.grey;
                                                                    briefColor = Colors.green;
                                                                  });
                                                                });
                                                              },
                                                              child: Container(
                                                                width: mediaWidth(context, 1),
                                                                height: 60,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(left: 10, right: 10,),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons.view_agenda,
                                                                      ),
                                                                      Text(
                                                                       ' 간략히 보기',
                                                                        style: TextStyle(
                                                                          color: Colors.grey.shade800,
                                                                           fontSize: 20,
                                                                           fontWeight: FontWeight.w500),
                                                                      ),
                                                                
                                                                      Spacer(),
                                                                      Icon(
                                                                        brief,
                                                                        color: briefColor,
                                                                      ),
                                                                    ]
                                                                  ),
                                                                )
                                                              ),
                                                            )
                                                          ]
                                                        )
                                                      );
                                                      });
                                                    }
                                                  );
                                                },
                                              ),
                                            ),
                                          ])),

                                Expanded(
                                  child: SingleChildScrollView(
                                    // keyboardDismissBehavior:
                                    //     ScrollViewKeyboardDismissBehavior.onDrag,
                                    child: Column(
                                      children: [
                                        FutureBuilder<List<defaultTool>>(
                                            future: futureDefaultTool,
                                            builder: (context, snapshot) {
                                            
                                              switch (selectedCategory) {
                                                case "전체":
                                                  defaultView = allDefault;
                                                  customView = allCustom;
                                                case "화재":
                                                  defaultView = fire;
                                                case "응급":
                                                  defaultView = emergent;
                                                case "지진":
                                                  defaultView = quake;
                                                case "생존":
                                                  defaultView = survive;
                                                case "전쟁":
                                                  defaultView = war;
                                                case "수해":
                                                  defaultView = flood;
                                                case "기타":
                                                  defaultView = allDefault;
                                                  customView = allCustom;
                                              }
                                              
                                              if (snapshot.hasError)
                                                return Text('${snapshot.error}');
                                              
                                              if(defaultView?.isEmpty == true && selectedLength == 0) {
                                                print("defaultView is empty");
                                                return Container(
                                                  height: mediaHeight(context, 0.7),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text("empty")
                                                    ]
                                                  ),
                                                );
                                              }
                                              
                                              if (defaultView != null) {
                                                return Column(
                                                  children: [
                                                    Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        SizedBox(
                                                            width: MediaQuery.of(context).size.width - categorySpace, //fullsize
                                                            child: ListView.builder(
                                                                shrinkWrap: true,
                                                                physics:
                                                                    const NeverScrollableScrollPhysics(),
                                                                itemCount: selectedLength,
                                                                scrollDirection: Axis.vertical,
                                                                itemBuilder: (context, i) {
                                                                  
                                                                  int countColor;
                                                                  int countText;
                                                                  int iconColor;
                                                                  int iconBack;
                                                                                                          
                                                                  int locateColor =
                                                                      0xFFCFDFFF;
                                                                  int locateText =
                                                                      0xFF6A9DFF;
                                                                                                          
                                                                  int expColor =
                                                                      0xFFB6F4CB;
                                                                  int expText =
                                                                      0xFF38AE5D;
                                                                                                          
                                                                  double locateWidth =
                                                                      80;
                                                                  double locatePadding =
                                                                      10;
                                                                  double expWidth = 80;
                                                                  double expPadding =
                                                                      10;
                                                                                                          
                                                                  double makerWidth =
                                                                      80;
                                                                  double makerPadding =
                                                                      10;
                                                                                                          
                                                                  if (defaultView?[i].count == 0) {
                                                                    countColor =
                                                                        0xFFFFC5C5; //pink background
                                                                    countText =
                                                                        0xFFF16969; //pink text
                                                                                                          
                                                                    iconBack =
                                                                        0xFFFFC5C5; //pink background
                                                                    iconColor =
                                                                        0xFFF16969; //pink text
                                                                  } else {
                                                                    countColor =
                                                                        0xFFFFF3B2; //yellow background
                                                                    countText =
                                                                        0xFFE4C93D; //yellow text
                                                                                                          
                                                                    iconBack =
                                                                        0xFFFFF3B2; //yellow background
                                                                    iconColor =
                                                                        0xFFE4C93D; //yellow text
                                                                  }
                                                                                                          
                                                                  String? name;
                                                                  if (defaultView?[i].name == null || defaultView?[i].name == "") {
                                                                    name = "";
                                                                  } else {
                                                                    name = defaultView?[i].name;
                                              
                                                                    if (name!.length > 10) {
                                                                      name = name?.substring(0, 10);
                                                                      name ="$name...";
                                                                    }
                                                                  }
                                                                                                          
                                                                  String? toolExplain;
                                                                  if (defaultView?[i].toolExplain == null || defaultView?[i].toolExplain == "") {
                                                                    toolExplain = "상세정보를 입력하세요.";
                                                                  } else {
                                                                    toolExplain = defaultView?[i].toolExplain;
                                                                    if (toolExplain!.length > 20) {
                                                                      toolExplain = toolExplain?.substring(0, 20);
                                                                      toolExplain ="$toolExplain...";
                                                                    }
                                                                  }
                                              
                                                                  bool expireVisibility = false;
                                                                  int expCheck = 0;
                                                                  int todayCheck = 0;
                                                                                                          
                                                                  String? exp;
                                                                  if (defaultView?[i].exp == null || defaultView?[i].exp == "") {
                                                                    exp = "";
                                                                    expWidth = 0;
                                                                    expPadding = 0;
                                                                  } else {
                                                                    exp = defaultView?[i].exp;
                                              
                                                                    todayCheck = int.parse(today);
                                                                    String tempExp = exp!.substring(0,4) + exp!.substring(5,7) + exp!.substring(8,10);
                                                                    expCheck = int.parse(tempExp);
                                              
                                                                    if(expCheck < todayCheck) {
                                                                      expireVisibility = true;
                                                                      expColor = 0xFFFFC5C5;
                                                                      expText = 0xFFF16969;
                                                                    } else {
                                                                      expColor = 0xFFB6F4CB;
                                                                      expText = 0xFF38AE5D;
                                                                    }
                                                                  }
                                                                                                          
                                                                  String? maker;
                                                                  if (defaultView?[i]
                                                                              .maker ==
                                                                          null ||
                                                                      defaultView?[i]
                                                                              .maker ==
                                                                          "") {
                                                                    maker = "Ad.";
                                                                    makerWidth = 40;
                                                                    //makerPadding = 0;
                                                                  } else {
                                                                    maker = defaultView?[i].maker;
                                                                                                          
                                                                    if (maker!.length < 3) {
                                                                      makerWidth = 40;
                                                                    } else if (maker!.length < 4) {
                                                                      maker = maker?.substring(0, 3);
                                                                      maker ="$maker..";
                                                                    } else if (maker!.length < 5) {
                                                                      makerWidth = 60;
                                                                    } else if (maker!.length > 5) {
                                                                      maker = maker?.substring(0, 5);
                                                                      maker ="$maker...";
                                                                    }
                                                                  }
                                                                                                          
                                                                  String? locate;
                                                                  if (defaultView?[i]
                                                                              .locate ==
                                                                          null ||
                                                                      defaultView?[i]
                                                                              .locate ==
                                                                          "") {
                                                                    locate = "";
                                                                    locateWidth = 0;
                                                                    locatePadding = 0;
                                                                  } else {
                                                                    locate = defaultView?[i]
                                                                        .locate;
                                                                                                          
                                                                    if (locate!.length <
                                                                        3) {
                                                                      locateWidth = 40;
                                                                    } else if (locate!
                                                                            .length <
                                                                        4) {
                                                                      locateWidth = 50;
                                                                    } else if (locate!
                                                                            .length <
                                                                        5) {
                                                                      locateWidth = 60;
                                                                    } else if (locate!
                                                                            .length >
                                                                        5) {
                                                                      locate = locate
                                                                          ?.substring(
                                                                              0, 5);
                                                                      locate =
                                                                          "$locate...";
                                                                    }
                                                                  }
                                              
                                                                  if(expWidth != 0) {
                                                                    makerWidth = 0;
                                                                  }
                                                                                                          
                                                                  if (searchText!
                                                                          .isNotEmpty &&
                                                                      !defaultView![i]
                                                                          .name!
                                                                          .toLowerCase()
                                                                          .contains(
                                                                              searchText
                                                                                  .toLowerCase())) {
                                                                    return SizedBox
                                                                        .shrink();
                                                                  } else
                                                                    return InkWell(
                                                                      onTap: () {
                                                                        showDefault(
                                                                            context,
                                                                            defaultView?[i]);
                                                                      },
                                                                      child: Column(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets
                                                                                  .only(
                                                                                  top:
                                                                                      10,
                                                                                  bottom:
                                                                                      10),
                                                                              child:
                                                                                  Container(
                                                                                child:
                                                                                    Row(
                                                                                  crossAxisAlignment:
                                                                                      CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(right: 20, left: 10, top: 5, bottom: 5),
                                                                                      child: Container(
                                                                                        decoration: BoxDecoration(
                                                                                          border: Border.all(
                                                                                            width: 1.8,
                                                                                            color: Color(iconBack),
                                                                                          ),
                                                                                          color: Color(iconBack),
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        ),
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.all(5.0),
                                                                                          child: Icon(
                                                                                            Icons.local_fire_department,
                                                                                            color: Color(iconColor),
                                                                                            size: 30,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Container(
                                                                                          width: mediaWidth(context, 1) - (categorySpace + 100),
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.only(top: 1),
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                              children: [
                                                                                                Row(
                                                                                                  children: [
                                                                                                    Text.rich(TextSpan(children: [
                                                                                                      TextSpan(
                                                                                                          text: '$name ',
                                                                                                          style: TextStyle(
                                                                                                            color: Colors.grey.shade700,
                                                                                                            fontSize: 18,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                          )),
                                                                                                    ])),
                                                                                                  ],
                                                                                                ),
                                              
                                                                                                
                                                                                            
                                                                                                Visibility(
                                                                                                  visible: expireVisibility,
                                                                                                  child: Row(
                                                                                                    children: [
                                                                                                      Icon(
                                                                                                        Icons.report_outlined,
                                                                                                        color: Colors.red,
                                                                                                        size: 15,
                                                                                                      ),
                                                                                                      Text(
                                                                                                      '유통기한 만료',
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 12,
                                                                                                          color: Colors.red,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                            
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                    
                                              
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.only(top: 2),
                                                                                          child: Text.rich(TextSpan(children: [
                                                                                            TextSpan(
                                                                                                text: '$toolExplain',
                                                                                                style: TextStyle(
                                                                                                  color: Colors.grey.shade500,
                                                                                                  fontSize: explainSize,
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                )),
                                                                                          ])),
                                                                                        ),
                                              
                                                                                        //  Padding(
                                                                                        //   padding: const EdgeInsets.only(top: 2),
                                                                                        //   child: Text.rich(TextSpan(children: [
                                                                                        //     TextSpan(
                                                                                        //         text: '$maker',
                                                                                        //         style: TextStyle(
                                                                                        //           color: Colors.grey.shade500,
                                                                                        //           fontSize: 15,
                                                                                        //         )),
                                                                                        //   ])),
                                                                                        // ),
                                                                                        
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.only(top: 5),
                                                                                          child: Row(
                                                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                                                            children: [
                                                                                              Padding(
                                                                                                padding: const EdgeInsets.only(right: 10),
                                                                                                child: Container(
                                                                                                  height: 20,
                                                                                                  width: 35,
                                                                                                  decoration: BoxDecoration(
                                                                                                    border: Border.all(
                                                                                                      width: 1,
                                                                                                      color: Color(countColor),
                                                                                                    ),
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                    color: Color(countColor),
                                                                                                  ),
                                                                                                  child: Padding(
                                                                                                    padding: const EdgeInsets.only(left: 5, right: 5),
                                                                                                    child: Text(
                                                                                                      '${defaultView?[i].count}개',
                                                                                                      style: TextStyle(
                                                                                                        color: Color(countText),
                                                                                                        fontSize: 12,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                      ),
                                                                                                      textAlign: TextAlign.center,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Padding(
                                                                                                padding: EdgeInsets.only(right: locatePadding),
                                                                                                child: Container(
                                                                                                  height: 20,
                                                                                                  width: locateWidth,
                                                                                                  decoration: BoxDecoration(
                                                                                                    border: Border.all(
                                                                                                      width: 1,
                                                                                                      color: Color(locateColor),
                                                                                                    ),
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                    color: Color(locateColor),
                                                                                                  ),
                                                                                                  child: Padding(
                                                                                                    padding: const EdgeInsets.only(left: 5, right: 5),
                                                                                                    child: Text(
                                                                                                      '$locate',
                                                                                                      style: TextStyle(
                                                                                                        color: Color(locateText),
                                                                                                        fontSize: 12,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                      ),
                                                                                                      textAlign: TextAlign.center,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Padding(
                                                                                                padding: EdgeInsets.only(right: expPadding),
                                                                                                child: Container(
                                                                                                  height: 20,
                                                                                                  width: expWidth,
                                                                                                  decoration: BoxDecoration(
                                                                                                    border: Border.all(
                                                                                                      width: 1,
                                                                                                      color: Color(expColor),
                                                                                                    ),
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                    color: Color(expColor),
                                                                                                  ),
                                                                                                  child: Padding(
                                                                                                    padding: const EdgeInsets.only(left: 5, right: 5),
                                                                                                    child: Text(
                                                                                                      '$exp',
                                                                                                      style: TextStyle(
                                                                                                        color: Color(expText),
                                                                                                        fontSize: 12,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                      ),
                                                                                                      textAlign: TextAlign.center,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Container(
                                                                                                height: 20,
                                                                                                width: makerWidth,
                                                                                                decoration: BoxDecoration(
                                                                                                  border: Border.all(
                                                                                                    width: 1,
                                                                                                    color: Colors.grey.shade300,
                                                                                                  ),
                                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                                  color: Colors.grey.shade300,
                                                                                                ),
                                                                                                child: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 5, right: 5),
                                                                                                  child: Text(
                                                                                                    '$maker',
                                                                                                    style: TextStyle(
                                                                                                      color: Colors.grey,
                                                                                                      fontSize: 12,
                                                                                                      fontWeight: FontWeight.bold,
                                                                                                    ),
                                                                                                    textAlign: TextAlign.center,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ]),
                                                                    );
                                                                })),
                                                        FutureBuilder<List<customTool>>(
                                                            future: futureCustomTool,
                                                            builder: (context, snapshot) {
                                              
                                                              if (snapshot.hasError)
                                                                return Text('${snapshot.error}');
                                              
                                                              if (customView?.isEmpty == true && selectedLength == 0) {
                                                                print("customView is empty");
                                                                return Column(
                                                                    children: [
                                                                      Container(
                                                                        child: Text("empty"),
                                                                      )
                                                                  ]);
                                                              }
                                              
                                                             if (customView != null) {
                                                                return Column(
                                                                  children: [
                                                                    Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize.min,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        SizedBox(
                                                                          width: MediaQuery.of(
                                                                                  context)
                                                                              .size
                                                                              .width - categorySpace,
                                                                          child: ListView.builder(
                                                                            shrinkWrap: true,
                                                                            physics:
                                                                                const NeverScrollableScrollPhysics(),
                                                                            itemCount: selectedCustomLength,
                                                                            scrollDirection:
                                                                                Axis.vertical,
                                                                            itemBuilder:
                                                                                (context, i) {
                                                                              int countColor;
                                                                              int countText;
                                                                              int iconColor;
                                                                              int iconBack;
                                              
                                                                              int locateColor =
                                                                                  0xFFCFDFFF;
                                                                              int locateText =
                                                                                  0xFF6A9DFF;
                                              
                                                                              int expColor =
                                                                                  0xFFB6F4CB;
                                                                              int expText =
                                                                                  0xFF38AE5D;
                                              
                                                                              double
                                                                                  locateWidth =
                                                                                  80;
                                                                              double
                                                                                  locatePadding =
                                                                                  10;
                                                                              double expWidth =
                                                                                  80;
                                                                              double
                                                                                  expPadding =
                                                                                  10;
                                              
                                                                              if (customView?[i]
                                                                                      .count ==
                                                                                  0) {
                                                                                countColor =
                                                                                    0xFFFFC5C5; //pink background
                                                                                countText =
                                                                                    0xFFF16969; //pink text
                                              
                                                                                iconBack =
                                                                                    0xFFFFC5C5; //pink background
                                                                                iconColor =
                                                                                    0xFFF16969; //pink text
                                                                              } else {
                                                                                countColor =
                                                                                    0xFFFFF3B2; //yellow background
                                                                                countText =
                                                                                    0xFFE4C93D; //yellow text
                                              
                                                                                iconBack =
                                                                                    0xFFFFF3B2; //yellow background
                                                                                iconColor =
                                                                                    0xFFE4C93D; //yellow text
                                                                              }
                                              
                                                                              String? name;
                                                                              if (customView?[i].name == null || customView?[i].name == "") {
                                                                                name = "";
                                                                              } else {
                                                                                name = customView?[i].name;
                                              
                                                                                if (name!.length > 10) {
                                                                                  name = name?.substring(0, 10);
                                                                                  name ="$name...";
                                                                                }
                                                                              }
                                              
                                                                              String? toolExplain;
                                                                              if (customView?[i].toolExplain == null || customView?[i].toolExplain == "") {
                                                                                toolExplain = "상세정보를 입력하세요.";
                                                                              } else {
                                                                                toolExplain = customView?[i].toolExplain;
                                                                                if (toolExplain!.length > 20) {
                                                                                  toolExplain = toolExplain?.substring(0, 20);
                                                                                  toolExplain ="$toolExplain...";
                                                                                }
                                                                              }
                                              
                                                                              bool expireVisibility = false;
                                                                              int expCheck = 0;
                                                                              int todayCheck = 0;
                                              
                                                                              String? exp;
                                                                              if (customView?[i].exp == null || customView?[i].exp == "") {
                                                                                exp = "";
                                                                                expWidth = 0;
                                                                                expPadding = 0;
                                                                              } else {
                                                                                exp = customView?[i].exp;
                                              
                                                                                todayCheck = int.parse(today);
                                                                                String tempExp = exp!.substring(0,4) + exp!.substring(5,7) + exp!.substring(8,10);
                                                                                expCheck = int.parse(tempExp);
                                              
                                                                                if (expCheck <
                                                                                    todayCheck) {
                                                                                  expireVisibility =
                                                                                      true;
                                                                                  expColor =
                                                                                      0xFFFFC5C5;
                                                                                  expText =
                                                                                      0xFFF16969;
                                                                                } else {
                                                                                  expColor =
                                                                                      0xFFB6F4CB;
                                                                                  expText =
                                                                                      0xFF38AE5D;
                                                                                }
                                                                              }
                                              
                                                                              String? locate;
                                                                              if (customView?[
                                                                                              i]
                                                                                          .locate ==
                                                                                      null ||
                                                                                  customView?[
                                                                                              i]
                                                                                          .locate ==
                                                                                      "") {
                                                                                locate = "";
                                                                                locateWidth = 0;
                                                                                locatePadding =
                                                                                    0;
                                                                              } else {
                                                                                locate =
                                                                                    customView?[
                                                                                            i]
                                                                                        .locate;
                                              
                                                                                if (locate!
                                                                                        .length <
                                                                                    3) {
                                                                                  locateWidth =
                                                                                      40;
                                                                                } else if (locate!
                                                                                        .length <
                                                                                    4) {
                                                                                  locateWidth =
                                                                                      50;
                                                                                } else if (locate!
                                                                                        .length <
                                                                                    5) {
                                                                                  locateWidth =
                                                                                      60;
                                                                                } else if (locate!
                                                                                        .length >
                                                                                    5) {
                                                                                  locate = locate
                                                                                      ?.substring(
                                                                                          0, 5);
                                                                                  locate =
                                                                                      "$locate...";
                                                                                }
                                                                              }
                                              
                                                                              if (searchText!
                                                                                      .isNotEmpty &&
                                                                                  !customView![i]
                                                                                      .name!
                                                                                      .toLowerCase()
                                                                                      .contains(
                                                                                          searchText
                                                                                              .toLowerCase())) {
                                                                                return SizedBox
                                                                                    .shrink();
                                                                              } else
                                                                                return InkWell(
                                                                                  onTap: () {
                                                                                    showCustom(
                                                                                        context,
                                                                                        customView?[i]);
                                                                                  },
                                                                                  child: Column(
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: const EdgeInsets
                                                                                            .only(
                                                                                            top:
                                                                                                10,
                                                                                            bottom:
                                                                                                10),
                                                                                        child:
                                                                                            Container(
                                                                                          child:
                                                                                              Row(
                                                                                            crossAxisAlignment:
                                                                                                CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Padding(
                                                                                                padding: const EdgeInsets.only(right: 20, left: 10, top: 5, bottom: 5),
                                                                                                child: Container(
                                                                                                  decoration: BoxDecoration(
                                                                                                    border: Border.all(
                                                                                                      width: 1.7,
                                                                                                      color: Color(iconBack),
                                                                                                    ),
                                                                                                    color: Color(iconBack),
                                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                                  ),
                                                                                                  child: Padding(
                                                                                                    padding: EdgeInsets.all(10.0),
                                                                                                    child: Icon(
                                                                                                      Icons.medical_services,
                                                                                                      color: Color(iconColor),
                                                                                                      size: 20,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Column(
                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                                children: [
                                                                                                  Container(
                                                                                                    width: mediaWidth(context, 1) - (categorySpace + 100),
                                                                                                    child: Padding(
                                                                                                      padding: const EdgeInsets.only(top: 1),
                                                                                                      child: Row(
                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                        children: [
                                                                                                          Text.rich(TextSpan(children: [
                                                                                                            TextSpan(
                                                                                                                text: '$name',
                                                                                                                style: TextStyle(
                                                                                                                  color: Colors.grey.shade700,
                                                                                                                  fontSize: 18,
                                                                                                                  fontWeight: FontWeight.bold,
                                                                                                                )),
                                                                                                          ])),
                                              
                                                                                                          Visibility(
                                                                                                            visible: expireVisibility,
                                                                                                            child: Row(
                                                                                                              children: [
                                                                                                                Icon(
                                                                                                                  Icons.report_outlined,
                                                                                                                  color: Colors.red,
                                                                                                                  size: 15,
                                                                                                                ),
                                                                                                                Text(
                                                                                                                  '유통기한 만료',
                                                                                                                  style: TextStyle(
                                                                                                                    fontSize: 12,
                                                                                                                    color: Colors.red,
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: const EdgeInsets.only(top: 2),
                                                                                                    child: Text.rich(TextSpan(children: [
                                                                                                      TextSpan(
                                                                                                          text: '$toolExplain',
                                                                                                          style: TextStyle(
                                                                                                            color: Colors.grey.shade500,
                                                                                                            fontSize: explainSize,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                          )),
                                                                                                    ])),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: const EdgeInsets.only(top: 5),
                                                                                                    child: Row(
                                                                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                                                                      children: [
                                                                                                        Padding(
                                                                                                          padding: const EdgeInsets.only(right: 10),
                                                                                                          child: Container(
                                                                                                            height: 20,
                                                                                                            width: 35,
                                                                                                            decoration: BoxDecoration(
                                                                                                              border: Border.all(
                                                                                                                width: 1,
                                                                                                                color: Color(countColor),
                                                                                                              ),
                                                                                                              borderRadius: BorderRadius.circular(5),
                                                                                                              color: Color(countColor),
                                                                                                            ),
                                                                                                            child: Padding(
                                                                                                              padding: const EdgeInsets.only(left: 5, right: 5),
                                                                                                              child: Text(
                                                                                                                '${customView?[i].count}개',
                                                                                                                style: TextStyle(
                                                                                                                  color: Color(countText),
                                                                                                                  fontSize: 12,
                                                                                                                  fontWeight: FontWeight.bold,
                                                                                                                ),
                                                                                                                textAlign: TextAlign.center,
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                        Padding(
                                                                                                          padding: EdgeInsets.only(right: locatePadding),
                                                                                                          child: Container(
                                                                                                            height: 20,
                                                                                                            width: locateWidth,
                                                                                                            decoration: BoxDecoration(
                                                                                                              border: Border.all(
                                                                                                                width: 1,
                                                                                                                color: Color(locateColor),
                                                                                                              ),
                                                                                                              borderRadius: BorderRadius.circular(5),
                                                                                                              color: Color(locateColor),
                                                                                                            ),
                                                                                                            child: Padding(
                                                                                                              padding: const EdgeInsets.only(left: 5, right: 5),
                                                                                                              child: Text(
                                                                                                                '$locate',
                                                                                                                style: TextStyle(
                                                                                                                  color: Color(locateText),
                                                                                                                  fontSize: 12,
                                                                                                                  fontWeight: FontWeight.bold,
                                                                                                                ),
                                                                                                                textAlign: TextAlign.center,
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                        
                                                                                                        Padding(
                                                                                                          padding: EdgeInsets.only(right: expPadding),
                                                                                                          child: Container(
                                                                                                            height: 20,
                                                                                                            width: expWidth,
                                                                                                            decoration: BoxDecoration(
                                                                                                              border: Border.all(
                                                                                                                width: 1,
                                                                                                                color: Color(expColor),
                                                                                                              ),
                                                                                                              borderRadius: BorderRadius.circular(5),
                                                                                                              color: Color(expColor),
                                                                                                            ),
                                                                                                            child: Padding(
                                                                                                              padding: const EdgeInsets.only(left: 5, right: 5),
                                                                                                              child: Text(
                                                                                                                '$exp',
                                                                                                                style: TextStyle(
                                                                                                                  color: Color(expText),
                                                                                                                  fontSize: 12,
                                                                                                                  fontWeight: FontWeight.bold,
                                                                                                                ),
                                                                                                                textAlign: TextAlign.center,
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  )
                                                                                                ],
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                );
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                );
                                                              } else
                                                                return Visibility(
                                                                    visible: false,
                                                                    child:
                                                                        CircularProgressIndicator());
                                                            })
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              }
                                              return Center(
                                                child: Visibility(
                                                    visible: true,
                                                    child: CircularProgressIndicator()),
                                              );
                                            }),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              
                  ],
                ),

                 Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100)),
                            width: 60,
                            height: 60,
                            child: Material(
                              borderRadius: BorderRadius.circular(100),
                              elevation: 0,
                              child: Ink(
                                decoration: const ShapeDecoration(
                                  color: Colors.green,
                                  shape: CircleBorder(),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    size: 40,
                                  ),
                                  color: Colors.white,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                toolRegistPage())).then((value) {
                                      setState(() {
                                        loadCategory = init();
                                        futureDefaultTool = loadDefaultTool();
                                        futureCustomTool = loadCustomTool();
                                      });
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                ]
              ),
            ),
          ),
          //bottomNavigationBar: BulidBottomAppBar(),
        ),
      ),
    );
  }
}

// List loadToolImage(imgurl) {
//   String baseUrl =
//       "http://test.elibtest.r-e.kr:8080/api/v1/media/tool/img?name=";

//   List imageList = [];
//   for (var img in imgurl) {
//     imageList.add(baseUrl + img);
//   }

//   return imageList;
// }

// Future<dynamic> ImageBox(BuildContext context, train) {

// }

// class ImageBox extends StatefulWidget {
//   ImageBox({
//     Key? key,
//     this.tool,
//   }) : super(key: key);

//   dynamic tool;

//   @override
//   State<ImageBox> createState() => _ImageBoxState();
// }

// class _ImageBoxState extends State<ImageBox> {
//   late List? imageList;
//   PageController controller = PageController();

//   final CarouselController _controller = CarouselController();
//   int _current = 0;

//   @override
//   void initState() {
//     super.initState();
//     init();
//   }

//   void init() async {
//     imageList = loadToolImage(widget.tool.imgUrl);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) =>  AlertDialog(
//         content: Center(
//             child: Column(
//           children: [
//             Container(
//               width: mediaWidth(context, 1),
//               height: mediaWidth(context, 1),
//               child: imageSlide(),
//             ),
//             SizedBox(height: 5),
//             imageIndicator(),

//             Text(
//               '$_current',
//               style: TextStyle(
//                 fontSize: 25,
//                 fontWeight: FontWeight.bold,
//               ),
//             )
//           ],
//         )),
//       ),
//     );
//   }

//   onchanged(int index) {
//     setState(() {
//       _current = index + 1;

//       if(_current == imageList!.length) {
//         print("----------");
//       }
//     });
//   }

//   Widget imageSlide() {
//     return PageView.builder(
//       onPageChanged: onchanged,
//       scrollDirection: Axis.horizontal,
//       controller: controller,
//       itemCount: imageList!.length,
//       itemBuilder: (context, index) {
//         return Container(
//             width: mediaWidth(context, 1),
//             height: mediaWidth(context, 1),
//             child: Image(
//               fit: BoxFit.fill,
//               image: NetworkImage(
//                 imageList![index],
//               ),
//             ));
//       },
//     );
//   }

//   Widget imageIndicator() {
//     return SmoothPageIndicator(
//         controller: controller, // PageController
//         count: imageList!.length,
//         effect: SwapEffect(
//             activeDotColor: Colors.green,
//             dotColor: Colors.grey.shade400,
//             radius: 10,
//             dotHeight: 10,
//             dotWidth: 10,
//         ), // your preferred effect
//         onDotClicked: (index) {});
//   }
// }

Future<dynamic> showDefault(BuildContext context, defaultTool) {
  String? locate = defaultTool.locate;
  if (locate == null || locate == "") {
    locate = "-";
  } else {
    if (locate.length > 15) {
      locate = locate.substring(0, 15);
      locate = "$locate...";
    }
  }

  String? exp = defaultTool.exp;
  if (exp == null || exp == "") {
    exp = "-";
  }

  String? mfd = defaultTool.mfd;
  if (mfd == null || mfd == "") {
    mfd = "-";
  }

  String? name = defaultTool.name;
  if (name == null || name == "") {
    name = "-";
  } else {
    if(name.length > 10) {
      name = name.substring(0,10) + "...";
    }
  }

  String? maker = defaultTool.maker;

  String? toolExplain = defaultTool.toolExplain;
  if (toolExplain == null || toolExplain == "") {
    toolExplain = "-";
  } else {
    if (toolExplain.length > 15) {
      toolExplain = toolExplain.substring(0, 15);
      toolExplain = "$toolExplain...";
    }
  }

  List? shopUrl = defaultTool.shopUrl;
  List? imgUrl = defaultTool.imgUrl;
  List? videoUrl = defaultTool.videoUrl;

  bool shopVisible = true;
  if (shopUrl!.isEmpty == true) {
    shopVisible = false;
  }

  bool imgVisible = true;
  if (imgUrl!.isEmpty == true) {
    imgVisible = false;
  }

  bool videoVisible = true;
  if (videoUrl!.isEmpty == true) {
    videoVisible = false;
  }

  bool moreVisible = false;
  if(imgVisible==true || videoVisible==true) {
    moreVisible = true;
  }

  double fontSize = 12;

  return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0),
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25)
            ),
            height: 500,
            width: 300,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: shopVisible,
                        child: 
                        Container(
                          width: 70,
                          child: TextButton(
                          onPressed: () {
                              Navigator.of(context).pop();
                              _launchInBrowser(shopUrl?[0]);
                            },
                            child: Text(
                              "구매하기",
                              style: TextStyle(
                                color: Colors.blue.shade400,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: moreVisible,
                        child: Container(
                          width: 60,
                          child: TextButton(
                          onPressed: () {
                              showMore(context, defaultTool, imgVisible, videoVisible);
                            },
                            child: Text(
                              "더보기",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ), 
                      ),
            
                      Spacer(flex:3),
            
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 30,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.7,
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.local_fire_department,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 15),
                    child: Text(
                      '${name}',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 70, 70, 70),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '보유수량',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 70, 70, 70),
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          defaultTool.count.toString(),
                          style: TextStyle(
                              color: const Color.fromARGB(255, 70, 70, 70),
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '위치',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 70, 70, 70),
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${locate}',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 70, 70, 70),
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '제조일자',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 70, 70, 70),
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${mfd}',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 70, 70, 70),
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '유통기한',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 70, 70, 70),
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${exp}',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 70, 70, 70),
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '상세정보',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 70, 70, 70),
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${toolExplain}',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 70, 70, 70),
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 25, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            height: 35,
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            editDefaultToolPage(
                                              tool: defaultTool,
                                              count: defaultTool.count,
                                            ))).then((value) {
                                });
                              },
                              child: Text(
                                "도구편집",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.grey),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                )),
                              ),
                            ),
                          ),
                          Container(
                            height: 35,
                            child: ElevatedButton(
                              onPressed: () async {
                                showModalBottomSheet(
                                    elevation: 0.0, //이거추가하기
                                    barrierColor: Colors.black.withOpacity(0.2),
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        //color: Color.fromARGB(255, 255, 255, 255).withOpacity(1),
                                        height: 130,
                                        child: Center(
                                          child: Column(children: [
                                            
                                            Column(
                                              children: [
                                                Container(
                                                  width: mediaWidth(
                                                      context, 0.9),
                                                  height: 50,
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      final storage =
                                                          FlutterSecureStorage();
                                                      final accessToken =
                                                          await storage.read(
                                                              key:
                                                                  'ACCESS_TOKEN');
                                                      print(
                                                          "...............");
            
                                                      var dio =
                                                          await authDio();
                                                      dio.options.headers[
                                                              'Authorization'] =
                                                          '$accessToken';
            
                                                      try {
                                                        final response =
                                                            await dio.delete(
                                                                '/api/v1/user/tool/default',
                                                                queryParameters: {
                                                              'toolId':
                                                                  defaultTool
                                                                      .id
                                                            });
            
                                                        if (response
                                                                .statusCode ==
                                                            200) {
                                                          await Navigator
                                                              .pushAndRemoveUntil(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          BulidBottomAppBar(
                                                                            index: 0,
                                                                          )),
                                                                  (route) =>
                                                                      false);
                                                        }
                                                      } catch (e) {
                                                        Navigator.of(context).pop(); 
                                                        Navigator.of(context).pop(); 
                                                        showDialog(
                                                          context: context,
                                                          barrierDismissible:
                                                              true, //바깥 영역 터치시 닫을지 여부 결정
                                                          builder:
                                                              ((context) {
                                                            return AlertDialog(
                                                              backgroundColor: Colors.white,
                                                              insetPadding:
                                                                  EdgeInsets
                                                                      .all(0),
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(5))),
                                                              title:
                                                                  Text("오류"),
                                                              content:
                                                                  Container(
                                                                width:
                                                                    mediaWidth(
                                                                        context,
                                                                        0.7),
                                                                child:
                                                                    Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          0),
                                                                  child: Text(
                                                                    '삭제할 수 없는 도구입니다.',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          17,
                                                                    ),
                                                                    //textAlign: TextAlign.center,
                                                                  ),
                                                                ),
                                                              ),
                                                              actionsAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              actions: <Widget>[
                                                                Container(
                                                                  height: 40,
                                                                  width: mediaWidth(
                                                                      context,
                                                                      0.7),
                                                                  child:
                                                                      ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(context)
                                                                          .pop(); //창 닫기
                                                                    },
                                                                    child:
                                                                        Text(
                                                                      '확인',
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            Colors.white,
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                      ),
                                                                    ),
                                                                    style:
                                                                        ButtonStyle(
                                                                      backgroundColor: MaterialStateProperty.all(Colors
                                                                          .grey
                                                                          .shade400),
                                                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(0),
                                                                      )),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          }),
                                                        );
                                                      }
                                                    },
                                                    child: Text(
                                                      "도구 삭제",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(
                                                                  Color.fromARGB(255, 235, 235, 235)),
                                                      shape: MaterialStateProperty.all<
                                                              RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              side:
                                                                  BorderSide(
                                                                color: Color.fromARGB(255, 235, 235, 235),
                                                              ))),
                                                    ),
                                                  ),
                                                ),
            
                                                Container(
                                                  height: 10,
                                                ),
            
                                                Container(
                                                  width: mediaWidth(
                                                      context, 0.9),
                                                  height: 50,
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      "취소",
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(Colors
                                                                    .grey
                                                                    .shade100),
                                                      shape: MaterialStateProperty.all<
                                                              RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              side:
                                                                  BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade100,
                                                              ))),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ]),
                                        ),
                                      );
                                    });
                              },
                              child: Text(
                                "도구삭제",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                )),
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
            
          ),
          elevation: 10.0,
          //backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
        );
      });
}

Future<dynamic> showMore(BuildContext context, defaultTool, imgVisible, videoVisible) {

  return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white.withOpacity(0),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              color: Color.fromARGB(255, 255, 255, 255).withOpacity(0),
              height: 120,
              width: mediaWidth(context, 1),
              child: AlertDialog(
                  backgroundColor: Colors.white.withOpacity(0),
                  insetPadding: EdgeInsets.all(0),
                  contentPadding: EdgeInsets.zero,
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: imgVisible,
                        child: Container(
                          width: mediaWidth(context, 0.9),
                          height: 50,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              showDefaultImg(context, defaultTool);
                            },
                            icon: Icon(
                              Icons.image, 
                              size: 18,
                              color: Colors.grey,
                            ), 
                            label: Text(
                              "상세사진 보기",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        ),
                      ), 
        
                      Container(
                        height: 10,
                      ),
        
                      Visibility(
                        visible: videoVisible,
                        child: Container(
                          width: mediaWidth(context, 0.9),
                          height: 50,
                          child: TextButton.icon(
                              onPressed: () {
                                  Navigator.of(context).pop();
                                  showDefaultVideo(context, defaultTool);
                                },
                                icon: Icon(
                                  Icons.videocam, 
                                  size: 18,
                                  color: Colors.grey,
                                ), 
                                label: Text(
                                  "상세영상 시청하기",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10)
                          ),
                        ),
                      ), 
                    ],
                  )),
            ),
          ),
        );
      });
}

Future<dynamic> showDefaultImg(BuildContext context, defaultTool) {
  List? imgUrl = defaultTool.imgUrl;

  return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.white.withOpacity(0),
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white.withOpacity(0),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: AlertDialog(
                backgroundColor: Colors.white.withOpacity(0),
                insetPadding: EdgeInsets.all(0),
                contentPadding: EdgeInsets.zero,
                content: Container(
                  height: mediaHeight(context, 1),
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ImageBox(defaultTool: defaultTool),
                    ],
                  ),
                )),
          ),
        );
      });
}

List loadTrainImage(imgurl) {
  String baseUrl =
      "https://elib.elib-app-service.o-r.kr:8080/api/v1/media/tool/img?name=";

  List imageList = [];
  for (var img in imgurl) {
    imageList.add(baseUrl + img);
  }

  return imageList;
}

class ImageBox extends StatefulWidget {
  ImageBox({Key? key, this.defaultTool}) : super(key: key);

  dynamic defaultTool;

  @override
  State<ImageBox> createState() => _ImageBoxState();
}

class _ImageBoxState extends State<ImageBox> {
  late List? imageList;
  PageController controller = PageController();

  final CarouselController _controller = CarouselController();
  int _current = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    imageList = loadTrainImage(widget.defaultTool.imgUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        Container(
          width: mediaWidth(context, 1),
          height: mediaWidth(context, 1),
          color: Colors.transparent,
          child: Stack(children: [
            imageSlide(),
            //imageIndicator(),
          ]),
        ),
      ],
    ));
  }

  onchanged(int index) {
    setState(() async {
      _current = index + 1;
    });
  }

  Widget imageSlide() {
    return PageView.builder(
      onPageChanged: onchanged,
      scrollDirection: Axis.horizontal,
      controller: controller,
      itemCount: imageList!.length,
      itemBuilder: (context, index) {
        return Stack(children: [
          Container(
              width: mediaWidth(context, 1),
              height: mediaWidth(context, 1),
              child: InteractiveViewer(
                child: Image(
                  fit: BoxFit.fitWidth,
                  image: NetworkImage(
                    imageList![index],
                  ),
                ),
              )),
          Align(
            alignment: Alignment.center,
            child: IconButton(
              icon: const Icon(
                Icons.zoom_in,
                color: Colors.black45,
                size: 50,
              ),
              onPressed: () {
                _launchInBrowser(imageList![index]);
              },
            ),
          ),
        ]);
      },
    );
  }

  Widget imageIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SmoothPageIndicator(
          controller: controller, // PageController
          count: imageList!.length,
          effect: SwapEffect(
            activeDotColor: Colors.green,
            dotColor: Colors.grey.shade400,
            radius: 10,
            dotHeight: 10,
            dotWidth: 10,
          ), // your preferred effect
          onDotClicked: (index) {}),
    );
  }
}

Future<dynamic> showDefaultVideo(BuildContext context, defaultTool) {
  List? videoUrl = defaultTool.videoUrl;

  return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.white.withOpacity(0),
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white.withOpacity(0),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: AlertDialog(
                backgroundColor: Colors.white.withOpacity(0),
                insetPadding: EdgeInsets.all(0),
                contentPadding: EdgeInsets.zero,
                content: Container(
                  height: mediaHeight(context, 1),
                  width: mediaWidth(context, 1),
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      VideoBox(defaultTool: defaultTool),
                    ],
                  ),
                )),
          ),
        );
      });
}

List loadToolVideo(videourl) {
  String baseUrl =
      "https://elib.elib-app-service.o-r.kr:8080/api/v1/media/tool/video?name=";

  List videoList = [];
  for (var video in videourl) {
    videoList.add(baseUrl + video);
  }

  print(videoList);

  return videoList;
}

class VideoBox extends StatefulWidget {
  VideoBox({Key? key, this.defaultTool}) : super(key: key);

  dynamic defaultTool;

  @override
  State<VideoBox> createState() => _VideoBoxState();
}

int videoNumber = 0;
var count;

class _VideoBoxState extends State<VideoBox> {
  late List? videoList;

  @override
  void initState() {
    super.initState();
    init();
    videoNumber = videoList!.length;
    count = List.generate(videoNumber, (index) => 0);
  }

  void init() async {
    videoList = loadToolVideo(widget.defaultTool.videoUrl);
  }

  @override
  Widget build(BuildContext context) {
    //dynamic train = widget.train;

    return Center(
        child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        Container(
          height: mediaHeight(context, 0.3),
          width: mediaWidth(context, 1),
          color: Color.fromARGB(255, 255, 255, 255).withOpacity(0),
          child: ListView.builder(
              itemCount: videoList?.length,
              itemBuilder: (_, index) {
                return VideoPage(
                  videoUrl: videoList?[index],
                  index: index,
                  defaultTool: widget.defaultTool,
                );
              }),
        ),
      ],
    ));
    //return VideoPage(videoUrl: videoList?[0]);
  }
}

//videoPage 띄우는
class VideoPage extends StatefulWidget {
  final String videoUrl;
  final int index;
  dynamic defaultTool;

  VideoPage({
    Key? key,
    required this.videoUrl,
    required this.index,
    required this.defaultTool,
  }) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;

  Future initializeVideo() async {
    Uri videoUri = Uri.parse(widget.videoUrl);
    videoPlayerController = VideoPlayerController.networkUrl(videoUri);
    await videoPlayerController.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: false,
      looping: false,
    );
    setState(() {});
  }

  @override
  void initState() {
    initializeVideo();
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (chewieController == null) {
      return SizedBox(
        width: 50,
        height: 50,
        child: Visibility(
          visible: false,
          child: CircularProgressIndicator(),
        ),
      );
    } else
      return Column(children: [
        Container(
          height: mediaHeight(context, 0.3),
          width: mediaWidth(context, 1),
          child: Chewie(
            controller: chewieController!,
          ),
        ),
      ]);
  }
}

Future<dynamic> showCustom(BuildContext context, customTool) {
  String? locate = customTool.locate;
  if (locate == null || locate == "") {
    locate = "-";
  } else {
    if (locate.length > 15) {
      locate = locate.substring(0, 15);
      locate = "$locate...";
    }
  }

  String? exp = customTool.exp;
  if (exp == null || exp == "") {
    exp = "-";
  }

  String? mfd = customTool.mfd;
  if (mfd == null || mfd == "") {
    mfd = "-";
  }

  String? name = customTool.name;
  if (name == null || name == "") {
    name = "-";
  } else {
    if(name.length > 10) {
      name = name.substring(0,10) + "...";
    }
  }


  String? toolExplain = customTool.toolExplain;
  if (toolExplain == null || toolExplain == "") {
    toolExplain = "-";
  } else {
    if (toolExplain.length > 15) {
      toolExplain = toolExplain.substring(0, 15);
      toolExplain = "$toolExplain...";
    }
  }

  double fontSize = 12;

  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.3),
    barrierDismissible: true,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: Colors.white.withOpacity(0),
      contentPadding: EdgeInsets.zero,
      content: Container(
        decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25)
        ),
        height: 500,
        width: 300,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1.7,
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.medical_services,
                      color: Colors.grey,
                      size: 30,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 15),
                child: Text(
                  '${name}',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 70, 70, 70),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 15, bottom: 15, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '보유수량',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 70, 70, 70),
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      customTool.count.toString(),
                      style: TextStyle(
                          color: const Color.fromARGB(255, 70, 70, 70),
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 15, bottom: 15, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '위치',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 70, 70, 70),
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${locate}',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 70, 70, 70),
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 15, bottom: 15, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '제조일자',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 70, 70, 70),
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${mfd}',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 70, 70, 70),
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 15, bottom: 15, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '유통기한',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 70, 70, 70),
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${exp}',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 70, 70, 70),
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 15, bottom: 15, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '상세정보',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 70, 70, 70),
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${toolExplain}',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 70, 70, 70),
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 25, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        height: 35,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => editCustomToolPage(
                                          tool: customTool,
                                          count: customTool.count,
                                        ))).then((value) {});
                          },
                          child: Text(
                            "도구편집",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.grey),
                            shape:
                                MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            )),
                          ),
                        ),
                      ),
                      Container(
                        height: 35,
                        child: ElevatedButton(
                          onPressed: () async {
                            showModalBottomSheet(
                              elevation: 0.0,
                              barrierColor: Colors.black.withOpacity(0.2),
                              backgroundColor: Colors.transparent,
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    //color: Color.fromARGB(255, 255, 255, 255).withOpacity(0),
                                    height: 130,
                                    child: Center(
                                      child: Column(children: [
                                       
                                        Column(
                                          children: [
                                            Container(
                                              width: mediaWidth(context, 0.9),
                                              height: 50,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  final storage =
                                                      FlutterSecureStorage();
                                                  final accessToken =
                                                      await storage.read(
                                                          key: 'ACCESS_TOKEN');
                                                  print("...............");
        
                                                  var dio = await authDio();
                                                  dio.options.headers[
                                                          'Authorization'] =
                                                      '$accessToken';
        
                                                  try {
                                                    final response = await dio
                                                        .delete(
                                                            '/api/v1/user/tool/custom',
                                                            queryParameters: {
                                                          'toolId': customTool.id
                                                        });
        
                                                    if (response.statusCode ==
                                                        200) {
                                                      await Navigator
                                                          .pushAndRemoveUntil(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      BulidBottomAppBar(
                                                                        index:
                                                                            0,
                                                                      )),
                                                              (route) => false);
                                                    }
                                                  } catch (e) {
                                                    Navigator.of(context).pop(); 
                                                    Navigator.of(context).pop(); 
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible:
                                                          true, //바깥 영역 터치시 닫을지 여부 결정
                                                      builder: ((context) {
                                                        return AlertDialog(
                                                          backgroundColor: Colors.white,
                                                          insetPadding:
                                                              EdgeInsets.all(0),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          5))),
                                                          title: Text("오류"),
                                                          content: Container(
                                                            width: mediaWidth(
                                                                context, 0.7),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          0),
                                                              child: Text(
                                                                '삭제할 수 없는 도구입니다.',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 17,
                                                                ),
                                                                //textAlign: TextAlign.center,
                                                              ),
                                                            ),
                                                          ),
                                                          actionsAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          actions: <Widget>[
                                                            Container(
                                                              height: 40,
                                                              width: mediaWidth(
                                                                  context, 0.7),
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(); //창 닫기
                                                                },
                                                                child: Text(
                                                                  '확인',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                  ),
                                                                ),
                                                                style:
                                                                    ButtonStyle(
                                                                  backgroundColor:
                                                                      MaterialStateProperty.all(Colors
                                                                          .grey
                                                                          .shade400),
                                                                  shape: MaterialStateProperty.all<
                                                                          RoundedRectangleBorder>(
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(0),
                                                                  )),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }),
                                                    );
                                                  }
                                                },
                                                child: Text(
                                                  "도구 삭제",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Color.fromARGB(255, 235, 235, 235)),
                                                  shape: MaterialStateProperty
                                                      .all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              side: BorderSide(
                                                                color:
                                                                    Color.fromARGB(255, 235, 235, 235),
                                                              ))),
                                                ),
                                              ),
                                            ),

                                            Container(
                                                  height: 10,
                                            ),

                                            Container(
                                              width: mediaWidth(context, 0.9),
                                              height: 50,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "취소",
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.grey.shade100),
                                                  shape: MaterialStateProperty
                                                      .all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              side: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade100,
                                                              ))),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ]),
                                    ),
                                  );
                                });
                          },
                          child: Text(
                            "도구삭제",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                            shape:
                                MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            )),
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
      elevation: 10.0,
      //backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
    ),
  );
}
