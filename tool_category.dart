import 'dart:convert';

import 'package:elib_project/models/bottom_app_bar.dart';
import 'package:elib_project/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:elib_project/auth_dio.dart';
import 'package:elib_project/pages/tool_manage.dart';
import 'package:intl/intl.dart';

double appBarHeight = 40;
double mediaHeight(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.height - appBarHeight) * scale;
double mediaWidth(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.width) * scale;

double containerHeight = 35;

IconData openEye = Icons.visibility_outlined;
IconData closedEye = Icons.visibility_off_outlined;

List toolCategories2 = [];

class toolCategoryPage extends StatefulWidget {
  toolCategoryPage({
    Key? key,
  }) : super(key: key);

  @override
  State<toolCategoryPage> createState() => _toolCategoryPageState();
}

class _toolCategoryPageState extends State<toolCategoryPage> {
  
  @override
  void initState() {
    loadCategory = init();
    super.initState();
  }

  Future<void> init() async {

    String? toolStorage = await storage.read(key: 'Category_Tool');
    String? toolStorage2 = await storage.read(key: 'Category_Tool_2');

    if(toolStorage == null || toolStorage == "") {
      toolCategories = ["전체", "화재", "응급", "지진", "생존", "전쟁", "수해", "기타"];
      await storage.write(key: 'Category_Tool', value: jsonEncode(toolCategories));
    } else {
      toolCategories = jsonDecode(toolStorage);
    }

    if(toolStorage2 == null || toolStorage2 == "") {
      toolCategories2 = toolCategories;
      await storage.write(key: 'Category_Tool_2', value: jsonEncode(toolCategories2));

      toolStorage2 = await storage.read(key: 'Category_Tool_2');
      toolCategories2 = jsonDecode(toolStorage2!);
    } else {
      toolCategories2 = jsonDecode(toolStorage2);
    }
  }

  void updateCategories(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex--;
      }

      //움직이는 카테고리
      final category = toolCategories2.removeAt(oldIndex);

      //카테고리의 새 위치
      toolCategories2.insert(newIndex, category);
    });

    storage.write(key: 'Category_Tool_2', value: jsonEncode(toolCategories2));

    List temp = [];

    for(var i=0; i<toolCategories2.length; i++) {
      if(toolCategories.contains(toolCategories2[i]) == true) {
        temp.add(toolCategories2[i]);
      } else{
      }
    }

    toolCategories = temp;
    storage.write(key: 'Category_Tool', value: jsonEncode(temp));
  }

  @override
  Widget build(BuildContext context) {
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
                  '카테고리 설정',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context); // 뒤로가기 버튼 클릭 이벤트 처리
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 5, bottom: 0),
                child: TextButton(
                  onPressed: () async {
                    List initCategories = ["전체", "화재", "응급", "지진", "생존", "전쟁", "수해", "기타"];
                    
                    await storage.write(key: 'Category_Tool', value: jsonEncode(initCategories));
                    await storage.write(key: 'Category_Tool_2', value: jsonEncode(initCategories));

                    String? toolStorage = await storage.read(key: 'Category_Tool');
                    String? toolStorage2 = await storage.read(key: 'Category_Tool_2');

                    toolCategories = jsonDecode(toolStorage!);
                    toolCategories2 = jsonDecode(toolStorage2!);
                    setState(() {});
                  },
                  child: Text(
                    "초기화",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Theme(
            data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
            child: SafeArea(
              top: true,
              child: Column(
                children: [
                  Expanded(
                    child: FutureBuilder<void>(
                      future: loadCategory,
                      builder: (context, snapshot) {
                         return ReorderableListView.builder(
                          onReorder: (oldIndex, newIndex) =>
                            updateCategories(oldIndex, newIndex),
                            itemCount: toolCategories2.length,
                             itemBuilder: (context, i) {
                               var category = toolCategories2[i];

                               IconData eye = Icons.visibility_outlined;
                               if(toolCategories.contains(category) == false) {
                                eye = Icons.visibility_off_outlined;
                               }
                                          
                                return Container(
                                  key: Key(category),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10, bottom: 10,),
                                    child: Container(
                                     width: mediaWidth(context, 1),
                                     height: containerHeight,
                                      child: Row(
                                        //crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Stack(
                                            children:[
                                              Container(
                                                height: containerHeight,
                                                width: mediaWidth(context, 1),
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 10),
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 5),
                                                    child: Text(
                                                      category,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.grey.shade600,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              Container(
                                                width: mediaWidth(context, 1),
                                                height: containerHeight,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(right: 5),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                        width: containerHeight,
                                                        height: containerHeight,
                                                        child: IconButton(
                                                          icon: Icon(
                                                            eye,
                                                              size: 25,
                                                              color: Colors.grey,
                                                            ),
                                                            onPressed: () async {
                                                              if(toolCategories.contains(category) == true) {
                                                                toolCategories.removeWhere((item) => item == category);     
                                                                await storage.write(key: 'Category_Tool', value: jsonEncode(toolCategories));
                                                              } else {
                                                                toolCategories.add(category); 
                                                                List temp = [];

                                                                for(var i=0; i<toolCategories2.length; i++) {
                                                                  if(toolCategories.contains(toolCategories2[i]) == true) {
                                                                    temp.add(toolCategories2[i]);
                                                                  } else{
                                                                    
                                                                  }
                                                                }

                                                                toolCategories = temp;
                                                                await storage.write(key: 'Category_Tool', value: jsonEncode(temp));
                                                              }  
                                                              setState(() {   
                                                              });                   //Navigator.push(context, MaterialPageRoute(builder: (context) => toolRegistPage()));
                                                            },
                                                        ),
                                                      ),
                                                  
                                                      Container(
                                                        width: containerHeight,
                                                        height: containerHeight,
                                                        child: IconButton(
                                                          icon: Icon(
                                                            Icons.menu,
                                                              size: 25,
                                                              color: Colors.grey,
                                                            ),
                                                            onPressed: () {
                                                                                            //Navigator.push(context, MaterialPageRoute(builder: (context) => toolRegistPage()));
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ]
                                          )
                                          
                                        ],
                                      ),
                                    )
                                  )
                                );
                             }
                         );
                      }
                    ),
                  ),
                ],
              )
            ),
          )
        )
      )
    );
  }
}
