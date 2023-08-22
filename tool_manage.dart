import 'package:carousel_slider/carousel_controller.dart';
import 'package:chewie/chewie.dart';
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
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

double appBarHeight = 40;
double mediaHeight(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.height - appBarHeight) * scale;
double mediaWidth(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.width) * scale;

double fullWidth = 0;

String searchText = "";

int toolcount = 0;

class defaultTool {
  final int? id;
  final int toolId;
  final String? name;
  final List? imgUrl;
  final List? shopUrl;
  final List? videoUrl;
  final String toolExplain;
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
    fullWidth = mediaWidth(context, 1);

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
          resizeToAvoidBottomInset: false, //키보드 올라올때 오버플로우 방지
          appBar: AppBar(
            title: Title(
                color: Color.fromRGBO(87, 87, 87, 1),
                child: Text(
                  '도구 관리',
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
                    Icons.add_circle_outline_outlined,
                    size: 40,
                  ),
                  onPressed: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => toolRegistPage()))
                        .then((value) {
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

          body: Theme(
            data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
            child: SafeArea(
              top: true,
              child: Padding(
                padding: const EdgeInsets.only(left: 0, right: 0),
                child: Container(
                  height: mediaHeight(context, 1),
                  child: Column(
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
                              border: InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.grey.shade500),
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
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15, right: 15),
                                                child: SizedBox(
                                                    width: MediaQuery.of(context)
                                                        .size
                                                        .width, //fullsize
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
          
                                                          double locateWidth = 80;
                                                          double locatePadding =
                                                              10;
                                                          double expWidth = 80;
                                                          double expPadding = 10;
          
                                                          double makerWidth = 80;
                                                          double makerPadding =
                                                              10;
          
                                                          if (snapshot.data?[i]
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
                                                          if (snapshot.data?[i]
                                                                      .name ==
                                                                  null ||
                                                              snapshot.data?[i]
                                                                      .name ==
                                                                  "") {
                                                            name = "";
                                                          } else {
                                                            name = snapshot
                                                                .data?[i].name;
                                                          }
          
                                                          String? toolExplain;
                                                          if (snapshot.data?[i]
                                                                      .toolExplain ==
                                                                  null ||
                                                              snapshot.data?[i]
                                                                      .toolExplain ==
                                                                  "") {
                                                            toolExplain =
                                                                "상세정보를 입력하세요.";
                                                          } else {
                                                            toolExplain = snapshot
                                                                .data?[i]
                                                                .toolExplain;
                                                            if (toolExplain!
                                                                    .length >
                                                                24) {
                                                              toolExplain =
                                                                  toolExplain
                                                                      ?.substring(
                                                                          0, 24);
                                                              toolExplain =
                                                                  "$toolExplain...";
                                                            }
                                                          }
          
                                                          String? exp;
                                                          if (snapshot.data?[i]
                                                                      .exp ==
                                                                  null ||
                                                              snapshot.data?[i]
                                                                      .exp ==
                                                                  "") {
                                                            exp = "";
                                                            expWidth = 0;
                                                            expPadding = 0;
                                                          } else {
                                                            exp = snapshot
                                                                .data?[i].exp;
                                                          }
          
                                                          String? maker;
                                                          if (snapshot.data?[i]
                                                                      .maker ==
                                                                  null ||
                                                              snapshot.data?[i]
                                                                      .maker ==
                                                                  "") {
                                                            maker = "Ad.";
                                                            makerWidth = 40;
                                                            //makerPadding = 0;
                                                          } else {
                                                            maker = snapshot
                                                                .data?[i].maker;
          
                                                            if (maker!.length <
                                                                3) {
                                                              makerWidth = 40;
                                                            } else if (maker!
                                                                    .length <
                                                                4) {
                                                              makerWidth = 50;
                                                            } else if (maker!
                                                                    .length <
                                                                5) {
                                                              makerWidth = 60;
                                                            } else if (maker!
                                                                    .length >
                                                                5) {
                                                              maker = maker
                                                                  ?.substring(
                                                                      0, 5);
                                                              maker = "$maker...";
                                                            }
                                                          }
          
                                                          String? locate;
                                                          if (snapshot.data?[i]
                                                                      .locate ==
                                                                  null ||
                                                              snapshot.data?[i]
                                                                      .locate ==
                                                                  "") {
                                                            locate = "";
                                                            locateWidth = 0;
                                                            locatePadding = 0;
                                                          } else {
                                                            locate = snapshot
                                                                .data?[i].locate;
          
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
          
                                                          if (searchText!
                                                                  .isNotEmpty &&
                                                              !snapshot
                                                                  .data![i].name!
                                                                  .toLowerCase()
                                                                  .contains(searchText
                                                                      .toLowerCase())) {
                                                            return SizedBox
                                                                .shrink();
                                                          } else
                                                            return InkWell(
                                                              onTap: () {
                                                                showDefault(
                                                                    context,
                                                                    snapshot
                                                                        .data?[i]);
                                                              },
                                                              child: Column(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top: 10,
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
                                                                              padding: const EdgeInsets.only(
                                                                                  right: 20,
                                                                                  left: 10,
                                                                                  top: 5,
                                                                                  bottom: 5),
                                                                              child:
                                                                                  Container(
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
                                                                              crossAxisAlignment:
                                                                                  CrossAxisAlignment.start,
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment.center,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 1),
                                                                                  child: Text.rich(TextSpan(children: [
                                                                                    TextSpan(
                                                                                        text: '$name',
                                                                                        style: TextStyle(
                                                                                          color: Colors.grey.shade700,
                                                                                          fontSize: 18,
                                                                                          fontWeight: FontWeight.bold,
                                                                                        )),
                                                                                  ])),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 2),
                                                                                  child: Text.rich(TextSpan(children: [
                                                                                    TextSpan(
                                                                                        text: '$toolExplain',
                                                                                        style: TextStyle(
                                                                                          color: Colors.grey.shade500,
                                                                                          fontSize: 16,
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
                                                                                              '${snapshot.data?[i].count}개',
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
                                              ),
                                              FutureBuilder<List<customTool>>(
                                                  future: futureCustomTool,
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasError)
                                                      return Text(
                                                          '${snapshot.error}');
                                                    else if (snapshot.hasData) {
                                                      return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 15,
                                                                  right: 15),
                                                          child: SizedBox(
                                                            width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width,
                                                            child:
                                                                ListView.builder(
                                                              shrinkWrap: true,
                                                              physics:
                                                                  const NeverScrollableScrollPhysics(),
                                                              itemCount: snapshot
                                                                  .data?.length,
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
          
                                                                if (snapshot
                                                                        .data?[i]
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
                                                                if (snapshot
                                                                            .data?[
                                                                                i]
                                                                            .name ==
                                                                        null ||
                                                                    snapshot
                                                                            .data?[
                                                                                i]
                                                                            .name ==
                                                                        "") {
                                                                  name = "";
                                                                } else {
                                                                  name = snapshot
                                                                      .data?[i]
                                                                      .name;
                                                                }
          
                                                                String?
                                                                    toolExplain;
                                                                if (snapshot
                                                                            .data?[
                                                                                i]
                                                                            .toolExplain ==
                                                                        null ||
                                                                    snapshot
                                                                            .data?[
                                                                                i]
                                                                            .toolExplain ==
                                                                        "") {
                                                                  toolExplain =
                                                                      "상세정보를 입력하세요.";
                                                                } else {
                                                                  toolExplain =
                                                                      snapshot
                                                                          .data?[
                                                                              i]
                                                                          .toolExplain;
                                                                  if (toolExplain!
                                                                          .length >
                                                                      15) {
                                                                    toolExplain =
                                                                        toolExplain
                                                                            ?.substring(
                                                                                0,
                                                                                15);
                                                                    toolExplain =
                                                                        "$toolExplain...";
                                                                  }
                                                                }
          
                                                                String? exp;
                                                                if (snapshot
                                                                            .data?[
                                                                                i]
                                                                            .exp ==
                                                                        null ||
                                                                    snapshot
                                                                            .data?[
                                                                                i]
                                                                            .exp ==
                                                                        "") {
                                                                  exp = "";
                                                                  expWidth = 0;
                                                                  expPadding = 0;
                                                                } else {
                                                                  exp = snapshot
                                                                      .data?[i]
                                                                      .exp;
                                                                }
          
                                                                String? locate;
                                                                if (snapshot
                                                                            .data?[
                                                                                i]
                                                                            .locate ==
                                                                        null ||
                                                                    snapshot
                                                                            .data?[
                                                                                i]
                                                                            .locate ==
                                                                        "") {
                                                                  locate = "";
                                                                  locateWidth = 0;
                                                                  locatePadding =
                                                                      0;
                                                                } else {
                                                                  locate =
                                                                      snapshot
                                                                          .data?[
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
                                                                    !snapshot
                                                                        .data![i]
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
                                                                          snapshot
                                                                              .data?[i]);
                                                                    },
                                                                    child: Column(
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(
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
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 1),
                                                                                      child: Text.rich(TextSpan(children: [
                                                                                        TextSpan(
                                                                                            text: '$name',
                                                                                            style: TextStyle(
                                                                                              color: Colors.grey.shade700,
                                                                                              fontSize: 18,
                                                                                              fontWeight: FontWeight.bold,
                                                                                            )),
                                                                                      ])),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 2),
                                                                                      child: Text.rich(TextSpan(children: [
                                                                                        TextSpan(
                                                                                            text: '$toolExplain',
                                                                                            style: TextStyle(
                                                                                              color: Colors.grey.shade500,
                                                                                              fontSize: 16,
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
                                                                                                  '${snapshot.data?[i].count}개',
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
                                                          ));
                                                    } else
                                                      return Visibility(
                                                        visible: false,
                                                        child: CircularProgressIndicator()
                                                        );
                                                  })
                                            ],
                                          ),
                                        ],
                                      );
                                    }
                                    return Visibility(
                                      visible: false,
                                      child: CircularProgressIndicator());
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

  double fontSize = 12;

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Theme(
      data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
      child: AlertDialog(
      content: Container(
        height: 480,
        width: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  flex: 1,
                  child: Visibility(
                    visible: shopVisible,
                    child: IconButton(
                      icon: Icon(
                        Icons.store,
                        color: Colors.lightBlue.shade300,
                        size: 30,
                      ),
                      onPressed: () {
                        _launchInBrowser(shopUrl?[0]);
                      },
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Visibility(
                    visible: imgVisible,
                    child: IconButton(
                      icon: Icon(
                        Icons.image,
                        color: Colors.lightGreen.shade300,
                        size: 28,
                      ),
                      onPressed: () {
                        
                        showDefaultImg(context, defaultTool);
                      },
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Visibility(
                    visible: videoVisible,
                    child: IconButton(
                      icon: Icon(
                        Icons.videocam,
                        color: Colors.grey.shade600,
                        size: 30,
                      ),
                      onPressed: () {
                        showDefaultVideo(context, defaultTool);
                      },
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: Row(
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
                        onPressed: () async {
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 200,
                                  decoration: const BoxDecoration(
                                    color: Colors.white, // 모달 배경색
                                    borderRadius: BorderRadius.only(
                                      topLeft:
                                          Radius.circular(0), // 모달 좌상단 라운딩 처리
                                      topRight:
                                          Radius.circular(0), // 모달 우상단 라운딩 처리
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "삭제하시겠습니까?",
                                              style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.grey.shade800,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 0,
                                            bottom: 0,
                                            left: 0,
                                            right: 0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: mediaWidth(context, 0.5),
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
                                                            '/api/v1/user/tool/default',
                                                            queryParameters: {
                                                          'id': defaultTool.id
                                                        });

                                                    if (response.statusCode ==
                                                        200) {
                                                      Navigator
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
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible:
                                                          true, //바깥 영역 터치시 닫을지 여부 결정
                                                      builder: ((context) {
                                                        return AlertDialog(
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
                                                                          0),
                                                              side: BorderSide(
                                                                color:
                                                                    Colors.red,
                                                              ))),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: mediaWidth(context, 0.5),
                                              height: 50,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "취소",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.grey.shade300),
                                                  shape: MaterialStateProperty
                                                      .all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0),
                                                              side: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ))),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
    );}
  );
}

Future<dynamic> showDefaultImg(BuildContext context, defaultTool) {
  List? imgUrl = defaultTool.imgUrl;

  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.white.withOpacity(0),
    builder: (BuildContext context) {
      return Theme(
        data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.white.withOpacity(0),),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0),
          insetPadding: EdgeInsets.all(0),
          content: Container(
            height: mediaHeight(context, 1),
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageBox(
                  defaultTool: defaultTool
                ),
              ],
            ),
          )
              ),
        ),
    );}
  );
}


List loadTrainImage(imgurl) {
  String baseUrl =
      "http://test.elibtest.r-e.kr:8080/api/v1/media/tool/img?name=";

  List imageList = [];
  for (var img in imgurl) {
    imageList.add(baseUrl + img);
  }

  return imageList;
}

class ImageBox extends StatefulWidget {
  ImageBox({
    Key? key,
    this.defaultTool
  }) : super(key: key);

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
            ]
          ),
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
        return Stack(
          children: [
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
          ]
        );
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
        data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.white.withOpacity(0),),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0),
          insetPadding: EdgeInsets.all(0),
          content: Container(
            height: mediaHeight(context, 1),
            width: mediaWidth(context, 1),
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                VideoBox(
                  defaultTool: defaultTool
                ),
              ],
            ),
          )
              ),
        ),
    );}
  );
}

List loadToolVideo(videourl) {
  String baseUrl =
      "http://test.elibtest.r-e.kr:8080/api/v1/media/tool/video?name=";

  List videoList = [];
  for (var video in videourl) {
    videoList.add(baseUrl + video);
  }

  print(videoList);

  return videoList;
}

class VideoBox extends StatefulWidget {
  VideoBox({
    Key? key,
    this.defaultTool
  }) : super(key: key);

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
        return Column(
        children: [
          Container(
            height: mediaHeight(context, 0.3),
            width: mediaWidth(context, 1),
            child: Chewie(
              controller: chewieController!,
            ),
          ),
        ]
      );
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
        height: 480,
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
                                  height: 200,
                                  decoration: const BoxDecoration(
                                    color: Colors.white, // 모달 배경색
                                    borderRadius: BorderRadius.only(
                                      topLeft:
                                          Radius.circular(0), // 모달 좌상단 라운딩 처리
                                      topRight:
                                          Radius.circular(0), // 모달 우상단 라운딩 처리
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "삭제하시겠습니까?",
                                              style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.grey.shade800,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 0,
                                            bottom: 0,
                                            left: 0,
                                            right: 0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: mediaWidth(context, 0.5),
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
                                                          'id': customTool.id
                                                        });

                                                    if (response.statusCode ==
                                                        200) {
                                                      Navigator
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
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible:
                                                          true, //바깥 영역 터치시 닫을지 여부 결정
                                                      builder: ((context) {
                                                        return AlertDialog(
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
                                                                          0),
                                                              side: BorderSide(
                                                                color:
                                                                    Colors.red,
                                                              ))),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: mediaWidth(context, 0.5),
                                              height: 50,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "취소",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.grey.shade300),
                                                  shape: MaterialStateProperty
                                                      .all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0),
                                                              side: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ))),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
