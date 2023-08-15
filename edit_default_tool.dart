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
  String? mfd = null;
  String? maker = null;

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

    mfd = widget.tool.mfd;
    if (mfd == null) {
      mfd = "";
    }

    maker = widget.tool.maker;
    if (maker == null) {
      maker = "";
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
    TextEditingController _mfdController = TextEditingController(text: mfd);
    _mfdController.selection =TextSelection.collapsed( offset: mfd!.length);
    TextEditingController _makerController = TextEditingController(text: maker);

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
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0, left: 20, right: 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: mediaHeight(context, 0.03),),
                          
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: '제품명',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ])),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: SizedBox(
                                  child: TextFormField(
                                    controller: _nameController,
                                    enabled: false,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
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
                              ),
                          
                              SizedBox(height: mediaHeight(context, 0.04),),
                          
                              Text(
                                '상세정보',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: TextFormField(
                                  maxLines: 3,
                                  controller: _toolExplainController,
                                  enabled: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ), //검색 아이콘 추가
                                    contentPadding: EdgeInsets.only(
                                        left: 10, bottom: 0, top: boxHeight, right: 5),
                                  ),
                                  style: TextStyle(
                                    decorationThickness: 0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          
                              SizedBox(height: mediaHeight(context, 0.04),),
                          
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '위치',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: TextFormField(
                                  key: _containerkey,
                                  controller: _locateController,
                                  onChanged: (value) {
                                    locate = value;
                                  },
                                  decoration: InputDecoration(
                                    isDense: true,
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
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
                              ),
                          
                              SizedBox(height: mediaHeight(context, 0.04),),

                              Column(
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
                                    padding: const EdgeInsets.only(top: 5, bottom: 0),
                                    child: SizedBox(
                                      height: tempHeight,
                                      child:  Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1,
                                                color: Colors.black,
                                              ),
                                              borderRadius: BorderRadius.circular(5),
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
                                          )
                                      )
                                  )
                                ],
                              ),

                              SizedBox(
                                height: mediaHeight(context, 0.05),
                              ),
                          
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    height: 110,
                                    width: (MediaQuery.of(context).size.width - 60) / 2,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text.rich(TextSpan(children: [
                                          TextSpan(
                                              text: '제조일자',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        ])),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5),
                                          child: SizedBox(
                                            child: TextFormField(
                                              controller: _mfdController,
                                              enabled: false,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                contentPadding: EdgeInsets.only(
                                                    left: 10,
                                                    bottom: 0,
                                                    top: boxHeight,
                                                    right: 5),
                                              ),
                                              style: TextStyle(
                                                decorationThickness: 0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          
                                  SizedBox(
                                    height: 110,
                                    width: (MediaQuery.of(context).size.width - 60) / 2,
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
                                          padding: const EdgeInsets.only(top: 5),
                                          child: SizedBox(
                                            child: TextFormField(
                                              controller: _expController,
                                              enabled: false,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                contentPadding: EdgeInsets.only(
                                                    left: 10,
                                                    bottom: 0,
                                                    top: boxHeight,
                                                    right: 5),
                                              ),
                                              style: TextStyle(
                                                decorationThickness: 0,
                                                fontWeight: FontWeight.bold,
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

                          print("mfd $mfd");
                          print("exp $exp");
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
                          "편집하기",
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
