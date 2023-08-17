import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:elib_project/auth_dio.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';


double appBarHeight = 40;
double mediaHeight(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.height - appBarHeight) * scale;
double mediaWidth(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.width) * scale;

class trainRegistpage extends StatefulWidget {
  trainRegistpage({
    Key? key,
    this.train,
  }) : super(key: key);
  dynamic train;

  @override
  State<trainRegistpage> createState() => _trainRegistPageState();
}

class _trainRegistPageState extends State<trainRegistpage>
    with TickerProviderStateMixin {
  late TabController trainController;

  @override
  void initState() {
    super.initState();
    trainController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    trainController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dynamic train = widget.train;

    String? name = train.name;

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
                        '훈련 관리',
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
                        TabBar(
                          controller: trainController,
                          indicatorColor: Colors.green,
                          indicatorWeight: 3,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          tabs: const [
                            Tab(
                              child: Text(
                                '자료',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                '영상',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                            child: Container(
                                width: mediaWidth(context, 1),
                                child: TabBarView(
                                  controller: trainController,
                                  children: [
                                    ImageBox(
                                      train: train,
                                    ),
                                    VideoBox(
                                      train: train,
                                    ),
                                  ],
                                ))),
                      ],
                    )))));
  }
}

List loadTrainImage(imgurl) {
  String baseUrl =
      "http://test.elibtest.r-e.kr:8080/api/v1/media/train/img?name=";

  List imageList = [];
  for (var img in imgurl) {
    imageList.add(baseUrl + img);
  }

  print(imageList);

  return imageList;
}

class ImageBox extends StatefulWidget {
  ImageBox({
    Key? key,
    this.train,
  }) : super(key: key);

  dynamic train;

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
    imageList = loadTrainImage(widget.train.imgUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        Container(
          width: mediaWidth(context, 1),
          height: mediaWidth(context, 1),
          child: imageSlide(),
        ),
        SizedBox(height: 5),
        imageIndicator(),

        Text(
          '$_current',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    ));
  }

  onchanged(int index) {
    setState(() {
      _current = index + 1;

      if(_current == imageList!.length) {
        print("----------");
      }
    });
  }

  Widget imageSlide() {
    return PageView.builder(
      onPageChanged: onchanged,
      scrollDirection: Axis.horizontal,
      controller: controller,
      itemCount: imageList!.length,
      itemBuilder: (context, index) {
        return Container(
            width: mediaWidth(context, 1),
            height: mediaWidth(context, 1),
            child: Image(
              fit: BoxFit.fill,
              image: NetworkImage(
                imageList![index],
              ),
            ));
      },
    );
  }

  Widget imageIndicator() {
    return SmoothPageIndicator(
        controller: controller, // PageController
        count: imageList!.length,
        effect: SwapEffect(
            activeDotColor: Colors.green,
            dotColor: Colors.grey.shade400,
            radius: 10,
            dotHeight: 10,
            dotWidth: 10,
        ), // your preferred effect
        onDotClicked: (index) {});
  }
}

List loadTrainVideo(videourl) {
  String baseUrl =
      "http://test.elibtest.r-e.kr:8080/api/v1/media/train/video?name=";

  List videoList = [];
  for (var video in videourl) {
    videoList.add(baseUrl + video);
  }

  print(videoList);

  return videoList;
}


//Video 리스트뷰
class VideoBox extends StatefulWidget {
  VideoBox({
    Key? key,
    this.train,
  }) : super(key: key);

  dynamic train;

  @override
  State<VideoBox> createState() => _VideoBoxState();
}

class _VideoBoxState extends State<VideoBox> {
  //late List? videoList;
  List? videoList = ['http://test.elibtest.r-e.kr:8080/api/v1/media/tool/video?name=mask_main.mp4'];
  
  @override
  void initState() {
    super.initState();
    //init();
  }

  void init() async {
    videoList = loadTrainVideo(widget.train.videoUrl);
  }

  @override
  Widget build(BuildContext context) {
    //dynamic train = widget.train;

    return Center(
        child: Column(
        children: [
          Container(
            width: mediaWidth(context, 1),
            height: mediaHeight(context, 0.3),
            child: ListView.builder(
            itemCount: videoList?.length,
            itemBuilder: (_, index) {
              return VideoPage(videoUrl: videoList?[index]);
            }),
          ),

        ],
    ));
  }
}


//videoPage 띄우는
class VideoPage extends StatefulWidget {
  final String videoUrl;

  VideoPage({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _controller;
  late Future<void> _initailizedController;

  Future initializeVideo() async {
    Uri videoUri = Uri.parse(widget.videoUrl);
    _controller = VideoPlayerController.networkUrl(videoUri);
    _initailizedController = _controller.initialize();

    setState(() { });
  }

  @override
  void initState() {
    initializeVideo();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initailizedController,
      builder: (_, snapshot) {
        return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  });
                },
                child: VideoPlayer(_controller)));
      },
    );
  }
}

// //videoPage 띄우는
// class VideoPage extends StatefulWidget {
//   final String videoUrl;

//   VideoPage({Key? key, required this.videoUrl}) : super(key: key);

//   @override
//   State<VideoPage> createState() => _VideoPageState();
// }

// class _VideoPageState extends State<VideoPage> {
//   late VideoPlayerController videoPlayerController;
//   ChewieController? chewieController;

//   late VideoPlayerController _controller;
//   late Future<void> _initailizedController;

//   Future initializeVideo() async {
//     Uri videoUri = Uri.parse(widget.videoUrl);
//     videoPlayerController = VideoPlayerController.networkUrl(videoUri);
//     await videoPlayerController.initialize();

//     chewieController = ChewieController(
//       videoPlayerController: videoPlayerController,
//       autoPlay: false,
//       looping: false,
//     );

//     setState(() { });
//   }

//   @override
//   void initState() {
//     initializeVideo();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     videoPlayerController.dispose();
//     chewieController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (chewieController == null) {
//       return Container(
//         child: CircularProgressIndicator(),
//       );
//     }

//     else return Container(
//       child: Chewie(
//         controller: chewieController!,
//       ),
//     );
//   }
// }

