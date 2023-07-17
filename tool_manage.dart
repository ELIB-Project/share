import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io'; //쿠키
import 'package:elib_project/auth_dio.dart';
import 'package:elib_project/pages/tool_regist.dart';
import 'package:elib_project/pages/edit_default_tool.dart';
import 'package:elib_project/pages/edit_custom_tool.dart';
import 'package:elib_project/models/bottom_app_bar.dart';

double appBarHeight = 70;
double mediaHeight(BuildContext context, double scale) => (MediaQuery.of(context).size.height - appBarHeight) * scale;
double mediaWidth(BuildContext context, double scale) => (MediaQuery.of(context).size.width) * scale;

String searchText = "";

class defaultTool {
  final int toolId;
  final String? name;
  final String? shopUrl;
  final String? videoUrl;
  final String toolExplain;
  final int count;
  final String? locate;
  final String? exp;

  defaultTool({
    required this.toolId,
    required this.name,
    required this.shopUrl,
    required this.videoUrl,
    required this.toolExplain,
    required this.count,
    required this.locate,
    required this.exp,
  });

  factory defaultTool.fromJson(Map<String, dynamic> json) {
    return defaultTool(
      toolId: json['toolId'],
      name: json['name'],
      shopUrl: json['shopUrl'],
      videoUrl: json['videoUrl'],
      toolExplain: json['toolExplain'],
      count: json['count'],
      locate: json['locate'],
      exp: json['exp'],
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

  customTool({
    required this.id,
    required this.name,
    required this.toolExplain,
    required this.count,
    required this.locate,
    required this.exp,
  });

  factory customTool.fromJson(Map<String, dynamic> json) {
    return customTool(
      id: json['id'],
      name: json['name'],
      toolExplain: json['toolExplain'],
      count: json['count'],
      locate: json['locate'],
      exp: json['exp'],
    );
  }
}

Future<List<defaultTool>> loadDefaultTool() async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  print("access ${accessToken}");

  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/user/tool/default');

  if (response.statusCode == 200) {
    List<dynamic> data = response.data;
    List<defaultTool> list =
        data.map((dynamic e) => defaultTool.fromJson(e)).toList();

    //토큰확인용
    final accessToken = await storage.read(key: 'ACCESS_TOKEN');
    final refreshToken = await storage.read(key: 'REFRESH_TOKEN');
    print("newaccess ${accessToken}");
    print("newrefresh ${refreshToken}");

    return list;
  } else {
    throw Exception('Failed to Load');
  }
}

Future<List<customTool>> loadCustomTool() async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');

  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/user/tool/custom');

  if (response.statusCode == 200) {
    List<dynamic> data = response.data;
    List<customTool> list =
        data.map((dynamic e) => customTool.fromJson(e)).toList();
    return list;
  } else {
    throw Exception('Failed to Load');
  }
}

class toolManagePage extends StatefulWidget {
  const toolManagePage({super.key});

  @override
  State<toolManagePage> createState() => _toolManagePageState();
}

class _toolManagePageState extends State<toolManagePage> {
  late Future<List<defaultTool>> futureDefaultTool;
  late Future<List<customTool>> futureCustomTool;

  @override
  void initState() {
    super.initState();
    futureDefaultTool = loadDefaultTool();
    futureCustomTool = loadCustomTool();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorSchemeSeed: Color.fromARGB(255, 255, 255, 255), useMaterial3: true),
      home: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false, //키보드 올라올때 오버플로우 방지
          appBar: 
          PreferredSize(
            preferredSize: Size.fromHeight(appBarHeight),
            child: AppBar(
              title: Title(
                  color: Color.fromRGBO(87, 87, 87, 1),
                  child: Text(
                    '도구 관리',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 5, bottom: 5),
                  child: IconButton(
                    icon: Icon(
                      Icons.add_circle_outline_outlined,
                      size: 35,
                    ),
                    onPressed: () {
                      Navigator.push(context,
                        MaterialPageRoute(
                           builder: (context) => toolRegistPage())).then((value) {
                              setState(() {
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
          ),
          body: SafeArea(
            top: true,
            child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Container(
                height: mediaHeight(context, 1),
                child: Column(
                  children: [
                    SizedBox(
                      height: mediaHeight(context, 0.01),
                    ),
                    //검색창
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Container(
                        height: mediaHeight(context, 0.05),
                        decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Theme.of(context).shadowColor .withOpacity(0.3),
                                offset: const Offset(0, 3),
                                blurRadius: 5.0)
                          ],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15.0)),
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderRadius:BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(width: 1, color: Colors.grey.shade500),
                            ),
                            suffixIcon: Icon(Icons.search), //검색 아이콘 추가
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
                      height: mediaHeight(context, 0.01),
                    ),

                    //도구 리스트 출력부분
                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          children: [
                            FutureBuilder<List<defaultTool>>(
                                future: futureDefaultTool,
                                builder: (context, snapshot) {
                                  if (snapshot.hasError)
                                    return Text('${snapshot.error}');
                                  else if (snapshot.hasData) {
                                    return Column(
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.only(top: 0.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(left: 10, top: 10),
                                                  child: Text.rich(
                                                      TextSpan(children: [
                                                    TextSpan(
                                                        text: 'Default',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                  ])),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(left: 15, right: 15),
                                                  child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width, //fullsize
                                                      child: ListView.builder(
                                                          shrinkWrap: true,
                                                          physics: const NeverScrollableScrollPhysics(),
                                                          itemCount: snapshot.data?.length,
                                                          scrollDirection: Axis.vertical,
                                                          itemBuilder: (context, i) {
                                                            int countColor;
                    
                                                            if (snapshot.data?[i].count == 0) {
                                                              countColor = 0xFFF93426;
                                                            } else {
                                                              countColor = 0xFFFFDF0E;
                                                            }
                    
                                                            String? name;
                                                            if (snapshot.data?[i].name == null || snapshot.data?[i].name =="") {
                                                              name = "";
                                                            } else {
                                                              name = snapshot.data?[i].name;
                                                            }
                    
                                                            String? exp;
                                                            if (snapshot.data?[i].exp == null || snapshot.data?[i].exp =="") {
                                                              exp = "-";
                                                            } else {
                                                              exp = snapshot.data?[i].exp;
                                                            }
                    
                                                            String? locate;
                                                            if (snapshot.data?[i].locate == null || snapshot.data?[i].locate =="") {
                                                              locate = "-";
                                                            } else {
                                                              locate = snapshot.data?[i].locate;
                    
                                                              if (locate!.length > 5) {
                                                                locate = locate?.substring(0, 5);
                                                                locate = "$locate...";
                                                              }
                                                            }
                    
                                                            if (searchText!.isNotEmpty && !snapshot.data![i].name!.toLowerCase().contains(searchText.toLowerCase())) {
                                                              return SizedBox.shrink();
                                                            } else
                                                              return InkWell(
                                                                onTap: () {
                                                                  showDefault(context, snapshot.data?[i]);
                                                                },
                                                                child: Column(
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(right: 15, left: 5, top: 5, bottom: 5),
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
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(bottom: 2),
                                                                                    child: Text.rich(TextSpan(children: [
                                                                                      TextSpan(
                                                                                          text: '$name',
                                                                                          style: TextStyle(
                                                                                            color: Colors.grey,
                                                                                            fontSize: 18,
                                                                                            fontWeight: FontWeight.bold,
                                                                                          )),
                                                                                    ])),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(top: 2),
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
                                                                                                '${snapshot.data?[i].count}개',
                                                                                                style: TextStyle(
                                                                                                  color: Colors.white,
                                                                                                  fontSize: 12,
                                                                                                ),
                                                                                                textAlign: TextAlign.center,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.only(right: 10),
                                                                                          child: Container(
                                                                                            height: 20,
                                                                                            width: 90,
                                                                                            decoration: BoxDecoration(
                                                                                              border: Border.all(
                                                                                                width: 1,
                                                                                                color: Colors.green,
                                                                                              ),
                                                                                              borderRadius: BorderRadius.circular(5),
                                                                                              color: Colors.green,
                                                                                            ),
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsets.only(left: 5, right: 5),
                                                                                              child: Text(
                                                                                                '$locate',
                                                                                                style: TextStyle(
                                                                                                  color: Colors.white,
                                                                                                  fontSize: 12,
                                                                                                ),
                                                                                                textAlign: TextAlign.center,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Container(
                                                                                          height: 20,
                                                                                          width: 90,
                                                                                          decoration: BoxDecoration(
                                                                                            border: Border.all(
                                                                                              width: 1,
                                                                                              color: Color(0xFFA2A2A2),
                                                                                            ),
                                                                                            borderRadius: BorderRadius.circular(5),
                                                                                            color: Color(0xFFA2A2A2),
                                                                                          ),
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.only(left: 5, right: 5),
                                                                                            child: Text(
                                                                                              '$exp',
                                                                                              style: TextStyle(
                                                                                                color: Colors.white,
                                                                                                fontSize: 12,
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
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10, top: 10),
                                                  child: Text.rich(
                                                      TextSpan(children: [
                                                    TextSpan(
                                                        text: 'Custom',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                  ])),
                                                ),
                                                FutureBuilder<List<customTool>>(
                                                    future: futureCustomTool,
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasError)
                                                        return Text(
                                                            '${snapshot.error}');
                                                      else if (snapshot
                                                          .hasData) {
                                                        return Padding(
                                                            padding:
                                                                const EdgeInsets.only(left: 15, right: 15),
                                                            child: SizedBox(
                                                              width: MediaQuery.of(context).size.width,
                                                              child: ListView.builder(
                                                                shrinkWrap: true,
                                                                physics: const NeverScrollableScrollPhysics(),
                                                                itemCount: snapshot .data?.length,
                                                                scrollDirection: Axis.vertical,
                                                                itemBuilder: (context,i) {
                                                                  int countColor;
                    
                                                                   if (snapshot.data?[i].count == 0) {
                                                              countColor = 0xFFF93426;
                                                            } else {
                                                              countColor = 0xFFFFDF0E;
                                                            }
                    
                                                            String? name;
                                                            if (snapshot.data?[i].name == null || snapshot.data?[i].name =="") {
                                                              name = "";
                                                            } else {
                                                              name = snapshot.data?[i].name;
                                                            }
                    
                                                            String? exp;
                                                            if (snapshot.data?[i].exp == null || snapshot.data?[i].exp =="") {
                                                              exp = "-";
                                                            } else {
                                                              exp = snapshot.data?[i].exp;
                                                            }
                    
                                                            String? locate;
                                                            if (snapshot.data?[i].locate == null || snapshot.data?[i].locate =="") {
                                                              locate = "-";
                                                            } else {
                                                              locate = snapshot.data?[i].locate;
                    
                                                              if (locate!.length > 5) {
                                                                locate = locate?.substring(0, 5);
                                                                locate = "$locate...";
                                                              }
                                                            }
                    
                                                            if (searchText!.isNotEmpty && !snapshot.data![i].name!.toLowerCase().contains(searchText.toLowerCase())) {
                                                              return SizedBox.shrink();
                                                            } else
                                                                    return InkWell(
                                                                      onTap: () {
                                                                        showCustom(context,snapshot.data?[i]);
                                                                      },
                                                                      child:
                                                                        Column(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(top: 10, bottom: 10),
                                                                            child:
                                                                                Container(
                                                                              child: Row(
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(right: 15, left: 5, top: 5, bottom: 5),
                                                                                    child: Container(
                                                                                      decoration: BoxDecoration(
                                                                                        border: Border.all(
                                                                                          width: 1.7,
                                                                                          color: Colors.grey,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(100),
                                                                                      ),
                                                                                      child: Padding(
                                                                                        padding: EdgeInsets.all(10.0),
                                                                                        child: Icon(
                                                                                          Icons.medical_services,
                                                                                          color: Colors.grey,
                                                                                          size: 30,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(bottom: 2),
                                                                                        child: Text.rich(TextSpan(children: [
                                                                                          TextSpan(
                                                                                              text: '$name',
                                                                                              style: TextStyle(
                                                                                                color: Colors.grey,
                                                                                                fontSize: 18,
                                                                                                fontWeight: FontWeight.bold,
                                                                                              )),
                                                                                        ])),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(top: 2),
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
                                                                                                    '${snapshot.data?[i].count}개',
                                                                                                    style: TextStyle(
                                                                                                      color: Colors.white,
                                                                                                      fontSize: 12,
                                                                                                    ),
                                                                                                    textAlign: TextAlign.center,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(right: 10),
                                                                                              child: Container(
                                                                                                height: 20,
                                                                                                width: 90,
                                                                                                decoration: BoxDecoration(
                                                                                                  border: Border.all(
                                                                                                    width: 1,
                                                                                                    color: Colors.green,
                                                                                                  ),
                                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                                  color: Colors.green,
                                                                                                ),
                                                                                                child: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 5, right: 5),
                                                                                                  child: Text(
                                                                                                    '$locate',
                                                                                                    style: TextStyle(
                                                                                                      color: Colors.white,
                                                                                                      fontSize: 12,
                                                                                                    ),
                                                                                                    textAlign: TextAlign.center,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Container(
                                                                                              height: 20,
                                                                                              width: 90,
                                                                                              decoration: BoxDecoration(
                                                                                                border: Border.all(
                                                                                                  width: 1,
                                                                                                  color: Color(0xFFA2A2A2),
                                                                                                ),
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                                color: Color(0xFFA2A2A2),
                                                                                              ),
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsets.only(left: 5, right: 5),
                                                                                                child: Text(
                                                                                                  '$exp',
                                                                                                  style: TextStyle(
                                                                                                    color: Colors.white,
                                                                                                    fontSize: 12,
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
                                                                        ],
                                                                      ),
                                                                    );
                                                                },
                                                              ),
                                                            ));
                                                      } else
                                                        return CircularProgressIndicator();
                                                    })
                                              ],
                                            )),
                                      ],
                                    );
                                  }
                                  return CircularProgressIndicator();
                                }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          //bottomNavigationBar: BulidBottomAppBar(),
        ),
      ),
    );
  }
}

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

  String? toolExplain = defaultTool.toolExplain;
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
    builder: (BuildContext context) => AlertDialog(
      content: Container(
        height: 430,
        width: 250,
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
                defaultTool.name,
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
                padding: const EdgeInsets.only(
                    top: 25, bottom: 15, left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 35,
                      child: ElevatedButton(
                        onPressed: () async {
                          print(defaultTool.toolId);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => editDefaultToolPage(
                                        tool: defaultTool,
                                        count: defaultTool.count,
                                      ))).then((value) {});
                        },
                        child: Text(
                          "도구편집",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
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
                        onPressed: () async {},
                        child: Text(
                          "구매하기",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.lightBlue),
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
      elevation: 10.0,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
    ),
  );
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
    builder: (BuildContext context) => AlertDialog(
      content: Container(
        height: 430,
        width: 250,
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
                customTool.name,
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
                padding: const EdgeInsets.only(
                    top: 25, bottom: 15, left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 35,
                      child: ElevatedButton(
                        onPressed: () async {
                          print(customTool.id);
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
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 300,
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  )),
                                  child: Center(
                                      child: Center(
                                    child: Column(children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 80),
                                        child: Text(
                                          "삭제하시겠습니까?",
                                          style: TextStyle(
                                            fontSize: 23,
                                            color: Colors.grey.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 60,
                                            bottom: 50,
                                            left: 90,
                                            right: 90),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 40,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "취소",
                                                  style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                style: ButtonStyle(
                                                  shape: MaterialStateProperty
                                                      .all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7),
                                                              side: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade700,
                                                              ))),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 100,
                                              height: 40,
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
                                                  final response = await dio.delete(
                                                      '/api/v1/user/tool/custom',
                                                      queryParameters: {
                                                        'id': customTool.id
                                                      });

                                                  if (response.statusCode ==
                                                      200) {
                                                    Navigator.pushAndRemoveUntil(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (BuildContext context) =>
                                                                BulidBottomAppBar(
                                                                  index: 0,
                                                                )),
                                                        (route) => false);
                                                  } else {
                                                    throw Exception(
                                                        'Failed to Load');
                                                  }
                                                },
                                                child: Text(
                                                  "삭제",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.red),
                                                  shape: MaterialStateProperty
                                                      .all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7),
                                                              side: BorderSide(
                                                                color:
                                                                    Colors.red,
                                                              ))),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ]),
                                  )),
                                );
                              });
                        },
                        child: Text(
                          "도구삭제",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
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
      elevation: 10.0,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
    ),
  );
}
