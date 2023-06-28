import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io'; //쿠키
import 'package:elib_project/auth_dio.dart';

const account = "testKakao1";

Future<void> signIn() async {
  //초기 회원가입 메소드처럼 구현해놓은것
  final storage = new FlutterSecureStorage(); //로그인페이지에 넣어줘야하는

  final httpsUri =
      Uri.http('test.elibtest.r-e.kr:8080', '/login/test', {'limit': '10'});
  final http.Response response = await http.get(httpsUri);

  if (response.statusCode == 200) {
    final accessToken = await response.headers['authorization'];

    var exp = RegExp(r"((?:[^,]|, )+)");
    final Iterable<RegExpMatch> matches =
        await exp.allMatches(response.headers["set-cookie"]!);

    for (final m in matches) {
      // 쿠키 한개에 대한 디코딩 처리
      Cookie cookie = Cookie.fromSetCookieValue(m[0]!);
      var refresh = cookie.value;
      final refreshToken = "Bearer " + refresh.substring(7);

      print("accesstoken: $accessToken");
      print("refreshtoken: $refreshToken");

      await storage.write(key: 'ACCESS_TOKEN', value: accessToken);
      await storage.write(key: 'REFRESH_TOKEN', value: refreshToken);
    } // for
  } else {
    print('signIn Error..................');
  }
}

class Score {
  final int totalScore;
  final int toolScore;
  final int oldToolScore;
  final int trainScore;
  final int oldTrainScore;

  Score({
    required this.totalScore,
    required this.toolScore,
    required this.oldToolScore,
    required this.trainScore,
    required this.oldTrainScore,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      totalScore: json['totalScore'],
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
    List<familyScore> list = data.map((dynamic e) => familyScore.fromJson(e)).toList();

    return list;
  } else {
    throw Exception('Failed to Load');
  }
}

class testPage extends StatefulWidget {
  const testPage({super.key});

  @override
  State<testPage> createState() => _testPageState();
}

class _testPageState extends State<testPage> {
  late Future<Score> futureScore;
  late Future<List<familyScore>> futureFamilyScore;

  @override
  void initState() {
    super.initState();
    futureScore = loadScore();
    futureFamilyScore = loadFamilyScore();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorSchemeSeed: const Color(0xff6750a4), useMaterial3: true),
      home: Scaffold(
        body: SafeArea(
          top: true,
          child: FutureBuilder<Score>(
            future: futureScore, 
            builder: (context, snapshot){
              if (snapshot.hasError) 
                return Text('${snapshot.error}');

              else if(snapshot.hasData){
                return Column(
                  children: <Widget>[
                  SizedBox(height: 5.0),
                  Image.asset(
                    'assets/image/eliblogo.png',
                    width: 95.95,
                    height: 50,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '안녕하세요 ',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                '오늘의 우리집 안전점수는?',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 110, 110, 110),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SafetyScoreBox(
                          totalScore: snapshot.data?.totalScore,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ToolScoreBox(
                              toolScore: snapshot.data?.toolScore,
                              oldToolScore: snapshot.data?.oldToolScore,
                            ),
                            TrainingScoreBox(
                              trainScore: snapshot.data?.trainScore,
                              oldTrainScore: snapshot.data?.oldTrainScore
                            ),
                          ],
                        ),

                        FutureBuilder<List<familyScore>>(
                          future: futureFamilyScore, 
                          builder: (context, snapshot) {
                            if (snapshot.hasError)
                            return Text('${snapshot.error}');
                            
                            else if(snapshot.hasData){
                              return FamilyScoreBox(
                                list: snapshot.data,
                              );
                            }
                            else 
                              return CircularProgressIndicator();
                          }),
                      ],
                    ),
                  ),
                ],
              );}
              return CircularProgressIndicator();
            }),
          ),
          bottomNavigationBar: _bulidBottomAppBar(),
        ),
        
      );
  }
}

class ToolScoreBox extends StatelessWidget {
  const ToolScoreBox({
    Key? key, 
    required this.toolScore,
    required this.oldToolScore,
  }) : super(key: key);

  final toolScore;
  final oldToolScore;

  @override
  Widget build(BuildContext context) {
    int toolColor;
    if(toolScore<35) {
      toolColor = 0xFFF93426; //red
    } else if(toolScore<70) {
      toolColor = 0xFFFFDF0E; //yellow
    } else {
      toolColor = 0xFF4CAF50; //green
    }

    int? gap;
    int gapColor;
    String gapIcon;
    double iconFont = 19;
    String? gapNum;

    if (toolScore == oldToolScore) {
      gap = 0;
      gapNum = "";
      gapIcon = "-";
      iconFont = 30;
      gapColor = 0xFF9E9E9E; //gray
    } else if(toolScore>oldToolScore) {
      gap = toolScore - oldToolScore;
      gapNum = gap.toString();
      gapIcon = "▲";
      gapColor = 0xFF4CAF50; //green
    } else {
      gap = oldToolScore - toolScore;
      gapNum = gap.toString();
      gapIcon = "▼";
      gapColor = 0xFFF93426; //red
    }

    return Center(
        child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: SizedBox(
                width: 190,
                height: 140,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(children: <Widget>[
                    Icon(
                      Icons.construction,
                      color: Colors.grey,
                      size: 30,
                    ),
                    Text(
                      '재난대비 도구 현황',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text.rich(TextSpan(children: [
                          TextSpan(
                              text: '$toolScore',
                              style: TextStyle(
                                  color: Color(toolColor),
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: ' 점  ',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                                  text: gapIcon,
                                  style: TextStyle(
                                      color: Color(gapColor),
                                      fontSize: iconFont,
                                      fontWeight: FontWeight.bold)),
                          TextSpan(
                                text: gapNum,
                                style: TextStyle(
                                    color: Color(gapColor),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                        ])),
                      ]
                    )
                  ]),
                ))));
    }
}

class TrainingScoreBox extends StatelessWidget {
  const TrainingScoreBox({
    Key? key, 
    required this.trainScore,
    required this.oldTrainScore,
  }) : super(key: key);

  final trainScore;
  final oldTrainScore;

  @override
  Widget build(BuildContext context) {
    int trainColor;
    if(trainScore<35) {
      trainColor = 0xFFF93426; //red
    } else if(trainScore<70) {
      trainColor = 0xFFFFDF0E; //yellow
    } else {
      trainColor = 0xFF4CAF50; //green
    }

    int? gap;
    int gapColor;
    String gapIcon;
    double iconFont = 19;
    String? gapNum;

    if (trainScore == oldTrainScore) {
      gap = 0;
      gapNum = "";
      gapIcon = "-";
      iconFont = 30;
      gapColor = 0xFF9E9E9E; //gray
    } else if(trainScore>oldTrainScore) {
      gap = trainScore - oldTrainScore;
      gapNum = gap.toString();
      gapIcon = "▲";
      gapColor = 0xFF4CAF50; //green
    } else {
      gap = oldTrainScore - trainScore;
      gapNum = gap.toString();
      gapIcon = "▼";
      gapColor = 0xFFF93426; //red
    }

    return Center(
        child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: SizedBox(
                width: 190,
                height: 140,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(children: <Widget>[
                    Icon(
                      Icons.assignment,
                      color: Colors.grey,
                      size: 30,
                    ),
                    Text(
                      '재난대비훈련 이수 현황',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text.rich(TextSpan(children: [
                          TextSpan(
                              text: '$trainScore',
                              style: TextStyle(
                                  color: Color(trainColor),
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: ' 점  ',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                                  text: gapIcon,
                                  style: TextStyle(
                                      color: Color(gapColor),
                                      fontSize: iconFont,
                                      fontWeight: FontWeight.bold)),
                          TextSpan(
                                text: gapNum,
                                style: TextStyle(
                                    color: Color(gapColor),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                        ])),
                      ]
                    )
                  ]),
                ))));
    }
}

class FamilyScoreBox extends StatelessWidget {
  const FamilyScoreBox({
    Key? key, 
    required this.list,
  }) : super(key: key);

  final List<familyScore>? list;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(TextSpan(children: [
              TextSpan(
                text: '구성원 현황',
                style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                )),
              ])),
              SizedBox(
                height: 120,
                width: 400,
                child: ListView.builder(
                  itemCount: list?.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    int scoreColor;
                    int? score = list?[i].totalScore;

                    if(score != null && score<35) {
                      scoreColor = 0xFFF93426; //red
                    } else if(score != null && score<70) {
                      scoreColor = 0xFFFFDF0E; //yellow
                    } else {
                      scoreColor = 0xFF4CAF50; //green
                    }

                    return Padding(
                      padding: EdgeInsets.only(right: 5.0),
                      child: 
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                          side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                        ),
                          child: SizedBox(
                            width: 120,
                            height: 120,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text.rich(TextSpan(children: [
                                  TextSpan(
                                    text: '${list?[i].name}',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                  )),
                                  TextSpan(
                                    text: '님',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                  ))
                                ])),
                                Text.rich(TextSpan(children: [
                                  TextSpan(
                                    text: '${list?[i].totalScore}',
                                    style: TextStyle(
                                      color: Color(scoreColor),
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                  )),
                                  TextSpan(
                                    text: ' 점',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                  ))
                                ]))
                              ],
                            ),
                          ),
                        ),                      
                    );
                  },
                )
              )
            ],
          ),
        ));
  }
}

class SafetyScoreBox extends StatefulWidget {
  const SafetyScoreBox({
    Key? key, 
    required this.totalScore,
    }) : super(key: key);

  final totalScore;

  @override
  State<SafetyScoreBox> createState() => _SafetyScoreBoxState();
}

class _SafetyScoreBoxState extends State<SafetyScoreBox> {
  @override
  Widget build(BuildContext context) {

    int totalScore = widget.totalScore;
    double totalBar =  totalScore/100;

    int safetyColor;
    String safetyText;
    if(totalScore<35) {
      safetyColor = 0xFFF93426; //red
      safetyText = 'Bad';
    } else if(totalScore<70) {
      safetyColor = 0xFFFFDF0E; //yellow
      safetyText = 'Soso';
    } else {
      safetyColor = 0xFF4CAF50; //green
      safetyText = 'Good';
    }

    return Center(
      child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: SizedBox(
            width: 400,
            height: 160,
            child: Column(
              children: [
                Row(children: <Widget>[
                  Container(
                    width: 200,
                    height: 155,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/image/firefighter.png',
                            width: 150,
                            height: 110,
                          ),
                        ),
                        Container(
                            width: 150,
                            height: 30,
                            child: Center(
                              child: LinearPercentIndicator(
                                lineHeight: 15,
                                percent: totalBar,
                                progressColor: Color(safetyColor),
                              ),
                            ))
                      ],
                    ),
                  ),
                Spacer(),
                Container(
                  width: 170,
                  height: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                              width: 110,
                              height: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
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
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(TextSpan(children: [
                            TextSpan(
                                text: '$totalScore',
                                style: TextStyle(
                                    color: Color(safetyColor),
                                    fontSize: 70,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: '  점',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold))
                          ])),
                        ],
                      )
                    ],
                  ),
                )
              ])
            ]),
          )),
    );
  }
}

BottomAppBar _bulidBottomAppBar() {
  return BottomAppBar(
    elevation: 1,
    child: SizedBox(
      height: kBottomNavigationBarHeight,
      // color: Colors.white,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              children: const <Widget>[
                Icon(
                  Icons.construction,
                ),
                Text("도구관리")
              ],
            ),
            Column(
              children: const <Widget>[
                Icon(
                  Icons.edit_document,
                ),
                Text("훈련관리")
              ],
            ),
            Column(
              children: const <Widget>[
                Icon(
                  Icons.home,
                ),
                Text("홈")
              ],
            ),
            Column(
              children: const <Widget>[
                Icon(
                  Icons.groups,
                ),
                Text("구성원관리")
              ],
            ),
            Column(
              children: const <Widget>[
                Icon(
                  Icons.more_horiz,
                ),
                Text("더보기")
              ],
            )
          ]),
    ),
  );
}
