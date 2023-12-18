import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/feedback/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../ux/routing.dart';
import '../../../../../constant/widget/icon_button_widget.dart';

class ListStreamersScreen extends StatefulWidget {
  const ListStreamersScreen({super.key});

  @override
  State<ListStreamersScreen> createState() => _ListStreamersScreenState();
}

class _ListStreamersScreenState extends State<ListStreamersScreen>  with TickerProviderStateMixin{
  final streamers = const [
    Streamer(
        image:
            'https://images.rawpixel.com/image_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvMjc5LXBhaTE1NzktbmFtLmpwZw.jpg',
        username: 'marcelardianto_',
        name: 'Marcel',
        streamDesc: 'Office Vlog',
        watchersCount: 10400,
        isFollowing: false),
    Streamer(
        image:
            'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?cs=srgb&dl=pexels-pixabay-415829.jpg&fm=jpg',
        username: 'angela_gunawan',
        name: 'Guns',
        streamDesc: 'Yuk join live aku!',
        watchersCount: 10400,
        isFollowing: true),
    Streamer(
        image:
            'https://www.shutterstock.com/image-photo/portrait-young-beautiful-woman-perfect-600nw-2228044151.jpg',
        username: 'stephanie.wijaya',
        name: 'stephanis',
        streamDesc: 'Lagi gabut aja',
        watchersCount: 10400,
        isFollowing: false),
    Streamer(
        image:
            'https://i.pinimg.com/736x/ec/35/7b/ec357b956cbb9da835c2feefe74e56fb.jpg',
        username: 'deni.riwanto',
        streamDesc: 'Nge-vlog di kantor #2',
        name: 'Deni',
        watchersCount: 10400,
        isFollowing: true),
    Streamer(
        image:
            'https://images.rawpixel.com/image_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvMjc5LXBhaTE1NzktbmFtLmpwZw.jpg',
        username: 'marcelardianto_',
        name: 'Marcel',
        streamDesc: 'Hello World!',
        watchersCount: 10400,
        isFollowing: false),
    Streamer(
        image:
            'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?cs=srgb&dl=pexels-pixabay-415829.jpg&fm=jpg',
        username: 'angela_gunawan',
        name: 'Guns',
        streamDesc: 'Tutorial Makeup edition 2',
        watchersCount: 10400,
        isFollowing: true),
    Streamer(
        image:
            'https://www.shutterstock.com/image-photo/portrait-young-beautiful-woman-perfect-600nw-2228044151.jpg',
        username: 'stephanie.wijaya',
        streamDesc: 'Lagi gabut aja',
        watchersCount: 10400,
        name: 'stephanis',
        isFollowing: false),
    Streamer(
        image:
            'https://i.pinimg.com/736x/ec/35/7b/ec357b956cbb9da835c2feefe74e56fb.jpg',
        username: 'deni.riwanto',
        streamDesc: 'Hello World!',
        watchersCount: 10400,
        name: 'Deni',
        isFollowing: true),
    Streamer(
        image:
            'https://images.rawpixel.com/image_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvMjc5LXBhaTE1NzktbmFtLmpwZw.jpg',
        username: 'marcelardianto_',
        streamDesc: 'Hello World!',
        watchersCount: 10400,
        name: 'Marcel',
        isFollowing: false),
    Streamer(
        image:
            'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?cs=srgb&dl=pexels-pixabay-415829.jpg&fm=jpg',
        username: 'angela_gunawan',
        streamDesc: 'Lagi gabut aja',
        watchersCount: 10400,
        name: 'Guns',
        isFollowing: true),
    Streamer(
        image:
            'https://www.shutterstock.com/image-photo/portrait-young-beautiful-woman-perfect-600nw-2228044151.jpg',
        username: 'stephanie.wijaya',
        streamDesc: 'Lagi gabut aja',
        watchersCount: 400,
        name: 'stephanis',
        isFollowing: false),
    Streamer(
        image:
            'https://i.pinimg.com/736x/ec/35/7b/ec357b956cbb9da835c2feefe74e56fb.jpg',
        username: 'deni.riwanto',
        streamDesc: 'Hello World!',
        watchersCount: 400,
        name: 'Deni',
        isFollowing: true),
  ];

  late AnimationController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(() {
      if(_controller.isCompleted){
        _controller.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StreamingFeedbackNotifier>(builder: (context, notifier, _) {
      final sizeTile = (context.getWidth() - 12) / 2;
      return Scaffold(
        appBar: AppBar(
          leading: CustomIconButtonWidget(
            onPressed: () {
              Routing().moveBack();
            },
            color: Colors.black,
            iconData: '${AssetPath.vectorPath}back-arrow.svg',
            padding: const EdgeInsets.only(right: 16, left: 16),
          ),
          title: Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: const CustomTextWidget(
                textToDisplay: 'HyppeLive',
                textStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: (){
                    _controller..duration = const Duration(seconds: 2)..forward();

                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: CustomTextWidget(
                    textToDisplay:
                        notifier.language.exploreLiveToLivenUpYourDay ??
                            'Serunya LIVE untuk ramaikan harimu!',
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  strokeWidth: 2.0,
                  color: Colors.purple,
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: SingleChildScrollView(
                    child: Wrap(
                      children: List.generate(streamers.length, (index) {
                        final streamer = streamers[index];
                        // return Lottie.asset(
                        //   "${AssetPath.jsonPath}loveicon.json",
                        //   width: sizeTile,
                        //   height: sizeTile + 150,
                        //   repeat: false,
                        //   controller: _controller
                        // );
                        if (index % 2 == 0) {
                          return Container(
                            width: sizeTile,
                            height: sizeTile,
                            margin: const EdgeInsets.only(
                                left: 2, right: 4, bottom: 4, top: 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                      child: streamerImage(streamer.image ?? '')),
                                  Positioned(
                                    top: 8,
                                    right: 14,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          left: 4, right: 8, top: 2, bottom: 2),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color: Colors.black.withOpacity(0.5)),
                                      child: Row(
                                        children: [
                                          const CustomIconWidget(
                                            iconData:
                                                '${AssetPath.vectorPath}eye.svg',
                                            width: 16,
                                            height: 16,
                                            defaultColor: false,
                                          ),
                                          fourPx,
                                          CustomTextWidget(
                                            textToDisplay: streamer.watchersCount
                                                .getCountShort(),
                                            textStyle: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 10,
                                    bottom: 14,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomTextWidget(
                                          textToDisplay: streamer.streamDesc ?? '',
                                          textStyle: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        twoPx,
                                        CustomTextWidget(
                                          textToDisplay: streamer.username ?? '',
                                          textStyle: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            width: sizeTile,
                            height: sizeTile,
                            margin: const EdgeInsets.only(
                                left: 4, right: 2, bottom: 4, top: 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                      child: streamerImage(streamer.image ?? '')),
                                  Positioned(
                                    top: 8,
                                    right: 14,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          left: 4, right: 8, top: 2, bottom: 2),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color: Colors.black.withOpacity(0.5)),
                                      child: Row(
                                        children: [
                                          const CustomIconWidget(
                                            iconData:
                                                '${AssetPath.vectorPath}eye.svg',
                                            width: 16,
                                            height: 16,
                                            defaultColor: false,
                                          ),
                                          fourPx,
                                          CustomTextWidget(
                                            textToDisplay: streamer.watchersCount
                                                .getCountShort(),
                                            textStyle: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 10,
                                    bottom: 14,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomTextWidget(
                                          textToDisplay: streamer.streamDesc ?? '',
                                          textStyle: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        twoPx,
                                        CustomTextWidget(
                                          textToDisplay: streamer.username ?? '',
                                          textStyle: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget streamerImage(String image) {
    return Stack(
      children: [
        const Align(
          alignment: Alignment.center,
          child: CustomLoading(),
        ),
        Positioned.fill(
            child: Image.network(
          image,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        )),
      ],
    );
  }
}

class Streamer {
  final String? image;
  final String? username;
  final String? name;
  final bool isFollowing;
  final String? streamDesc;
  final int watchersCount;
  const Streamer(
      {this.image,
      this.username,
      this.name,
      this.isFollowing = true,
      this.streamDesc,
      this.watchersCount = 0});
}
