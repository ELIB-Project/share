import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io'; //쿠키
import 'package:elib_project/auth_dio.dart';
import 'package:elib_project/pages/tool_regist.dart';

class defaultTool {
  final int id;
  final String name;
  final String shopUrl;
  final String videoUrl;
  final String toolExplain;
  final int count;
  final String? locate;
  final String? exp;

  defaultTool({
    required this.id,
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
      id: json['id'],
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
  final String name;
  final int count;
  final String? locate;
  final String? exp;

  customTool({
    required this.id,
    required this.name,
    required this.count,
    required this.locate,
    required this.exp,
  });

  factory customTool.fromJson(Map<String, dynamic> json) {
    return customTool(
      id: json['id'],
      name: json['name'],
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
    List<defaultTool> list = data.map((dynamic e) => defaultTool.fromJson(e)).toList();
    
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
    List<customTool> list = data.map((dynamic e) => customTool.fromJson(e)).toList();
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
      theme: ThemeData(
          colorSchemeSeed: const Color(0xff6750a4), useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title:
              Title(color: Color.fromRGBO(87, 87, 87, 1), 
                child: Text(' 도구 관리',
                          style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          ),
                        )),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => toolRegistPage())).then((value){
                      setState((){
                        futureDefaultTool = loadDefaultTool();
                        futureCustomTool = loadCustomTool();
                      });
                    }
                  );
                },
              ),
            ),
          ],
        ),
        body: SafeArea(
            top: true,
            child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: FutureBuilder<List<defaultTool>>(
                future: futureDefaultTool, 
                builder: (context, snapshot){
                  if (snapshot.hasError) 
                    return Text('${snapshot.error}');
            
                  else if(snapshot.hasData){
                    double? defaultHeight = snapshot.data!.length * 70;
                    
                    return SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 5.0),
                          Padding(
                            padding: EdgeInsets.only(top: 15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                                  ),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      focusedBorder:  OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                        borderSide: BorderSide(width: 2, color: Colors.black),
                                      ),
                                      suffixIcon: Icon(Icons.search), //검색 아이콘 추가
                                      contentPadding: EdgeInsets.only(left: 10, bottom: 0, top: 10, right: 5),
                                    ),
                                  ),
                                ),
                    
                                Padding(
                                  padding: const EdgeInsets.only(left:5, top: 10),
                                  child: Text.rich(TextSpan(children: [
                                  TextSpan(
                                    text: 'Default',
                                    style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    )),
                                  ])),
                                ),
                              
                                Padding(
                                  padding: const EdgeInsets.only(left:5, right: 5),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width, //fullsize
                                    height: defaultHeight,
                                    child: ListView.builder(
                                      itemCount: snapshot.data?.length,
                                      scrollDirection: Axis.vertical,
                                      itemBuilder: (context, i) {
                                        int countColor;
                                        
                                        if(snapshot.data?[i].count == 0) {
                                          countColor = 0xFFF93426;
                                        } else {
                                          countColor = 0xFFFFDF0E;
                                        }
                    
                                        return InkWell(
                                          onTap: () {
                    
                                          },
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                                child: Container(
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
                                                            Text.rich(TextSpan(children: [
                                                            TextSpan(
                                                              text: '${snapshot.data?[i].name}',
                                                              style: TextStyle(
                                                                color: Colors.grey,
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold,
                                                              )),
                                                            ])),
                                                            Row(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 10),
                                                                  child: Container(      
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
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 10),
                                                                  child: Container(      
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
                                                                        '${snapshot.data?[i].locate}',
                                                                        style: TextStyle(
                                                                          color: Colors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                
                                                                Container(      
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
                                                                      '${snapshot.data?[i].exp}',
                                                                      style: TextStyle(
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ]
                                          ),
                                        );
                                      })
                                  ),
                                ),
                              
                                Padding(
                                  padding: const EdgeInsets.only(left:5, top: 10),
                                  child: Text.rich(TextSpan(children: [
                                  TextSpan(
                                    text: 'Custom',
                                    style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    )),
                                  ])),
                                ),
                                FutureBuilder<List<customTool>>(
                                  future: futureCustomTool,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) 
                                      return Text('${snapshot.error}');
                                    
                                    else if(snapshot.hasData){
                                      double? customHeight = snapshot.data!.length * 70;
                                      print(customHeight);
                                      print(snapshot.data);
                                      return SingleChildScrollView(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left:5, right: 5),
                                          child: SizedBox(
                                            width: MediaQuery.of(context).size.width,
                                            height: customHeight,
                                            child: ListView.builder(
                                              itemCount: snapshot.data?.length,
                                              scrollDirection: Axis.vertical,
                                              itemBuilder: (context, i) {
                                                int countColor;
                                                                                  
                                                if(snapshot.data?[i].count == 0) {
                                                  countColor = 0xFFF93426; //red
                                                } else {
                                                  countColor = 0xFFFFDF0E; //yellow
                                                }
                                          
                                                return InkWell(
                                                  onTap: () {
                                                              
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                                                  child: Container(
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
                                                              Text.rich(TextSpan(children: [
                                                              TextSpan(
                                                                text: '${snapshot.data?[i].name}',
                                                                style: TextStyle(
                                                                  color: Colors.grey,
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold,
                                                                )),
                                                              ])),
                                                              Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Container(      
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
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Container(      
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
                                                                          '${snapshot.data?[i].locate}',
                                                                          style: TextStyle(
                                                                            color: Colors.white,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  
                                                                  Container(      
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
                                                                        '${snapshot.data?[i].exp}',
                                                                        style: TextStyle(
                                                                          color: Colors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
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
                                          )
                                        ),
                                      );
                                    }
                                    else
                                      return CircularProgressIndicator();
                                })
                              ],
                            )
                          ),
                      ],
                      ),
                    );}
                  return CircularProgressIndicator();
                }),
            ),
            
        ),
          bottomNavigationBar: _bulidBottomAppBar(),
        ),
        
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
