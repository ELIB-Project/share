import 'package:elib_project/models/bottom_app_bar.dart';
import 'package:elib_project/pages/edit_custom_tool.dart';
import 'package:elib_project/pages/edit_default_tool.dart';
import 'package:elib_project/pages/tool_manage.dart';
import 'package:elib_project/pages/tool_regist_qr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:elib_project/auth_dio.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'dart:convert';

String apiUrl = "http://test.elibtest.r-e.kr:8080/api/v1/media/qr";

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

double appBarHeight = 50;

double mediaHeight(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top) *
    scale;

double mediaWidth(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.width) * scale;

String today = getToday();
String getToday() {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd');
  String strToday = formatter.format(now);
  return strToday;
}

class toolRegistPage extends StatefulWidget {
  const toolRegistPage({super.key});

  @override
  State<toolRegistPage> createState() => _toolRegistPageState();
}

class _toolRegistPageState extends State<toolRegistPage> {
  final GlobalKey _containerkey = GlobalKey();
  final _formKey = GlobalKey<FormState>();

  String name = "";
  String? toolExplain = null;
  int count = 0;
  String? locate = null;
  String? exp = null;
  String? mfd = null;

  int buttonCount = 0;

  double tempHeight = 0;

  Size? _getSize() {
    if (_containerkey.currentContext != null) {
      final RenderBox renderBox =
          _containerkey.currentContext!.findRenderObject() as RenderBox;
      Size size = renderBox.size;
      return size;
    }
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        tempHeight = _getSize()!.height;
      });
    });
  }

  String? _output;
  int? toolId;

  Future _scan() async {
    print("runned");
    //스캔 시작 - 이때 스캔 될때까지 blocking
    String? barcode = await scanner.scan();
    //스캔 완료하면 _output 에 문자열 저장하면서 상태 변경 요청.
    setState(() => _output = barcode!);

    _output = _output!.substring(apiUrl.length);
    _output = _output!.replaceAll('?', '{"');
    _output = _output!.replaceAll('=', '":"');
    _output = _output!.replaceAll('&', '","');
    _output = _output! + '"}';
    print(_output);

    Map<String, dynamic> temp;
    importTool tool;

    try {
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                //title: Text("제목"),
                content: Text(
                  'Qr을 지원하지 않는 도구입니다.',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                  textAlign: TextAlign.center,
                ),
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            //title: Text("제목"),
            content: Text(
              'Qr을 지원하지 않는 도구입니다.',
              style: TextStyle(
                fontSize: 17,
              ),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
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
              ),
            ],
          );
        }),
      );
    }
    

    print("load-------------------------------");
    //print(tool.toolId);
    //print(temp['toolId']);

    
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
    final boxHeight = mediaHeight(context, 0.03);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorSchemeSeed: const Color(0xff6750a4), useMaterial3: true),
      home: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Title(
                color: Color.fromRGBO(87, 87, 87, 1),
                child: Text(
                  ' 도구 등록',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                Navigator.pop(context); // 뒤로가기 버튼 클릭 이벤트 처리
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 5, bottom: 0),
                child: IconButton(
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    size: 35,
                  ),
                  onPressed: () async {
                    await permission();
                    _scan();
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => toolRegistPage()));
                  },
                  tooltip: 'scan',
                ),
              ),
            ],
          ),
          body: SafeArea(
              top: true,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 0, left: 20, right: 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: mediaHeight(context, 0.03),
                              ),
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: ' 제품명',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    )),
                                TextSpan(
                                    text: ' (필수)',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ])),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: SizedBox(
                                  child: TextFormField(
                                    autovalidateMode: AutovalidateMode.always,
                                    onChanged: (value) {
                                      name = value;
                                    },
                                    onSaved: (value) {
                                      name = value as String;
                                    },
                                    validator: (value) {
                                      int length = value!.length;

                                      if (buttonCount == 1) {
                                        if (length < 1) {
                                          return '필수 입력란입니다.';
                                        }
                                      }

                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        borderSide: BorderSide(
                                            width: 2, color: Colors.black),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        borderSide: BorderSide(
                                            width: 2, color: Colors.black),
                                      ),
                                      errorStyle:
                                          TextStyle(color: Colors.green),
                                      contentPadding: EdgeInsets.only(
                                          left: 10,
                                          bottom: 0,
                                          top: boxHeight,
                                          right: 5),
                                    ),
                                    style: TextStyle(
                                      decorationThickness: 0,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: mediaHeight(context, 0.04),
                              ),
                              Text(
                                ' 상세정보',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: TextField(
                                  onChanged: (value) {
                                    toolExplain = value;
                                  },
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      borderSide: BorderSide(
                                          width: 2, color: Colors.black),
                                    ), //검색 아이콘 추가
                                    contentPadding: EdgeInsets.only(
                                        left: 10,
                                        bottom: 0,
                                        top: boxHeight,
                                        right: 5),
                                  ),
                                  style: TextStyle(
                                    decorationThickness: 0,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: mediaHeight(context, 0.04),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ' 위치',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: TextField(
                                      key: _containerkey,
                                      onChanged: (value) {
                                        locate = value;
                                      },
                                      decoration: InputDecoration(
                                        isDense: true,
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          borderSide: BorderSide(
                                              width: 2, color: Colors.black),
                                        ),
                                        contentPadding: EdgeInsets.only(
                                            left: 10,
                                            bottom: 0,
                                            top: boxHeight,
                                            right: 5),
                                      ),
                                      style: TextStyle(
                                        decorationThickness: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: mediaHeight(context, 0.04),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ' 개수',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: SizedBox(
                                        height: tempHeight,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color: Colors.black,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    if (count > 0) {
                                                      count--;
                                                    }
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.remove,
                                                  size: 18,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                count.toString(),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    count++;
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.add,
                                                  size: 18,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: mediaHeight(context, 0.05),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    height: 110,
                                    width: (MediaQuery.of(context).size.width -
                                            60) /
                                        2,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text.rich(TextSpan(children: [
                                          TextSpan(
                                              text: ' 제조일자',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        ])),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: SizedBox(
                                            child: TextFormField(
                                              //key: _containerkey,
                                              autovalidateMode:
                                                  AutovalidateMode.always,
                                              onChanged: (value) {
                                                mfd = value;
                                              },
                                              onSaved: (value) {
                                                mfd = value as String;
                                              },
                                              validator: (value) {
                                                int length = value!.length;

                                                if (length == 0) {
                                                  return null;
                                                }

                                                if (length < 10) {
                                                  return "날짜 형식을 확인해주세요.";
                                                } else {
                                                  int year = int.parse(
                                                      value[0] +
                                                          value[1] +
                                                          value[2] +
                                                          value[3]);

                                                  if (year < 2022 ||
                                                      year > 2100) {
                                                    return "날짜 형식을 확인해주세요.";
                                                  } else {
                                                    int month = int.parse(
                                                        value[5] + value[6]);

                                                    if (month < 1 ||
                                                        month > 12) {
                                                      return "날짜 형식을 확인해주세요.";
                                                    } else {
                                                      int day = int.parse(
                                                          value[8] + value[9]);

                                                      if (month == 1 ||
                                                          month == 3 ||
                                                          month == 5 ||
                                                          month == 7 ||
                                                          month == 8 ||
                                                          month == 10 ||
                                                          month == 12) {
                                                        if (day < 1 ||
                                                            day > 31) {
                                                          return "날짜 형식을 확인해주세요.";
                                                        }
                                                      } else if (month == 4 ||
                                                          month == 6 ||
                                                          month == 9 ||
                                                          month == 11) {
                                                        if (day < 1 ||
                                                            day > 30) {
                                                          return "날짜 형식을 확인해주세요.";
                                                        }
                                                      } else {
                                                        if (((year % 4) == 0 &&
                                                                (year % 100) !=
                                                                    0 ||
                                                            (year % 400) ==
                                                                0)) {
                                                          //윤년
                                                          if (day < 1 ||
                                                              day > 29) {
                                                            return "날짜 형식을 확인해주세요.";
                                                          }
                                                        } else {
                                                          //평년
                                                          if (day < 1 ||
                                                              day > 28) {
                                                            return "날짜 형식을 확인해주세요.";
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                                return null;
                                              },
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    8),
                                                NumberFormatter(),
                                              ],
                                              decoration: InputDecoration(
                                                isDense: true,
                                                border: InputBorder.none,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5)),
                                                  borderSide: BorderSide(
                                                      width: 2,
                                                      color: Colors.black),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5)),
                                                  borderSide: BorderSide(
                                                      width: 2,
                                                      color: Colors.black),
                                                ),
                                                errorStyle: TextStyle(
                                                    color: Colors.green),
                                                contentPadding: EdgeInsets.only(
                                                    left: 10,
                                                    bottom: 0,
                                                    top: boxHeight,
                                                    right: 5),
                                                hintText: '$today',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              style: TextStyle(
                                                decorationThickness: 0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 110,
                                    width: (MediaQuery.of(context).size.width -
                                            60) /
                                        2,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text.rich(TextSpan(children: [
                                          TextSpan(
                                              text: ' 유통기한',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        ])),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: SizedBox(
                                            child: TextFormField(
                                              //key: _containerkey,
                                              autovalidateMode:
                                                  AutovalidateMode.always,
                                              onChanged: (value) {
                                                exp = value;
                                              },
                                              onSaved: (value) {
                                                exp = value as String;
                                              },
                                              validator: (value) {
                                                int length = value!.length;

                                                if (length == 0) {
                                                  return null;
                                                }

                                                if (length < 10) {
                                                  return "날짜 형식을 확인해주세요.";
                                                } else {
                                                  int year = int.parse(
                                                      value[0] +
                                                          value[1] +
                                                          value[2] +
                                                          value[3]);

                                                  if (year < 2022 ||
                                                      year > 2100) {
                                                    return "날짜 형식을 확인해주세요.";
                                                  } else {
                                                    int month = int.parse(
                                                        value[5] + value[6]);

                                                    if (month < 1 ||
                                                        month > 12) {
                                                      return "날짜 형식을 확인해주세요.";
                                                    } else {
                                                      int day = int.parse(
                                                          value[8] + value[9]);

                                                      if (month == 1 ||
                                                          month == 3 ||
                                                          month == 5 ||
                                                          month == 7 ||
                                                          month == 8 ||
                                                          month == 10 ||
                                                          month == 12) {
                                                        if (day < 1 ||
                                                            day > 31) {
                                                          return "날짜 형식을 확인해주세요.";
                                                        }
                                                      } else if (month == 4 ||
                                                          month == 6 ||
                                                          month == 9 ||
                                                          month == 11) {
                                                        if (day < 1 ||
                                                            day > 30) {
                                                          return "날짜 형식을 확인해주세요.";
                                                        }
                                                      } else {
                                                        if (((year % 4) == 0 &&
                                                                (year % 100) !=
                                                                    0 ||
                                                            (year % 400) ==
                                                                0)) {
                                                          //윤년
                                                          if (day < 1 ||
                                                              day > 29) {
                                                            return "날짜 형식을 확인해주세요.";
                                                          }
                                                        } else {
                                                          //평년
                                                          if (day < 1 ||
                                                              day > 28) {
                                                            return "날짜 형식을 확인해주세요.";
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                                return null;
                                              },
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    8),
                                                NumberFormatter(),
                                              ],
                                              decoration: InputDecoration(
                                                isDense: true,
                                                border: InputBorder.none,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5)),
                                                  borderSide: BorderSide(
                                                      width: 2,
                                                      color: Colors.black),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5)),
                                                  borderSide: BorderSide(
                                                      width: 2,
                                                      color: Colors.black),
                                                ),
                                                errorStyle: TextStyle(
                                                    color: Colors.green),
                                                contentPadding: EdgeInsets.only(
                                                    left: 10,
                                                    bottom: 0,
                                                    top: boxHeight,
                                                    right: 5),
                                                hintText: '$today',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              style: TextStyle(
                                                decorationThickness: 0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: mediaWidth(context, 1),
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          buttonCount = 1;

                          if (_formKey.currentState!.validate()) {
                            final storage = FlutterSecureStorage();
                            final accessToken =
                                await storage.read(key: 'ACCESS_TOKEN');

                            var dio = await authDio();
                            dio.options.headers['Authorization'] =
                                '$accessToken';
                            final response = await dio
                                .post('/api/v1/user/tool/custom', data: {
                              "name": name,
                              "toolExplain": toolExplain,
                              "count": count,
                              "locate": locate,
                              "exp": exp,
                              "mfd": mfd,
                            });

                            if (response.statusCode == 200) {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          BulidBottomAppBar(
                                            index: 0,
                                          )),
                                  (route) => false);
                            } else {
                              throw Exception('Failed to Load');
                            }
                          }
                        },
                        child: Text(
                          "등록하기",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          )),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

class NumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex <= 4) {
        if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
          buffer.write('-');
        }
      } else {
        if (nonZeroIndex % 6 == 0 &&
            nonZeroIndex != text.length &&
            nonZeroIndex > 5) {
          buffer.write('-');
        }
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}
