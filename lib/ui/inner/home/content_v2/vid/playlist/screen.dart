import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/comment_v2/on_show_comment_v2.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/player/player_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/widget/vid_detail_top.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/widget/vid_detail_bottom.dart';

class VidDetailScreen extends StatefulWidget {
  final VidDetailScreenArgument arguments;

  const VidDetailScreen({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  _VidDetailScreenState createState() => _VidDetailScreenState();
}

class _VidDetailScreenState extends State<VidDetailScreen> with AfterFirstLayoutMixin {
  final _notifier = VidDetailNotifier();

  Orientation? orientation = Orientation.portrait;

  @override
  void afterFirstLayout(BuildContext context) {
    _notifier.initState(context, widget.arguments);
    if (widget.arguments.vidData?.certified ?? false) {
      System().block(context);
    } else {
      System().disposeBlock();
    }
  }

  @override
  void dispose() {
    System().disposeBlock();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }

  void changeOrientation(Orientation value) {
    setState(() {
      orientation = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    var width = MediaQuery.of(context).size.width;
    var height;
    if (orientation == Orientation.portrait) {
      height = width * 9.0 / 16.0;
    } else {
      height = MediaQuery.of(context).size.height;
    }
    return ChangeNotifierProvider<VidDetailNotifier>(
      create: (context) => _notifier,
      child: Consumer<VidDetailNotifier>(
        builder: (_, notifier, __) {
          var map = {
            DataSourceRelated.vidKey: widget.arguments.vidData?.apsaraId,
            DataSourceRelated.regionKey: DataSourceRelated.defaultRegion,
          };
          return WillPopScope(
            onWillPop: notifier.onPop,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (orientation == Orientation.portrait) VidDetailTop(data: notifier.data),

                    Container(
                      color: Colors.black,
                      child: PlayerPage(
                        playMode: (widget.arguments.vidData?.isApsara ?? false) ? ModeTypeAliPLayer.auth : ModeTypeAliPLayer.url,
                        dataSourceMap: map,
                        data: widget.arguments.vidData,
                        height: height,
                        width: width,
                      ),
                    ),
                    Offstage(
                      offstage: orientation == Orientation.landscape,
                      child: VidDetailBottom(data: notifier.data),
                    ),
                    // if (orientation == Orientation.portrait)
                    _notifier.data != null && (_notifier.data?.allowComments ?? false)
                        ? Expanded(
                            child: Offstage(
                            offstage: orientation == Orientation.landscape,
                            child: OnShowCommentBottomSheetV2(
                              fromFront: true,
                              postID: _notifier.data?.postID,
                            ),
                          ))
                        : const SizedBox.shrink()
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
