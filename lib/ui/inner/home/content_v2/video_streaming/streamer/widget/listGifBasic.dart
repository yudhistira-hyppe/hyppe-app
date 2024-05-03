import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:nb_utils/nb_utils.dart' as util;
import 'package:provider/provider.dart';

class ListGift extends StatefulWidget {
  const ListGift({super.key});

  @override
  State<ListGift> createState() => _ListGiftState();
}

class _ListGiftState extends State<ListGift> {
  int currentAnimationIndex = 0;
  Timer? _timer;
  Timer? _time2;
  bool show = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _time2?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) {
        return Column(children: <Widget>[for (var item in notifier.giftBasic) gift()]);
      },
    );
  }

  Widget gift() {
    return util.AnimatedScrollView(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 4),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xff000000).withOpacity(0.5), const Color(0xffffffff).withOpacity(0.1)],
                stops: const [0.25, 0.75],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(40)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {},
                child: CustomProfileImage(
                  cacheKey: '',
                  following: true,
                  forStory: false,
                  width: 40 * SizeConfig.scaleDiagonal,
                  height: 40 * SizeConfig.scaleDiagonal,
                  imageUrl: System().showUserPicture(
                    '',
                  ),
                  // badge: notifier.user.profile?.urluserBadge,
                  allwaysUseBadgePadding: false,
                ),
              ),
              twelvePx,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'nataliajessica',
                    style: TextStyle(fontSize: 16 * SizeConfig.scaleDiagonal, color: Color(0xffcecece), fontWeight: FontWeight.w700),
                  ),
                  const Text(
                    'Mengirim Lemper',
                    style: const TextStyle(color: kHyppeTextPrimary),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 16),
                width: 35 * SizeConfig.scaleDiagonal,
                height: 35 * SizeConfig.scaleDiagonal,
                decoration: const BoxDecoration(image: DecorationImage(image: NetworkImage('https://ahmadtaslimfuadi07.github.io/jsonlottie/image228.png'))),
              )
            ],
          ),
        ),
      ],
    );
  }
}
