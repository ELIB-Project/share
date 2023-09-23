import 'package:elib_project/pages/home_page.dart';
import 'package:elib_project/pages/tool_regist.dart';
import 'package:elib_project/pages/train_category.dart';
import 'package:elib_project/pages/view.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io'; //쿠키
import 'package:elib_project/auth_dio.dart';

double appBarHeight = 40;
double mediaHeight(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.height - appBarHeight) * scale;
double mediaWidth(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.width) * scale;

double topFontSize = 20;

Color tileColor = Colors.grey.shade300;
Color categoryText = Colors.grey;

const storage = FlutterSecureStorage();

class trainList {
  final int id;
  final String? name;
  final List? imgUrl;
  final List? videoUrl;
  bool? imgComplete;
  bool? videoComplete;
  final String? type;

  trainList({
    required this.id,
    required this.name,
    required this.imgUrl,
    required this.videoUrl,
    required this.imgComplete,
    required this.videoComplete,
    required this.type,
  });

  factory trainList.fromJson(Map<String, dynamic> json) {
    return trainList(
      id: json['id'],
      name: json['name'],
      imgUrl: json['imgUrl'],
      videoUrl: json['videoUrl'],
      imgComplete: json['imgComplete'],
      videoComplete: json['videoComplete'],
      type: json['type'],
    );
  }
}


class trainPage extends StatefulWidget {
  const trainPage({super.key});

  @override
  State<trainPage> createState() => _trainPageState();
}

class _trainPageState extends State<trainPage> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => true;
  

  void viewTrain(trainList) {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => trainRegistpage(
              train: trainList,
            )))
        .then((value) {
      setState(() {
        futureTrainList = loadTrainList();
      });
    });
  }

  @override
  void initState() {
    loadCategoryTr = initTr();
    futureTrainList = loadTrainList();

    super.initState();
  }

  void updateCategoriesTr(int oldIndex, int newIndex) {
    const storage = FlutterSecureStorage();

    setState(() {
      if (oldIndex < newIndex) {
        newIndex--;
      }

      //움직이는 카테고리
      final category = trainCategories.removeAt(oldIndex);

      //카테고리의 새 위치
      trainCategories.insert(newIndex, category);
    });

    storage.write(key: 'Category_Train', value: jsonEncode(trainCategories));
  }

  
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Color.fromARGB(255, 250, 250, 250),
          colorSchemeSeed: Color.fromARGB(0, 241, 241, 241),
          useMaterial3: true),
        home: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
              appBar: AppBar(
                title: Title(
                    color: Color.fromRGBO(87, 87, 87, 1),
                    child: Text(
                      '훈련',
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
                        Icons.visibility_outlined,
                        size: 30,
                        color: Colors.grey.shade500,
                      ),
                      onPressed: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => trainCategoryPage())).then((value) {
                          setState(() {
                            loadCategoryTr = initTr();
                            futureTrainList = loadTrainList();
                          });
                        });
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => toolRegistPage()));
                      },
                    ),
                  ),
                ],
              ),
              body: SafeArea(
                  top: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: mediaHeight(context, 0.01),
                      ),

                      //미이수 내역
                      Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Container(
                            width: mediaWidth(context, 1),
                            height: mediaHeight(context, 0.07),
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
                                  const BorderRadius.all(Radius.circular(10)),
                              color: Color(0xFFFFF3B2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FutureBuilder<List<trainList>>(
                                  future: futureTrainList,
                                  builder: (context, snapshot) {
                                    return Text.rich(TextSpan(children: [
                                      TextSpan(
                                          text: textA,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: topFontSize,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      TextSpan(
                                          text: textB,
                                          style: TextStyle(
                                            color: colorB,
                                            fontSize: topFontSize,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      TextSpan(
                                          text: textC,
                                          style: TextStyle(
                                            color: colorC,
                                            fontSize: topFontSize,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      TextSpan(
                                          text: textD,
                                          style: TextStyle(
                                            color: colorD,
                                            fontSize: topFontSize,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      TextSpan(
                                          text: textE,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: topFontSize,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ]));
                                  }
                                ),
                              ],
                            ),
                          )),

                      SizedBox(
                        height: mediaHeight(context, 0.03),
                      ),

                      //카테고리
                      Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            //color: Colors.grey.shade300,
                            height: mediaHeight(context, 1),
                            width: categoryWidth,
                            child: Column(
                              children: [
                                
                                Expanded(
                                  //height: mediaHeight(context, 1) - 10,
                                  child: FutureBuilder<void>(
                                    future: loadCategoryTr,
                                    builder: (context, snapshot) {
                                      return ReorderableListView.builder(
                                        onReorder: (oldIndex, newIndex) =>
                                            updateCategoriesTr(oldIndex, newIndex),
                                        itemCount: trainCategories.length,
                                        itemBuilder: (context, i) {
                                          var category = trainCategories[i];
                                          
                                          if(category == selectedCategoryTr) {
                                            tileColor = Colors.grey.shade400;
                                            categoryText = Colors.white;
                                          } else { 
                                            tileColor = Colors.white;
                                            categoryText = Colors.grey.shade400;
                                          }
                                
                                        return
                                            Container(
                                              //color: tileColor,
                                              //color: Colors.white,
                                              key: Key(category),
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                                                child: Container(
                                                  height: 30,
                                                    decoration: BoxDecoration(
                                                      color: tileColor,
                                                      borderRadius:
                                                          BorderRadius.circular(20),
                                                      border: Border.all(
                                                        color: categoryText,
                                                        width: 1,
                                                      ),
                                                    ),
                                                  child: Stack(
                                                    children: [
                                                      Center(
                                                        child: Text(
                                                          category,
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.normal,
                                                            color: categoryText,
                                                            fontSize: 15,
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                      ListTile(
                                                      //tileColor: tileColor,
                                                      // title: Text(
                                                      //   category,
                                                      //   style: TextStyle(
                                                      //     fontWeight: FontWeight.normal,
                                                      //     color: categoryText,
                                                      //     fontSize: 15,
                                                      //   ),
                                                      // ),
                                                      onTap: () {
                                                                  
                                                        selectedCategoryTr = category;
                                                    
                                                        selectedLengthTr = allTrain?.length;
                                                        
                                                        switch (selectedCategoryTr) {
                                                          case "전체":
                                                            selectedLengthTr = allTrain?.length;
                                                            trainView = allTrain;
                                                          case "화재":
                                                            selectedLengthTr = fireTr?.length;
                                                            trainView = fireTr;
                                                          case "응급":
                                                            selectedLengthTr = emergentTr?.length;
                                                            trainView = emergentTr;
                                                          case "지진":
                                                            selectedLengthTr = quakeTr?.length;
                                                            trainView = quakeTr;
                                                          case "생존":
                                                            selectedLengthTr = surviveTr?.length;
                                                            trainView = surviveTr;
                                                          case "전쟁":
                                                            selectedLengthTr = warTr?.length;
                                                            trainView = warTr;
                                                          case "수해":
                                                            selectedLengthTr = floodTr?.length;
                                                            trainView = floodTr;
                                                          case "기타":
                                                            selectedLengthTr = etcTr?.length;
                                                            trainView = etcTr;
                                                        }
                                                        print(selectedCategoryTr);
                                                    
                                                        setState(() {
                                                        });
                                                      },
                                                    ),
                                                    ]
                                                  ),
                                                ),
                                              ),
                                            );
                                        }
                                        
                                      );
                                    }
                                  ),
                                ),
                              ],
                            ),
                          ),

                      //훈련 리스트 출력부분
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              FutureBuilder<List<trainList>>(
                                  future: futureTrainList,
                                  builder: (context, snapshot) {

                                    switch (selectedCategoryTr) {
                                      case "전체":
                                        trainView = allTrain;
                                        selectedLengthTr = allTrain?.length;
                                      case "화재":
                                        trainView = fireTr;
                                        selectedLengthTr = fireTr?.length;
                                      case "응급":
                                        trainView = emergentTr;
                                        selectedLengthTr = emergentTr?.length;
                                      case "지진":
                                        trainView = quakeTr;
                                        selectedLengthTr = quakeTr?.length;
                                      case "생존":
                                        trainView = surviveTr;
                                        selectedLengthTr = surviveTr?.length;
                                      case "전쟁":
                                        trainView = warTr;
                                        selectedLengthTr = warTr?.length;
                                      case "수해":
                                        trainView = floodTr;
                                        selectedLengthTr = floodTr?.length;
                                      case "기타":
                                        trainView = etcTr;
                                        selectedLengthTr = etcTr?.length;
                                    }

                                    if (snapshot.hasError)
                                      return Text('${snapshot.error}');

                                    if (trainView?.isEmpty == true && selectedLengthTr == 0) {
                                      return Container(
                                        height: mediaHeight(context, 0.7),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text("empty")
                                            ]),
                                      );
                                    }

                                    if (trainView!=null)
                                    print(selectedCategoryTr);
                                    print(selectedLengthTr);
                                    print(trainView);

                                      return Column(
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width - categorySpace,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount:
                                                          selectedLengthTr,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemBuilder:
                                                          (context, i) {
                                                        String? name;
                                                        if (trainView?[i]
                                                                    .name ==
                                                                null ||
                                                            trainView?[i]
                                                                    .name ==
                                                                "") {
                                                          name = "test";
                                                        } else {
                                                          name = trainView?[i].name;
                                                        }
                                                                                              
                                                        List? videoUrl =
                                                            trainView?[i]
                                                                .videoUrl;
                                                        List? imgUrl = trainView?[i].imgUrl;
                                                                                              
                                                        bool videoVisible =
                                                            true;
                                                        if (videoUrl!.isEmpty ==
                                                            true) {
                                                          videoVisible = false;
                                                        }
                                                                                              
                                                        bool imgVisible = true;
                                                        if (imgUrl!.isEmpty ==
                                                            true) {
                                                          imgVisible = false;
                                                        }
                                                                                              
                                                        IconData? iconName;
                                                        int iconColor;
                                                                                              
                                                        bool? imgComplete = trainView?[i].imgComplete;
                                                        bool? videoComplete = trainView?[i].videoComplete;
                                                        if(imgComplete == true && videoComplete == true) {
                                                          iconName = Icons.check_circle;
                                                        iconColor = 0xFF38AE5D;
                                                        } else {
                                                          iconName = Icons.report_outlined;
                                                          iconColor = 0xFFF16969;
                                                        }
                                                                                              
                                                        return InkWell(
                                                            onTap: () {
                                                              viewTrain(trainView?[i]);
                                                            },
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              15,
                                                                          bottom:
                                                                              15),
                                                                      child:
                                                                          Text(
                                                                        '$name ',
                                                                        style:
                                                                            TextStyle(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade600,
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Visibility(
                                                                      visible:
                                                                          imgVisible,
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .description,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade400,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                    Visibility(
                                                                      visible:
                                                                          videoVisible,
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .videocam,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade400,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Icon(
                                                                  iconName,
                                                                  color: Color(
                                                                      iconColor),
                                                                  size: 25,
                                                                ),
                                                              ],
                                                            ));
                                                      }),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    return Center(
                                      child: Visibility(
                                        visible: true,
                                        child: CircularProgressIndicator()),
                                    )
                                      ;
                                  }),
                            ],
                          ),
                        ),
                      ),
                    ]
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}
