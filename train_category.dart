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

List trainCategories2 = [];

class trainCategoryPage extends StatefulWidget {
  trainCategoryPage({
    Key? key,
  }) : super(key: key);

  @override
  State<trainCategoryPage> createState() => _trainCategoryPageState();
}

class _trainCategoryPageState extends State<trainCategoryPage> {
  
  @override
  void initState() {
    loadCategoryTr = initTr();
    super.initState();
  }

    Future<void> initTr() async {

    String? trainStorage = await storage.read(key: 'Category_Train');
    String? trainStorage2 = await storage.read(key: 'Category_Train_2');

    if(trainStorage == null || trainStorage == "") {
      trainCategories = ["전체", "화재", "응급", "지진", "생존", "전쟁", "수해", "기타"];
      await storage.write(key: 'Category_Train', value: jsonEncode(trainCategories));
    } else {
      trainCategories = jsonDecode(trainStorage);
    }

    if(trainStorage2 == null || trainStorage2 == "") {
      trainCategories2 = trainCategories;
      await storage.write(key: 'Category_Train_2', value: jsonEncode(trainCategories2));

      trainStorage2 = await storage.read(key: 'Category_Train_2');
      trainCategories2 = jsonDecode(trainStorage2!);
    } else {
      trainCategories2 = jsonDecode(trainStorage2);
    }
  }

  void updateCategoriesTr(int oldIndex, int newIndex) {
      setState(() {
        if (oldIndex < newIndex) {
          newIndex--;
        }

        //움직이는 카테고리
        final category = trainCategories2.removeAt(oldIndex);

        //카테고리의 새 위치
        trainCategories2.insert(newIndex, category);
      });

      storage.write(key: 'Category_Train_2', value: jsonEncode(trainCategories2));

      List temp = [];

      for(var i=0; i<trainCategories2.length; i++) {
        if(trainCategories.contains(trainCategories2[i]) == true) {
          temp.add(trainCategories2[i]);
        } else{
        }
      }

      trainCategories = temp;
      storage.write(key: 'Category_Train', value: jsonEncode(temp));
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
                    
                    await storage.write(key: 'Category_Train', value: jsonEncode(initCategories));
                    await storage.write(key: 'Category_Train_2', value: jsonEncode(initCategories));

                    String? trainStorage = await storage.read(key: 'Category_Train');
                    String? trainStorage2 = await storage.read(key: 'Category_Train_2');

                    trainCategories = jsonDecode(trainStorage!);
                    trainCategories2 = jsonDecode(trainStorage2!);
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
                      future: loadCategoryTr,
                      builder: (context, snapshot) {
                         return ReorderableListView.builder(
                          onReorder: (oldIndex, newIndex) =>
                            updateCategoriesTr(oldIndex, newIndex),
                            itemCount: trainCategories2.length,
                             itemBuilder: (context, i) {
                               var category = trainCategories2[i];

                               IconData eye = Icons.visibility_outlined;
                               if(trainCategories.contains(category) == false) {
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
                                                              if(trainCategories.contains(category) == true) {
                                                                trainCategories.removeWhere((item) => item == category);     
                                                                await storage.write(key: 'Category_Train', value: jsonEncode(trainCategories));
                                                              } else {
                                                                trainCategories.add(category); 
                                                                List temp = [];

                                                                for(var i=0; i<trainCategories2.length; i++) {
                                                                  if(trainCategories.contains(trainCategories2[i]) == true) {
                                                                    temp.add(trainCategories2[i]);
                                                                  } else{
                                                                    
                                                                  }
                                                                }

                                                                trainCategories = temp;
                                                                await storage.write(key: 'Category_Train', value: jsonEncode(temp));
                                                              }  
                                                              setState(() { 
                                                              });                   
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
