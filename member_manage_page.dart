import "package:elib_project/pages/alarm_page.dart";
import "package:elib_project/pages/edit_family_name.dart";
import "package:elib_project/pages/enter_code_page.dart";
import "package:elib_project/pages/group_add_page.dart";
import "package:elib_project/pages/member_info_page.dart";
import "package:elib_project/pages/member_invite_page.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:flutter/material.dart";
import "package:kakao_flutter_sdk/kakao_flutter_sdk_share.dart";
import "../auth_dio.dart";
import "../models/bottom_app_bar.dart";

class GlobalData {
  static double queryWidth = 0.0;
  static double queryHeight = 0.0;
}

class MemberManagementPage extends StatefulWidget {
  const MemberManagementPage({
    Key? key,
  }) : super(key: key);

  @override
  _MemberManagementPageState createState() => _MemberManagementPageState();
}

class _MemberManagementPageState extends State<MemberManagementPage> {
  @override
  Widget build(BuildContext context) {
    GlobalData.queryHeight = MediaQuery.of(context).size.height;
    GlobalData.queryWidth = MediaQuery.of(context).size.width;
    // 여기에 위젯을 구성하는 코드를 작성합니다.
    // 예: Scaffold, Column, ListView 등을 사용하여 화면을 구성합니다.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 250, 250, 250),
          colorSchemeSeed: const Color.fromARGB(0, 241, 241, 241),
          useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: const Color.fromARGB(255, 250, 250, 250),
          title: Title(
              color: const Color.fromRGBO(87, 87, 87, 1),
              child: const Text(
                "구성원관리",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              )),
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.send),
            //   onPressed: () {
            //     // _navigateToInvitePage(context);
            //     _showBottomSheet();
            //   },
            // ),
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                _navigateToAlarmPage(context);
              },
            ),
          ],
        ),
        body: SafeArea(
            child: Column(
          children: [
            // Container(
            //   height: 2.0,
            //   color: const Color.fromRGBO(171, 171, 171, 0.5),
            // ),
            Expanded(
                child: Stack(children: [
              VerticalTabBarLayout(),
              // ListBuild(context),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Ink(
                            decoration: const ShapeDecoration(
                              color: Colors.green,
                              shape: CircleBorder(),
                            ),
                            child: Center(
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  size: 40,
                                ),
                                color: Colors.white,
                                onPressed: () {
                                  _showBottomSheet();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ])),
          ],
        )),
        extendBodyBehindAppBar: true, // AppBar가 배경 이미지를 가리지 않도록 설정
      ),
    );
  }

  _showBottomSheet() async {
    // String? url = await receiveKakaoScheme();
    // ignore: use_build_context_synchronously
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                _navigateToInvitePage(context);
              },
              child: const SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10),
                      child: Icon(
                        Icons.send,
                        size: 30,
                        color: Colors.lightBlue,
                      ),
                    ),
                    Text(
                      '전화번호로 구성원 초대',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    )
                  ],
                ),
              ),
            ),
            const Divider(
              thickness: 3,
            ),
            InkWell(
              onTap: () async {
                int templateId = 97413;
                String code = await creatInviteCode();
                String url = "http://test.elibtest.r-e.kr:8080";
                // final defaultText = await texttemplate();
                bool isKakaoTalkSharingAvailable =
                    await ShareClient.instance.isKakaoTalkSharingAvailable();
                if (isKakaoTalkSharingAvailable) {
                  try {
                    Uri uri = await ShareClient.instance.shareScrap(
                        templateId: templateId,
                        url: url,
                        templateArgs: {'code': code});
                    await ShareClient.instance.launchKakaoTalk(uri);
                    print('카카오톡 공유 완료');
                  } catch (error) {
                    print('카카오톡 공유 실패 $error');
                  }
                } else {
                  try {
                    Uri shareUrl = await WebSharerClient.instance.makeScrapUrl(
                        url: url,
                        templateId: templateId,
                        templateArgs: {'code': code});
                    await launchBrowserTab(shareUrl, popupOpen: true);
                  } catch (error) {
                    print('카카오톡 공유 실패 $error');
                  }
                }
              },
              child: Container(
                height: 50,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10),
                      child: Image.asset(
                        'assets/image/talkicon.png',
                        width: 30,
                      ),
                    ),
                    const Text(
                      '카카오톡으로 구성원 초대',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              thickness: 3,
            ),
            InkWell(
              onTap: () {
                _navigateToEnterCodePage(context);
              },
              child: Container(
                height: 50,
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10),
                      child: Icon(Icons.add_box_outlined,
                          size: 30, color: Colors.green),
                    ),
                    Text(
                      '초대코드 입력',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

Future<List<familyName>> getEntries() async {
  List<familyName> entries = await loadFamilyInfo();
  return entries;
}

Widget ListBuild(BuildContext context) {
  return FutureBuilder<List<familyName>>(
    future: getEntries(), // entries를 얻기 위해 Future를 전달
    builder: (BuildContext context, AsyncSnapshot<List<familyName>> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // 데이터를 아직 받아오는 중이면 로딩 표시를 보여줌
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        // 데이터를 받아오는 도중 에러가 발생하면 에러 메시지를 보여줌
        return Text('Error: ${snapshot.error}');
      } else {
        // 데이터를 정상적으로 받아왔을 경우
        List<familyName> entries = snapshot.data!; // 해결된 데이터를 얻음

        return Container(
          width: GlobalData.queryWidth,
          height: GlobalData.queryHeight,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/eliblogo.png'),
              colorFilter: ColorFilter.matrix([
                // 희미한 효과를 주는 컬러 매트릭스
                0.1, 0, 0, 0, 0,
                0, 0.9, 0, 0, 0,
                0, 0, 0.1, 0, 0,
                0, 0, 0, 0.1, 0,
              ]),
            ),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: entries.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                //color: const Color.fromARGB(255, 230, 229, 228),
                child: Center(
                  child: OutlinedCardExample(
                    username: index,
                    entries: entries, // entries 전달
                  ),
                ),
              );
            },
            // separatorBuilder: (BuildContext context, int index) =>
            //     const Divider(),
          ),
        );
      }
    },
  );
}

class OutlinedCardExample extends StatefulWidget {
  final int username;
  final List<familyName> entries; // entries 변수 추가
  const OutlinedCardExample({
    Key? key,
    required this.username,
    required this.entries, // 생성자에 entries 추가
  }) : super(key: key);

  @override
  State<OutlinedCardExample> createState() => _OutlinedCardExampleState();
}

class _OutlinedCardExampleState extends State<OutlinedCardExample> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: SizedBox(
          width: GlobalData.queryWidth,
          // height: GlobalData.queryHeight * 0.1,
          child: InkWell(
            onTap: () async {
              showDetail(context);
            },
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                  child: widget.entries[widget.username].imgUrl == null
                      ? Container(
                          width: 50,
                          height: 50,
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 2, color: Colors.grey),
                            image: DecorationImage(
                                image: NetworkImage(
                                    widget.entries[widget.username].imgUrl!),
                                fit: BoxFit.cover),
                          ),
                        ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.entries[widget.username].nickname == null
                        ? Text(
                            '${widget.entries[widget.username].name}님 ',
                            style: const TextStyle(
                                color: Color.fromRGBO(131, 131, 131, 1),
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          )
                        : Text(
                            '${widget.entries[widget.username].nickname}님 ',
                            style: const TextStyle(
                                color: Color.fromRGBO(131, 131, 131, 1),
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                    Text(
                      '${widget.entries[widget.username].phone.substring(0, 3)}-${widget.entries[widget.username].phone.substring(3, 7)}-${widget.entries[widget.username].phone.substring(7, 11)}',
                      style: const TextStyle(
                          color: Color.fromRGBO(131, 131, 131, 1),
                          fontSize: 14),
                    ),
                  ],
                ),
                const Spacer(), // Adds flexible space
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> showDetail(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            dialogBackgroundColor:
                Colors.white, // Override dialog background color
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white, // 배경색 지정
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                Column(
                  children: [
                    widget.entries[widget.username].imgUrl == null
                        ? Container(
                            width: 60,
                            height: 60,
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(width: 2, color: Colors.grey),
                              image: DecorationImage(
                                  image: NetworkImage(
                                      widget.entries[widget.username].imgUrl!),
                                  fit: BoxFit.cover),
                            ),
                          ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: widget.entries[widget.username].nickname == null
                          ? Text(
                              '${widget.entries[widget.username].name}님 ',
                              style: const TextStyle(
                                  color: Color.fromRGBO(131, 131, 131, 1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24),
                            )
                          : Text(
                              '${widget.entries[widget.username].nickname}님 ',
                              style: const TextStyle(
                                  color: Color.fromRGBO(131, 131, 131, 1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24),
                            ),
                    )
                  ],
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height * 0.33,
              child: Column(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      _navigateToMemberInfoPage(
                          context,
                          0,
                          widget.entries[widget.username].id,
                          widget.entries[widget.username].phone);
                    },
                    child: const ListTile(
                      //leading. 타일 앞에 표시되는 위젯. 참고로 타일 뒤에는 trailing 위젯으로 사용 가능
                      leading: Icon(Icons.construction),
                      title: Text(
                        '재난도구 보유 현황',
                        style: TextStyle(
                            color: Color.fromRGBO(131, 131, 131, 1),
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _navigateToMemberInfoPage(
                          context,
                          1,
                          widget.entries[widget.username].id,
                          widget.entries[widget.username].phone);
                    },
                    child: const ListTile(
                      leading: Icon(
                        Icons.edit_document,
                      ),
                      title: Text(
                        '재난훈련 이수 현황',
                        style: TextStyle(
                            color: Color.fromRGBO(131, 131, 131, 1),
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _navigateToMemberInfoPage(
                          context,
                          2,
                          widget.entries[widget.username].id,
                          widget.entries[widget.username].phone);
                    },
                    child: const ListTile(
                      leading: Icon(Icons.place_outlined),
                      title: Text(
                        '최근 위치 정보',
                        style: TextStyle(
                            color: Color.fromRGBO(131, 131, 131, 1),
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _navigateToMemberInfoPage(
                          context,
                          3,
                          widget.entries[widget.username].id,
                          widget.entries[widget.username].phone);
                    },
                    child: const ListTile(
                      leading: Icon(Icons.phone),
                      title: Text(
                        '긴급연락',
                        style: TextStyle(
                            color: Color.fromRGBO(131, 131, 131, 1),
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.entries[widget.username].nickname == null
                          ? _navigateToEditFamilyNamePage(
                              context,
                              widget.entries[widget.username].name,
                              widget.entries[widget.username].id)
                          : _navigateToEditFamilyNamePage(
                              context,
                              widget.entries[widget.username].nickname!,
                              widget.entries[widget.username].id);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 0.0,
                    ),
                    child: const Text('구성원 이름 변경'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showdialog(context, widget.entries[widget.username].id);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromRGBO(255, 92, 92, 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 0.0,
                    ),
                    child: const Text('구성원 삭제'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<List<familyName>> loadFamilyInfo() async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/family');

  if (response.statusCode == 200) {
    List<dynamic> data = response.data;
    List<familyName> list =
        data.map((dynamic e) => familyName.fromJson(e)).toList();
    return list;
    // print(list?[i].name);
  } else {
    throw Exception('fail');
  }
}

Future<void> deleteMember(int id) async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.delete('/api/v1/family/$id');

  if (response.statusCode == 200) {
  } else {
    throw Exception('fail');
  }
}

class familyName {
  final String name;
  final int id;
  final String phone;
  final String? imgUrl;
  final String? nickname;
  familyName(
      {required this.name,
      required this.id,
      required this.phone,
      required this.imgUrl,
      required this.nickname});

  factory familyName.fromJson(Map<String, dynamic> json) {
    return familyName(
        name: json['name'],
        id: json['id'],
        phone: json['phone'],
        imgUrl: json['image'],
        nickname: json['nickname']);
  }
}

void _navigateToInvitePage(BuildContext context) {
  // TODO: 더보기 페이지로 화면 전환
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MemberInvitePage(),
    ),
  );
}

void _navigateToAlarmPage(BuildContext context) {
  // TODO: 더보기 페이지로 화면 전환
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AlarmPage(),
    ),
  );
}

void _navigateToMemberInfoPage(
    BuildContext context, int pageNum, int id, String phone) {
  // TODO: 더보기 페이지로 화면 전환
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          MemberInfoPage(pageNum: pageNum, userId: id, phone: phone),
    ),
  );
}

Future<dynamic> _showdialog(BuildContext context, int id) {
  return showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "구성원을 삭제 하시겠습니까?",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async {
                await deleteMember(id);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => BulidBottomAppBar(
                              index: 3,
                            )),
                    (route) => false);
              },
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      });
}

Future<String> creatInviteCode() async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/family/code');

  if (response.statusCode == 200) {
    return response.data;
  } else {
    throw Exception('fail');
  }
}

void _navigateToEnterCodePage(BuildContext context) {
  // TODO: 더보기 페이지로 화면 전환
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => EnterCodePage()),
  );
}

void _navigateToEditFamilyNamePage(
    BuildContext context, String currentname, int familyid) {
  // TODO: 더보기 페이지로 화면 전환
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          EditFamilyNamePage(currentname: currentname, familyid: familyid),
    ),
  );
}

class VerticalTabBarLayout extends StatefulWidget {
  @override
  _VerticalTabBarLayoutState createState() => _VerticalTabBarLayoutState();
}

class _VerticalTabBarLayoutState extends State<VerticalTabBarLayout>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<String> tabNames = ['모든 구성원'];
  int _selectedIndex = 0; // Track the selected index

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabNames.length, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    setState(() {
      _selectedIndex = _tabController.index;
    });
  }

  void addTab() {
    setState(() {
      int newTabIndex = tabNames.length + 1;
      tabNames.add('Tab $newTabIndex');
      _tabController = TabController(length: tabNames.length, vsync: this);
      _selectedIndex = tabNames.length - 1; // Update the selected index
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: ListView(
            // Wrap with ListView to make the tab area scrollable
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int index = 0; index < tabNames.length; index++)
                    ListTile(
                      title: Text(
                        tabNames[index],
                        style: TextStyle(
                          color: _selectedIndex == index
                              ? Colors.blue
                              : Colors.black,
                          fontWeight: _selectedIndex == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        _tabController.animateTo(index);
                        setState(() {
                          _selectedIndex = index; // Update the selected index
                        });
                      },
                    ),
                  ElevatedButton(
                    onPressed: () {
                      _navigateToAddGroupPage(context);
                      // addTab();
                    },
                    child: Text('그룹 추가'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ListBuild(context)
              // for (String tabName in tabNames)
              //   Center(child: Text('$tabName Content')),
            ],
          ),
        ),
      ],
    );
  }
}

void _navigateToAddGroupPage(BuildContext context) {
  // TODO: 더보기 페이지로 화면 전환
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GroupAddPage(),
      )).then((value) {});
}
