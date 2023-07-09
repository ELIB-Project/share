import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:elib_project/auth_dio.dart';
import 'package:intl/intl.dart';

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
  final _formKey = GlobalKey<FormState>();

  String name = "";
  String? toolExplain = null;
  int count = 0;
  String? locate = null;
  String? exp = null;

  int buttonCount = 0;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorSchemeSeed: const Color(0xff6750a4), useMaterial3: true),
      home: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
              centerTitle: true,
              title:
                Title(color: Color.fromRGBO(87, 87, 87, 1), 
                  child: Text(' 도구 등록',
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
                padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                child: Form(
                  key: _formKey,
                  child: Column( 
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(TextSpan(children: [
                        TextSpan(
                          text: '제품명',
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
                        padding: const EdgeInsets.only(top: 10, bottom: 0),
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

                              if(buttonCount == 1) {
                                if(length < 1) {
                                  return '필수 입력란입니다.';
                                }
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                              focusedBorder:  OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(width: 2, color: Colors.black),
                              ),
                              errorBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(width: 2, color: Colors.black),
                              ),
                              errorStyle: TextStyle(color: Colors.green),
                              contentPadding: EdgeInsets.only(left: 10, bottom: 0, top: 10, right: 5),
                            ),
                            style: TextStyle(
                              decorationThickness: 0,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20, ),
                      
                      Text(
                       '상세정보',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 0),
                        child: TextField(
                          onChanged: (value) {
                              toolExplain = value;
                          },
                          maxLines: 3,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10)
                                            ),
                            focusedBorder:  OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(width: 2, color: Colors.black),
                            ), //검색 아이콘 추가
                            contentPadding: EdgeInsets.only(left: 10, bottom: 0, top: 10, right: 5),
                          ),
                          style: TextStyle(
                              decorationThickness: 0,
                            ),
                        ),
                      ),

                      const SizedBox(height: 20, ),
                      
                      Text(
                       '위치',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 0),
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            onChanged: (value) {
                              locate = value;
                            },
                           decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10)
                                              ),
                              focusedBorder:  OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(width: 2, color: Colors.black),
                              ),
                              contentPadding: EdgeInsets.only(left: 10, bottom: 0, top: 10, right: 5),
                            ),
                            style: TextStyle(
                              decorationThickness: 0,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20, ),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 130,
                            width: (MediaQuery.of(context).size.width-60)/2,
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
                                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                                  child: SizedBox(
                                    child: TextFormField(
                                      autovalidateMode: AutovalidateMode.always,
                                      onChanged: (value) {
                                        exp = value;
                                      },  
                                      onSaved: (value) {
                                        exp = value as String;
                                      },
                                      validator: (value) {
                                        int length = value!.length;

                                        if(length == 0) {
                                          return null;
                                        }
                                  
                                        if (length < 10) {
                                          return "날짜 형식을 확인해주세요.";
                                        } else {
                                          int year = int.parse(value[0]+value[1]+value[2]+value[3]);
                                          
                                          if(year < 2022 || year > 2100) {
                                            return "날짜 형식을 확인해주세요.";
                                          } else {
                                            int month = int.parse(value[5]+value[6]);
                                            
                                            if(month < 1 || month > 12) {
                                              return "날짜 형식을 확인해주세요.";
                                            } else {
                                              int day = int.parse(value[8]+value[9]);
                                              
                                              if(month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                                                if(day < 1 || day > 31) {
                                                  return "날짜 형식을 확인해주세요.";
                                                }
                                              } else if(month == 4 || month == 6 || month == 9 || month == 11) {
                                                if(day < 1 || day > 30) {
                                                  return "날짜 형식을 확인해주세요.";
                                                }
                                              } else { 
                                                if (((year % 4) == 0 && (year % 100) != 0 || (year % 400) == 0)) { //윤년
                                                  if(day < 1 || day > 29) {
                                                    return "날짜 형식을 확인해주세요.";
                                                  }
                                                } else { //평년
                                                  if(day < 1 || day > 28) {
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
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(8),
                                        NumberFormatter(),
                                      ],
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10)
                                                          ),
                                          focusedBorder:  OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                            borderSide: BorderSide(width: 2, color: Colors.black),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                            borderSide: BorderSide(width: 2, color: Colors.black),
                                          ),
                                          errorStyle: TextStyle(color: Colors.green),
                                          contentPadding: EdgeInsets.only(left: 10, bottom: 0, top: 10, right: 5),
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
                            height: 130,
                            width: (MediaQuery.of(context).size.width-60)/2,
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
                                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                                  child: SizedBox(
                                    height: 48,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all( 
                                         width: 1,
                                         color: Colors.black, 
                                        ),
                                      borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                if(count>0) {
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
                                    )
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              buttonCount = 1;

                              if (_formKey.currentState!.validate()) {
                                final storage = FlutterSecureStorage();
                                final accessToken = await storage.read(key: 'ACCESS_TOKEN');
                  
                                var dio = await authDio();
                                dio.options.headers['Authorization'] = '$accessToken';
                                final response = await dio.post('/api/v1/user/tool/custom',
                                  data: {
                                    "name": name,
                                    "toolExplain": toolExplain,
                                    "count": count,
                                    "locate": locate,
                                    "exp": exp,
                                  }
                                );
                  
                                if (response.statusCode == 200) {
                                  print(accessToken);
                                  print(response.data);
                                  Navigator.pop(context);
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
                              backgroundColor: MaterialStateProperty.all(Colors.green),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )
                              ),
                            ),      
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ),
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
        if (nonZeroIndex % 6 == 0 && nonZeroIndex != text.length && nonZeroIndex > 5) {
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
