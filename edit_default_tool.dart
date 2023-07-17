import 'package:elib_project/models/bottom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:elib_project/auth_dio.dart';
import 'package:elib_project/pages/tool_manage.dart';
import 'package:intl/intl.dart';

double appBarHeight = 50;

double mediaHeight(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.height -  MediaQuery.of(context).padding.top) * scale;

double mediaWidth(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.width) * scale;

String today = getToday();
String getToday() {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd');
  String strToday = formatter.format(now);
  return strToday;
}

int count = 0;

class editDefaultToolPage extends StatefulWidget {
  editDefaultToolPage({
    Key? key,
    required this.tool,
    required this.count,
  }) : super(key: key);

  dynamic tool;
  final count;

  @override
  State<editDefaultToolPage> createState() => _editDefaultToolPageState();
}

class _editDefaultToolPageState extends State<editDefaultToolPage> {
  final GlobalKey _containerkey = GlobalKey();
  final _formKey = GlobalKey<FormState>();

  String? name = null;
  String? toolExplain = null;
  String? locate = null;
  String? exp = null;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        tempHeight = _getSize()!.height;
      });
    });

    count = widget.count;
    exp = widget.tool.exp;
    if (exp == null) {
      exp = "";
    }
    locate = widget.tool.locate;
    if (locate == null) {
      locate = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final boxHeight = mediaHeight(context, 0.03);

    dynamic tool = widget.tool;

    TextEditingController _nameController =
        TextEditingController(text: tool.name);
    TextEditingController _toolExplainController =
        TextEditingController(text: tool.toolExplain);
    TextEditingController _locateController =
        TextEditingController(text: locate);
    _locateController.selection =
        TextSelection.collapsed(offset: locate!.length);
    TextEditingController _expController = TextEditingController(text: exp);
    _expController.selection = TextSelection.collapsed(offset: exp!.length);

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
                  ' 도구 편집',
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
          ),
          body: SafeArea(
              top: true,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0, left: 20, right: 20),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      height: mediaHeight(context, 0.9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(height: mediaHeight(context, 0.01),),
                    
                          Text.rich(TextSpan(children: [
                            TextSpan(
                                text: '제품명',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                )),
                          ])),
                          SizedBox(
                            child: TextFormField(
                              controller: _nameController,
                              enabled: false,
                              decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: EdgeInsets.only(
                                    left: 10, bottom: 0, top: boxHeight, right: 5),
                              ),
                              style: TextStyle(
                                decorationThickness: 0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    
                          SizedBox(height: mediaHeight(context, 0.02),),
                    
                          Text(
                            '상세정보',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          TextFormField(
                            maxLines: 3,
                            controller: _toolExplainController,
                            enabled: false,
                            decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ), //검색 아이콘 추가
                              contentPadding: EdgeInsets.only(
                                  left: 10, bottom: 0, top: boxHeight, right: 5),
                            ),
                            style: TextStyle(
                              decorationThickness: 0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    
                          SizedBox(height: mediaHeight(context, 0.02),),
                    
                          Text(
                            '위치',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          TextFormField(
                            controller: _locateController,
                            onChanged: (value) {
                              locate = value;
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide:
                                    BorderSide(width: 2, color: Colors.black),
                              ),
                              contentPadding: EdgeInsets.only(
                                  left: 10, bottom: 0, top: boxHeight, right: 5),
                            ),
                            style: TextStyle(
                              decorationThickness: 0,
                            ),
                          ),
                    
                          SizedBox(height: mediaHeight(context, 0.02),),
                    
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 120,
                                width:
                                    (MediaQuery.of(context).size.width - 60) / 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(TextSpan(children: [
                                      TextSpan(
                                          text: '유통기한',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ])),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 0),
                                      child: SizedBox(
                                        child: TextFormField(
                                          key: _containerkey,
                                          controller: _expController,
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
                                              int year = int.parse(value[0] +
                                                  value[1] +
                                                  value[2] +
                                                  value[3]);
                    
                                              if (year < 2022 || year > 2100) {
                                                return "날짜 형식을 확인해주세요.";
                                              } else {
                                                int month = int.parse(
                                                    value[5] + value[6]);
                    
                                                if (month < 1 || month > 12) {
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
                                                    if (day < 1 || day > 31) {
                                                      return "날짜 형식을 확인해주세요.";
                                                    }
                                                  } else if (month == 4 ||
                                                      month == 6 ||
                                                      month == 9 ||
                                                      month == 11) {
                                                    if (day < 1 || day > 30) {
                                                      return "날짜 형식을 확인해주세요.";
                                                    }
                                                  } else {
                                                    if (((year % 4) == 0 &&
                                                            (year % 100) != 0 ||
                                                        (year % 400) == 0)) {
                                                      //윤년
                                                      if (day < 1 || day > 29) {
                                                        return "날짜 형식을 확인해주세요.";
                                                      }
                                                    } else {
                                                      //평년
                                                      if (day < 1 || day > 28) {
                                                        return "날짜 형식을 확인해주세요.";
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                            return null;
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(8),
                                            NumberFormatter(),
                                          ],
                                          decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                              borderSide: BorderSide(
                                                  width: 2, color: Colors.black),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
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
                                height: 120,
                                width:
                                    (MediaQuery.of(context).size.width - 60) / 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '개수',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 0),
                                      child: SizedBox(
                                        height: tempHeight,
                                        child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                          borderRadius: BorderRadius.circular(10),
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
                                                size: 20,
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
                                                size: 20,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                    
                          SizedBox(height: mediaHeight(context, 0.05),),
                    
                          Center(
                            child: Container(
                              width: 120,
                              height: 40,
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
                                        .post('/api/v1/user/tool/default', data: {
                                      "toolId": tool.toolId,
                                      "count": count,
                                      "locate": locate,
                                      "exp": exp,
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
                                  "편집하기",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.green),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                                ),
                              ),
                            ),
                          ),
                    
                          SizedBox(height: mediaHeight(context, 0.1),),
                        ],
                      ),
                    ),
                  ),
                ),
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
