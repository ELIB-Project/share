import 'package:elib_project/pages/tool_regist.dart';
import 'package:elib_project/pages/view.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io'; //쿠키
import 'package:elib_project/auth_dio.dart';

double appBarHeight = 40;
double mediaHeight(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.height - appBarHeight) * scale;
double mediaWidth(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.width) * scale;

double topFontSize = 20;

String textA = "";
String textB = "";
String textC = "";
String textD = "";
String textE = "";

Color colorB = Colors.grey.shade600;
Color colorC = Colors.grey.shade600;
Color colorD = Colors.grey.shade600;

class trainList {
  final int id;
  final String? name;
  final List? imgUrl;
  final List? videoUrl;
  bool? imgComplete;
  bool? videoComplete;

  trainList({
    required this.id,
    required this.name,
    required this.imgUrl,
    required this.videoUrl,
    required this.imgComplete,
    required this.videoComplete,
  });

  factory trainList.fromJson(Map<String, dynamic> json) {
    return trainList(
      id: json['id'],
      name: json['name'],
      imgUrl: json['imgUrl'],
      videoUrl: json['videoUrl'],
      imgComplete: json['imgComplete'],
      videoComplete: json['videoComplete'],
    );
  }
}


int? allTrainCount;
int? trainCount;

Future<int> loadTrainCount() async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/user/train/count');

  if (response.statusCode == 200) {
    return response.data;
  } else {
    throw Exception('fail');
  }
}

Future<List<trainList>> loadTrainList() async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  print("access ${accessToken}");

  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/train');

  if (response.statusCode == 200) {
    
    List<dynamic> data = response.data;
    List<trainList> list =
        data.map((dynamic e) => trainList.fromJson(e)).toList();

    init() async {
      allTrainCount = list.length;
    }
    init();

    trainCount = (allTrainCount! - await loadTrainCount());

    void text() async {
    if(trainCount! == 0) {
      textA = "";
      textB = "모든 훈련을 ";
      textC = "이수완료 ";
      textD = "했습니다.";
      textE = "";

      colorB = Colors.grey.shade600;
      colorC = Colors.green;
      colorD = Colors.grey.shade600;
    } else if (trainCount! > 0) {
      textA = "총 ";
      textB = "$trainCount";
      textC = "개의 훈련이 ";
      textD = "미이수";
      textE = " 상태입니다.";

      colorB = Colors.red;
      colorD = Colors.red;
    } 
  }
  text();

    return list;
  } else {
    throw Exception('Failed to Load');
  }
}

class trainPage extends StatefulWidget {
  const trainPage({super.key});

  @override
  State<trainPage> createState() => _trainPageState();
}

class _trainPageState extends State<trainPage>{
  late Future<List<trainList>> futureTrainList;

  void viewTrain(trainList) {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => trainRegistpage(
              train: trainList,
            )))
        .then((value) {
      setState(() {
        futureTrainList = loadTrainList();
      });
    });
  }

  @override
  void initState() {
    futureTrainList = loadTrainList();
    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {
    

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorSchemeSeed: Color.fromARGB(255, 255, 255, 255),
            useMaterial3: true),
        home: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
              appBar: AppBar(
                title: Title(
                    color: Color.fromRGBO(87, 87, 87, 1),
                    child: Text(
                      '훈련 관리',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ),
              body: SafeArea(
                  top: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: mediaHeight(context, 0.01),
                      ),

                      //미이수 내역
                      Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Container(
                            width: mediaWidth(context, 1),
                            height: mediaHeight(context, 0.07),
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
                                  const BorderRadius.all(Radius.circular(10)),
                              color: Color(0xFFFFF3B2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FutureBuilder<List<trainList>>(
                                  future: futureTrainList,
                                  builder: (context, snapshot) {
                                    return Text.rich(TextSpan(children: [
                                      TextSpan(
                                          text: textA,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: topFontSize,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      TextSpan(
                                          text: textB,
                                          style: TextStyle(
                                            color: colorB,
                                            fontSize: topFontSize,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      TextSpan(
                                          text: textC,
                                          style: TextStyle(
                                            color: colorC,
                                            fontSize: topFontSize,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      TextSpan(
                                          text: textD,
                                          style: TextStyle(
                                            color: colorD,
                                            fontSize: topFontSize,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      TextSpan(
                                          text: textE,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: topFontSize,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ]));
                                  }
                                ),
                              ],
                            ),
                          )),

                      SizedBox(
                        height: mediaHeight(context, 0.03),
                      ),

                      //훈련 리스트 출력부분
                      Expanded(
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: Column(
                            children: [
                              FutureBuilder<List<trainList>>(
                                  future: futureTrainList,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError)
                                      return Text('${snapshot.error}');
                                    else if (snapshot.hasData)
                                      return Column(
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 25, right: 25),
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount:
                                                          snapshot.data?.length,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemBuilder:
                                                          (context, i) {
                                                        String? name;
                                                        if (snapshot.data?[i]
                                                                    .name ==
                                                                null ||
                                                            snapshot.data?[i]
                                                                    .name ==
                                                                "") {
                                                          name = "test";
                                                        } else {
                                                          name = snapshot
                                                              .data?[i].name;
                                                        }

                                                        List? videoUrl =
                                                            snapshot.data?[i]
                                                                .videoUrl;
                                                        List? imgUrl = snapshot
                                                            .data?[i].imgUrl;

                                                        bool videoVisible =
                                                            true;
                                                        if (videoUrl!.isEmpty ==
                                                            true) {
                                                          videoVisible = false;
                                                        }

                                                        bool imgVisible = true;
                                                        if (imgUrl!.isEmpty ==
                                                            true) {
                                                          imgVisible = false;
                                                        }

                                                        IconData? iconName;
                                                        int iconColor;

                                                        bool? imgComplete = snapshot.data?[i].imgComplete;
                                                        bool? videoComplete = snapshot.data?[i].videoComplete;
                                                        if(imgComplete == true && videoComplete == true) {
                                                          iconName = Icons.check_circle;
                                                        iconColor = 0xFF38AE5D;
                                                        } else {
                                                          iconName = Icons.report_outlined;
                                                          iconColor = 0xFFF16969;
                                                        }

                                                        return InkWell(
                                                            onTap: () {
                                                              viewTrain(snapshot.data?[i]);
                                                            },
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              15,
                                                                          bottom:
                                                                              15),
                                                                      child:
                                                                          Text(
                                                                        '$name ',
                                                                        style:
                                                                            TextStyle(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade600,
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Visibility(
                                                                      visible:
                                                                          imgVisible,
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .description,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade400,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                    Visibility(
                                                                      visible:
                                                                          videoVisible,
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .videocam,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade400,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Icon(
                                                                  iconName,
                                                                  color: Color(
                                                                      iconColor),
                                                                  size: 25,
                                                                ),
                                                              ],
                                                            ));
                                                      })),
                                            ],
                                          ),
                                        ],
                                      );
                                    return Visibility(
                                      visible: false,
                                      child: CircularProgressIndicator())
                                      ;
                                  }),
                            ],
                          ),
                        ),
                      )
                    ],
                  ))),
        ));
  }
}
