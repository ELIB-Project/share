import 'dart:async';

import 'package:elib_project/pages/tool_manage.dart';
import 'package:elib_project/pages/tool_regist_qr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:ui';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io'; //쿠키
import 'package:elib_project/auth_dio.dart';
import 'package:uni_links/uni_links.dart';
import '../models/bottom_app_bar.dart';
import 'package:elib_project/pages/membermanagement_page.dart';

double appBarHeight = 70;
double mediaHeight(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.height - appBarHeight) * scale;
double mediaWidth(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.width) * scale;

class Score {
  final String name;
  final int totalScore;
  final int oldTotalScore;
  final int toolScore;
  final int oldToolScore;
  final int trainScore;
  final int oldTrainScore;

  Score({
    required this.name,
    required this.totalScore,
    required this.oldTotalScore,
    required this.toolScore,
    required this.oldToolScore,
    required this.trainScore,
    required this.oldTrainScore,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      name: json['name'],
      totalScore: json['totalScore'],
      oldTotalScore: json['oldTotalScore'],
      toolScore: json['toolScore'],
      oldToolScore: json['oldToolScore'],
      trainScore: json['trainScore'],
      oldTrainScore: json['oldTrainScore'],
    );
  }
}

class familyScore {
  final String name;
  final int totalScore;

  familyScore({
    required this.name,
    required this.totalScore,
  });

  factory familyScore.fromJson(Map<String, dynamic> json) {
    return familyScore(
      name: json['name'],
      totalScore: json['totalScore'],
    );
  }
}

Future<Score> loadScore() async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');

  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/user/score');

  if (response.statusCode == 200) {
    return Score.fromJson(response.data);
  } else {
    throw Exception('Failed to Load');
  }
}

Future<List<familyScore>> loadFamilyScore() async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');

  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/family/score');

  if (response.statusCode == 200) {
    List<dynamic> data = response.data;
    List<familyScore> list =
        data.map((dynamic e) => familyScore.fromJson(e)).toList();

    return list;
  } else {
    throw Exception('Failed to Load');
  }
}

class importTool {
  String? toolId;
  String? mfd;
  String? exp;
  String? locate;
  String? name;
  String? toolExplain;
  String? maker;

  importTool(String? toolId, String? mfd, String? exp, String? locate, String? name, String? toolExplain, String? maker){
    this.toolId = toolId;
    this.mfd = mfd;
    this.exp = exp;
    this.locate = locate;
    this.name = name;
    this.toolExplain = toolExplain;
    this.maker = maker;
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


class HomePage extends StatefulWidget {
  const HomePage({super.key, this.changeIndex});
  final changeIndex;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Score> futureScore;
  late Future<List<familyScore>> futureFamilyScore;

  Future<void> initUniLinks() async {
    StreamSubscription _sub;

    _sub = linkStream.listen((String? link) {
      // Parse the link and warn the user, if it is not correct
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        if (initialLink.contains("entercode")) {
          // Parse the URL string
          Uri uri = Uri.parse(initialLink);
          // Get the query parameters as a map
          Map<String, String> queryParameters = uri.queryParameters;
          print(queryParameters);
          String? entercode = queryParameters['code'];
          print(entercode);
          Navigator.pushNamed(context, '/entercode', arguments: entercode);
        } else if (initialLink.contains("qr")) {
          Uri uri = Uri.parse(initialLink);
          // Get the query parameters as a map
          Map<String, dynamic> queryParameters = uri.queryParameters;
          print(queryParameters);
          String? toolId = queryParameters['toolId'];
          String? mfd = queryParameters['mfd'];
          String? exp = queryParameters['exp'];

          importTool tool = importTool(toolId, mfd, exp, null, null, null, null);
          print("000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
          print(tool);

          try {
            final storage = FlutterSecureStorage();
            final accessToken = await storage.read(key: 'ACCESS_TOKEN');
            var dio = await authDio();
            dio.options.headers['Authorization'] = '$accessToken';

            final response = await dio.get('/api/v1/tool/${tool.toolId}');

            if (response.statusCode == 200) {
              print("query-------------------------------");
              print(response);

              checkTool check = checkTool.fromJson(response.data);
              tool.name = check.name;
              tool.toolExplain = check.toolExplain;
              tool.maker = check.maker;

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => qrDefaultToolPage(
                            tool: tool,
                            count: 0,
                          ))).then((value) {});
            }

          } catch(e) {
            print("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
          }
        }
      }
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }
  }

  @override
  void initState() {
    super.initState();
    initUniLinks();
    futureScore = loadScore();
    futureFamilyScore = loadFamilyScore();
  }

  @override
  Widget build(BuildContext context) {
    Future<Position> position = _getUserLocation();
    position.then((value) {
      if (value != null) {
        double latitude = value.latitude;
        double longitude = value.longitude;
        sendUserLocation(latitude, longitude);
        print("Latitude: $latitude, Longitude: $longitude");
      } else {
        print("Failed to get the position.");
      }
    }).catchError((error) {
      print("Error: $error");
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Color.fromARGB(255, 250, 250, 250),
          colorSchemeSeed: Color.fromARGB(0, 241, 241, 241),
          useMaterial3: true),
      home: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            top: true,
            child: FutureBuilder<Score>(
                future: futureScore,
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return Text('${snapshot.error}');
                  else if (snapshot.hasData) {
                    return Column(
                      children: <Widget>[
                        Container(
                          height: mediaHeight(context, 0.1),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 5,
                                bottom: 0,
                                child: Image.asset(
                                  'assets/image/eliblogo.png',
                                  width: mediaWidth(context, 0.3),
                                ),
                              ),
                              Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: mediaWidth(context, 1),
                                      child:
                                          Text('안녕하세요, ${snapshot.data?.name}님',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center),
                                    ),
                                    Container(
                                      width: mediaWidth(context, 1),
                                      child: Text(' 오늘의 우리집 안전점수는?',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.center),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: mediaHeight(context, 0.03)),
                        Column(
                          children: [
                            //그래프
                            SafetyScoreBox(
                              totalScore: snapshot.data?.totalScore,
                              oldTotalScore: snapshot.data?.oldTotalScore,
                            ),

                            ToolScoreBox(
                              toolScore: snapshot.data?.toolScore,
                              oldToolScore: snapshot.data?.oldToolScore,
                              changeIndex: widget.changeIndex,
                            ),

                            SizedBox(height: mediaHeight(context, 0.03)),

                            TrainingScoreBox(
                              trainScore: snapshot.data?.trainScore,
                              oldTrainScore: snapshot.data?.oldTrainScore,
                              changeIndex: widget.changeIndex,
                            ),

                            SizedBox(height: mediaHeight(context, 0.03)),

                            FutureBuilder<List<familyScore>>(
                                future: futureFamilyScore,
                                builder: (context, snapshot) {
                                  if (snapshot.hasError)
                                    return Text('${snapshot.error}');
                                  else if (snapshot.hasData) {
                                    return FamilyScoreBox(
                                      list: snapshot.data,
                                      changeIndex: widget.changeIndex,
                                    );
                                  } else
                                    return Visibility(
                                      visible: false,
                                      child: CircularProgressIndicator()
                                      );
                                }),

                            SizedBox(height: mediaHeight(context, 0.02)),
                          ],
                        ),
                      ],
                    );
                  }
                  return Visibility(
                    visible: false,
                    child: CircularProgressIndicator()
                    );
                }),
          ),
        ),
        //bottomNavigationBar: BulidBottomAppBar()
      ),
    );
  }
}

String toolText = "";

class ToolScoreBox extends StatefulWidget {
  const ToolScoreBox({
    Key? key,
    required this.toolScore,
    required this.oldToolScore,
    this.changeIndex,
  }) : super(key: key);

  final toolScore;
  final oldToolScore;
  final changeIndex;

  @override
  State<ToolScoreBox> createState() => _ToolScoreBoxState();
}

class _ToolScoreBoxState extends State<ToolScoreBox>
    with TickerProviderStateMixin {
  double percentage = 0.0;
  double newPercentage = 0.0;
  double gapPercentage = 0.0;
  double newgapPercentage = 0.0;

  late AnimationController percentageAnimationController;

  void initState() {
    super.initState();

    percentageAnimationController = AnimationController(
        vsync: this, duration: new Duration(milliseconds: 10000))
      ..addListener(() {
        setState(() {
          percentage = lerpDouble(
              percentage, newPercentage, percentageAnimationController.value)!;
          gapPercentage = lerpDouble(gapPercentage, newgapPercentage,
              percentageAnimationController.value)!;
        });
      });

    setState(() {
      percentage = newPercentage;
      newPercentage = (widget.toolScore) / 100;

      double gap = 0.0;
      if (widget.toolScore > widget.oldToolScore) {
        gap = widget.toolScore.toDouble() - widget.oldToolScore.toDouble();
      } else {
        gap = widget.oldToolScore.toDouble() - widget.toolScore.toDouble();
      }
      gapPercentage = newgapPercentage;
      newgapPercentage = gap / 100;
      percentageAnimationController.forward();
    });
  }

  @override
  dispose() {
    percentageAnimationController.dispose(); // you need this
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int toolColor;
    if (widget.toolScore < 35) {
      toolColor = 0xFFF16969; //pink
    } else if (widget.toolScore < 70) {
      toolColor = 0xFF6A9DFF; //blue
    } else {
      toolColor = 0xFF4CAF50; //green
    }

    int? gap;
    int gapColor;
    String gapIcon;
    double iconFont = 19;
    String? gapNum;
    String? text;

    if (widget.toolScore == widget.oldToolScore) {
      gap = 0;
      gapNum = "";
      gapIcon = "";
      iconFont = 30;
      gapColor = 0xFF9E9E9E; //grey
      toolText = "변동 없음";
      text = "변동 없음";
    } else if (widget.toolScore > widget.oldToolScore) {
      gap = widget.toolScore - widget.oldToolScore;
      gapNum = "점";
      gapIcon = "▲";
      gapColor = 0xFF4CAF50; //green
      toolText = "$gap점 상승";
      text = " 상승";
    } else {
      gap = widget.oldToolScore - widget.toolScore;
      gapNum = "점";
      gapIcon = "▼";
      gapColor = 0xFFF16969; //pink
      toolText = "$gap점 하락";
      text = " 하락";
    }

    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('  재난대비 도구 현황',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              //fontWeight: FontWeight.bold,
            )),
        SizedBox(height: mediaHeight(context, 0.01)),
        InkWell(
          onTap: () {
            widget.changeIndex(0);
          },
          child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400, width: 1.5),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7.0,
                    offset: Offset(2, 5), // changes position of shadow
                  ),
                ],
              ),
              width: mediaWidth(context, 0.95),
              height: 100,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.construction,
                        color: Colors.grey,
                        size: 60,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ' 재난대비 도구 현황',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(gapIcon,
                              style: TextStyle(
                                  color: Color(toolColor),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          PercentScore(
                              percent: gapPercentage,
                              color: Color(toolColor),
                              fontSize: 25.0,
                              width: 35.0),
                          Text('$gapNum',
                              style: TextStyle(
                                  color: Color(toolColor),
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold)),
                          Text(text,
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: PercentScore(
                      percent: percentage,
                      color: Color(toolColor),
                      fontSize: 65.0,
                      width: 100.0),
                )
              ])),
        ),
      ],
    ));
  }
}

String trainText = "";

class TrainingScoreBox extends StatefulWidget {
  const TrainingScoreBox({
    Key? key,
    required this.trainScore,
    required this.oldTrainScore,
    this.changeIndex,
  }) : super(key: key);

  final trainScore;
  final oldTrainScore;
  final changeIndex;

  @override
  State<TrainingScoreBox> createState() => _TrainingScoreBoxState();
}

class _TrainingScoreBoxState extends State<TrainingScoreBox>
    with TickerProviderStateMixin {
  double percentage = 0.0;
  double newPercentage = 0.0;
  double gapPercentage = 0.0;
  double newgapPercentage = 0.0;

  late AnimationController percentageAnimationController;

  void initState() {
    super.initState();

    percentageAnimationController = AnimationController(
        vsync: this, duration: new Duration(milliseconds: 10000))
      ..addListener(() {
        setState(() {
          percentage = lerpDouble(
              percentage, newPercentage, percentageAnimationController.value)!;
          gapPercentage = lerpDouble(gapPercentage, newgapPercentage,
              percentageAnimationController.value)!;
        });
      });

    setState(() {
      percentage = newPercentage;
      newPercentage = (widget.trainScore) / 100;

      double gap = 0.0;
      if (widget.trainScore > widget.oldTrainScore) {
        gap = widget.trainScore.toDouble() - widget.oldTrainScore.toDouble();
      } else {
        gap = widget.oldTrainScore.toDouble() - widget.trainScore.toDouble();
      }
      gapPercentage = newgapPercentage;
      newgapPercentage = gap / 100;
      percentageAnimationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    int trainColor;
    if (widget.trainScore < 35) {
      trainColor = 0xFFF16969; //pink
    } else if (widget.trainScore < 70) {
      trainColor = 0xFF6A9DFF; //blue
    } else {
      trainColor = 0xFF4CAF50; //green
    }

    int? gap;
    int gapColor;
    String gapIcon;
    double iconFont = 19;
    String? gapNum;
    String? text;

    if (widget.trainScore == widget.oldTrainScore) {
      gap = 0;
      gapNum = "";
      gapIcon = "";
      iconFont = 30;
      gapColor = 0xFF9E9E9E; //grey
      trainText = "변동 없음";
      text = "변동 없음";
    } else if (widget.trainScore > widget.oldTrainScore) {
      gap = widget.trainScore - widget.oldTrainScore;
      gapNum = "점";
      gapIcon = "▲";
      gapColor = 0xFF4CAF50; //green
      trainText = "$gap점 상승";
      text = " 상승";
    } else {
      gap = widget.oldTrainScore - widget.trainScore;
      gapNum = "점";
      gapIcon = "▼";
      gapColor = 0xFFF16969; //pink
      trainText = "$gap점 하락";
      text = " 하락";
    }

    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('  재난대비 훈련 현황',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              //fontWeight: FontWeight.bold,
            )),
        SizedBox(height: mediaHeight(context, 0.01)),
        InkWell(
          onTap: () {
            widget.changeIndex(1);
          },
          child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400, width: 1.5),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7.0,
                    offset: Offset(2, 5), // changes position of shadow
                  ),
                ],
              ),
              width: mediaWidth(context, 0.95),
              height: 100,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_document,
                        color: Colors.grey,
                        size: 60,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ' 재난대비 훈련 현황',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(gapIcon,
                              style: TextStyle(
                                  color: Color(trainColor),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          PercentScore(
                              percent: gapPercentage,
                              color: Color(trainColor),
                              fontSize: 25.0,
                              width: 35.0),
                          Text('$gapNum',
                              style: TextStyle(
                                  color: Color(trainColor),
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold)),
                          Text(text,
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: PercentScore(
                      percent: percentage,
                      color: Color(trainColor),
                      fontSize: 65.0,
                      width: 100.0),
                )
              ])),
        ),
      ],
    ));
  }
}

class FamilyScoreBox extends StatelessWidget {
  const FamilyScoreBox({
    Key? key,
    required this.list,
    this.changeIndex,
  }) : super(key: key);

  final List<familyScore>? list;
  final changeIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('  구성원 현황',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            )),
        SizedBox(height: mediaHeight(context, 0.01)),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400, width: 1.5),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7.0,
                offset: Offset(2, 5), // changes position of shadow
              ),
            ],
          ),
          width: mediaWidth(context, 0.95),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
              Text('     총 구성원 현황',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.only(left: 35, right: 57),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('이름',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            //fontWeight: FontWeight.bold,
                          )),
                      Text('점수',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            //fontWeight: FontWeight.bold,
                          ))
                    ]),
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  color: Colors.grey.shade400,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 5),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list?.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, i) {
                  int scoreColor;
                  int? score = list?[i].totalScore;

                  if (score != null && score < 35) {
                    scoreColor = 0xFFF16969; //pink
                  } else if (score != null && score < 70) {
                    scoreColor = 0xFF6A9DFF; //blue
                  } else {
                    scoreColor = 0xFF4CAF50; //green
                  }

                  double last = 0;

                  if (i < list!.length - 1) {
                    last = 7;
                  } else {
                    last = 20;
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 35, right: 55),
                        child: InkWell(
                          onTap: () {
                            changeIndex(3);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${list?[i].name}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  )),
                              Text('${list?[i].totalScore}',
                                  style: TextStyle(
                                    color: Color(scoreColor),
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Container(
                          color: Colors.grey.shade400,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: last),
                    ],
                  );
                },
              ),
            ],
          ),
        )
      ],
    ));
  }
}

class SafetyScoreBox extends StatefulWidget {
  const SafetyScoreBox({
    Key? key,
    required this.totalScore,
    required this.oldTotalScore,
  }) : super(key: key);

  final totalScore;
  final oldTotalScore;

  @override
  State<SafetyScoreBox> createState() => _SafetyScoreBoxState();
}

class _SafetyScoreBoxState extends State<SafetyScoreBox>
    with TickerProviderStateMixin {
  double percentage = 0.0;
  double newPercentage = 0.0;

  late AnimationController percentageAnimationController;

  void initState() {
    super.initState();

    percentageAnimationController = AnimationController(
        vsync: this, duration: new Duration(milliseconds: 10000))
      ..addListener(() {
        setState(() {
          percentage = lerpDouble(
              percentage, newPercentage, percentageAnimationController.value)!;
        });
      });

    setState(() {
      percentage = newPercentage;
      newPercentage = (widget.totalScore) / 100;
      percentageAnimationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalScore = widget.totalScore;
    int oldTotalScore = widget.oldTotalScore;
    String image = "assets/image/firefighter.png";

    int safetyColor;
    String safetyText;
    if (totalScore < 35) {
      safetyColor = 0xFFF16969; //pink
      safetyText = 'Bad';
      image = "assets/image/firefighterBad.png";
    } else if (totalScore < 70) {
      safetyColor = 0xFF6A9DFF; //blue
      safetyText = 'Soso';
      image = "assets/image/firefighterSoso.png";
    } else {
      safetyColor = 0xFF4CAF50; //green
      safetyText = 'Good';
      image = "assets/image/firefighterGood.png";
    }

    String text;
    if (oldTotalScore < totalScore) {
      text = "점수가 상승했습니다.";
    } else if (oldTotalScore > totalScore) {
      text = "점수가 하락했습니다.";
    } else {
      text = "점수를 유지 중입니다.";
    }

    return Center(
      child: Column(
        children: [
          SizedBox(
            height: mediaWidth(context, 0.8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Stack(children: [
                  Positioned(
                    left: mediaWidth(context, 0.25),
                    top: mediaWidth(context, 0.18),
                    child: Image.asset(
                      image,
                      width: mediaWidth(context, 0.35),
                    ),
                  ),
                  PercentDonut(percent: percentage, color: Color(safetyColor)),
                ]),
              ],
            ),
          ),
          SizedBox(height: mediaHeight(context, 0.05)),
          SizedBox(
            height: 140,
            child: Row(
              children: [
                SizedBox(width: mediaWidth(context, 0.07)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(children: [
                      Container(
                          width: 100,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Color(safetyColor),
                          ),
                          child: Center(
                            child: Text(
                              safetyText,
                              style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          )),
                    ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PercentScore(
                            percent: percentage,
                            color: Color(safetyColor),
                            fontSize: 80.0,
                            width: 100.0),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: mediaWidth(context, 0.08)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      child: Text(
                        "$text",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(safetyColor),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      child: Text(
                        "재난대비 도구 점수 $toolText",
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 133, 133, 133),
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      child: Text(
                        "재난대비 훈련 점수 $trainText",
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 133, 133, 133),
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: mediaWidth(context, 0.07)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

//floating border
class PercentDonut extends StatelessWidget {
  const PercentDonut({Key? key, required this.percent, required this.color})
      : super(key: key);
  final percent;
  final color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: mediaWidth(context, 0.8),
      height: mediaWidth(context, 0.8),
      child: CustomPaint(
        // CustomPaint를 그리고 이 안에 차트를 그려줍니다..
        painter: PercentDonutPaint(
          percentage: percent, // 파이 차트가 얼마나 칠해져 있는지 정하는 변수입니다.
          activeColor: color, //색
        ),
      ),
    );
  }
}

////////
class PercentDonutPaint extends CustomPainter {
  double percentage;
  double textScaleFactor = 1.0; // 파이 차트에 들어갈 텍스트 크기를 정합니다.
  Color activeColor;
  PercentDonutPaint({required this.percentage, required this.activeColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint() // 화면에 그릴 때 쓸 Paint를 정의합니다.
      ..color = Color(0xfff3f3f3)
      ..strokeWidth = 35.0 // 선의 길이를 정합니다.
      ..style =
          PaintingStyle.stroke // 선의 스타일을 정합니다. stroke면 외곽선만 그리고, fill이면 다 채웁니다.
      ..strokeCap =
          StrokeCap.round; // stroke의 스타일을 정합니다. round를 고르면 stroke의 끝이 둥글게 됩니다.
    double radius = min(
        size.width / 2 - paint.strokeWidth / 2,
        size.height / 2 -
            paint.strokeWidth / 2); // 원의 반지름을 구함. 선의 굵기에 영향을 받지 않게 보정함.
    Offset center =
        Offset(size.width / 2, size.height / 2); // 원이 위젯의 가운데에 그려지게 좌표를 정함.
    canvas.drawCircle(center, radius, paint); // 원을 그림.
    double arcAngle = 2 * pi * percentage; // 호(arc)의 각도를 정함. 정해진 각도만큼만 그리도록 함.
    paint.color = activeColor; // 호를 그릴 때는 색을 바꿔줌.
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        arcAngle, false, paint); // 호(arc)를 그림.
  }

  // 화면 크기에 비례하도록 텍스트 폰트 크기를 정함.
  double getFontSize(Size size, String text) {
    return size.width / text.length * textScaleFactor;
  }

  @override
  bool shouldRepaint(PercentDonutPaint oldDelegate) {
    return true;
  }
}

class PercentScore extends StatelessWidget {
  const PercentScore(
      {Key? key,
      required this.percent,
      required this.color,
      required this.fontSize,
      required this.width})
      : super(key: key);
  final percent;
  final color;
  final fontSize;
  final width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width,
      child: CustomPaint(
        painter: PercentScorePaint(
          percentage: percent,
          activeColor: color,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

class PercentScorePaint extends CustomPainter {
  double percentage;
  Color activeColor;
  double fontSize;
  PercentScorePaint(
      {required this.percentage,
      required this.activeColor,
      required this.fontSize});

  @override
  void paint(Canvas canvas, Size size) {
    drawText(canvas, size, "${(percentage * 100).round()}");
  }

  // 원의 중앙에 텍스트를 적음.
  void drawText(Canvas canvas, Size size, String text) {
    TextSpan sp = TextSpan(
      children: [
        TextSpan(
            text: "${text}",
            style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: activeColor)),
      ],
    ); // TextSpan은 Text위젯과 거의 동일하다.
    TextPainter tp = TextPainter(text: sp, textDirection: TextDirection.ltr);

    tp.layout(); // 필수! 텍스트 페인터에 그려질 텍스트의 크기와 방향를 정함.
    double dx = size.width / 2 - tp.width / 2;
    double dy = size.height / 2 - tp.height / 2;

    Offset offset = Offset(dx, dy);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(PercentScorePaint oldDelegate) {
    return true;
  }
}

// 위치정보 받아오는 함수 구현
Future<Position> _getUserLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

Future<void> sendUserLocation(double lat, double lon) async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio
      .patch('/api/v1/user/locate', queryParameters: {'lat': lat, 'lon': lon});

  if (response.statusCode == 200) {
    print(response.data);
  } else {
    throw Exception('fail');
  }
}
