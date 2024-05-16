import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/live_stream/comment_live_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/notifier.dart';
import 'package:provider/provider.dart';

class ListGiftViewer extends StatefulWidget {
  const ListGiftViewer({super.key});

  @override
  State<ListGiftViewer> createState() => _ListGiftViewerState();
}

class _ListGiftViewerState extends State<ListGiftViewer> {
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
    return Consumer<ViewStreamingNotifier>(
      builder: (_, notifier, __) {
        return Column(verticalDirection: VerticalDirection.down, children: <Widget>[for (var item in notifier.giftBasic) gift(item)]);
      },
    );
  }

  Widget gift(CommentLiveModel data) {
    final mimeType = System().extensionFiles(data.urlGiftThum ?? '')?.split('/')[0] ?? '';
    String type = '';
    if (mimeType != '') {
      var a = mimeType.split('/');
      type = a[0];
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
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
            CustomProfileImage(
              cacheKey: '',
              following: true,
              forStory: false,
              width: 40 * SizeConfig.scaleDiagonal,
              height: 40 * SizeConfig.scaleDiagonal,
              imageUrl: System().showUserPicture(
                data.avatar?.mediaEndpoint ?? '',
              ),
              // badge: notifier.user.profile?.urluserBadge,
              allwaysUseBadgePadding: false,
            ),
            twelvePx,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.username ?? '',
                  style: TextStyle(fontSize: 16 * SizeConfig.scaleDiagonal, color: Color(0xffcecece), fontWeight: FontWeight.w700),
                ),
                Text(
                  'Mengirim ${data.messages}',
                  style: const TextStyle(color: kHyppeTextPrimary),
                ),
              ],
            ),
            type == '.svg'
                ? SvgPicture.network(
                    data.urlGiftThum ?? '',
                    height: 35 * SizeConfig.scaleDiagonal,
                    width: 35 * SizeConfig.scaleDiagonal,
                    semanticsLabel: 'A shark?!',
                    placeholderBuilder: (BuildContext context) => Container(padding: const EdgeInsets.all(30.0), child: const CircularProgressIndicator()),
                  )
                : Container(
                    margin: const EdgeInsets.only(left: 16),
                    width: 35 * SizeConfig.scaleDiagonal,
                    height: 35 * SizeConfig.scaleDiagonal,
                    decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(data.urlGiftThum ?? ''))),
                  )
          ],
        ),
      ),
    );
  }
}
