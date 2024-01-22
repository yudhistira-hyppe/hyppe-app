import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/vid_fullscreen_argument.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/content_violation.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/scroll/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/vid_player_page.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:provider/provider.dart';

class VidScrollFullScreenPage extends StatefulWidget {
  final VidFullscreenArgument? argument;
  const VidScrollFullScreenPage({super.key, required this.argument});

  @override
  State<VidScrollFullScreenPage> createState() => _VidScrollFullScreenPageState();
}

class _VidScrollFullScreenPageState extends State<VidScrollFullScreenPage> {
  PageController controller = PageController();
  List<ContentData>? vidData;
  ContentData? data;
  int index = 0;
  bool isPause = false;

  @override
  void didChangeDependencies() async {
    vidData = widget.argument?.vidData;
    index = widget.argument!.index;
    data = widget.argument?.data;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    controller = PageController(initialPage: widget.argument?.index ?? 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TranslateNotifierV2 lang = context.read<TranslateNotifierV2>();
    var map = {
      DataSourceRelated.vidKey: data!.apsaraId,
      DataSourceRelated.regionKey: DataSourceRelated.defaultRegion,
    };
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer3<ScrollVidNotifier, TranslateNotifierV2, HomeNotifier>(
        builder: (_, vidNotifier, translateNotifier, homeNotifier, __) {
          return Stack(
            children: [
              PageView.builder(
                controller: controller,
                scrollDirection: Axis.vertical,
                itemCount: vidNotifier.vidData?.length ?? 0,
                onPageChanged: (value) async {
                  widget.argument!.index = value;
                  if ((vidNotifier.vidData?.length ?? 0) - 1 == widget.argument?.index) {
                    // final pageSrc =
                    //     widget.argument?.pageSrc ?? PageSrc.otherProfile;
                    // //This loadmore data
                    // await notifier.loadMore(context, controller, pageSrc,
                    //     widget.argument?.key ?? '');
                    // if (mounted) {
                    //   setState(() {
                    //     picData = notifier.pics;
                    //   });
                    // } else {
                    //   picData = notifier.pics;
                    // }
                  }
                },
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Positioned.fill(child: itemVid(map, vidNotifier.vidData![index]),),
                      vidNotifier.vidData![index].email == SharedPreference().readStorage(SpKeys.email) && (vidNotifier.vidData![index].reportedStatus == 'OWNED' || vidNotifier.vidData![index].reportedStatus == 'OWNED')
                      ? Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ContentViolationWidget(
                              radius: 0.0,
                              data: vidData?[index] ?? ContentData(),
                              text: lang.translate.thisHyppeVidisSubjectToModeration ?? '',
                            ),
                      )
                      : const SizedBox.shrink()
                    ],
                  );
                  
                },
              )
            ],
          );
        }
      ),
    );
  }

  Widget itemVid(Map<String, String?> map, ContentData vidData){
    return OrientationBuilder(
      builder: (context, orientation) {
      final player = VidPlayerPage(
        fromFullScreen: true,
        orientation: orientation,
        playMode:
            (vidData.isApsara ?? false)
                ? ModeTypeAliPLayer.auth
                : ModeTypeAliPLayer.url,
        dataSourceMap: map,
        data: vidData,
        height:
            MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        inLanding: false,
        fromDeeplink: false,
        clearing: true,
        isAutoPlay: true,
        functionFullTriger: (value) {
          print(
              '===========hahhahahahaa===========');
        },
        isPlaying: !isPause,
        onPlay: (exec) {},
        getPlayer: (main, id) {},
        getAdsPlayer: (ads) {},
        autoScroll: () {
          // nextPage();
        },
      );
      if (orientation == Orientation.landscape) {
        return SizedBox(
          width: context.getWidth(),
          height: context.getHeight(),
          child: player,
        );
      }
      return player;
    });
  }
}