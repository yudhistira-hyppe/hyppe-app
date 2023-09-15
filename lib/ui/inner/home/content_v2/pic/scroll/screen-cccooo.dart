// ignore_for_file: no_logic_in_create_state

import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/arguments/contents/slided_pic_detail_screen_argument.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_newdesc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:hyppe/ui/constant/widget/profile_landingpage.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/content_violation.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/scroll/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/core/models/collection/utils/zoom_pic/zoom_pic.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter/gestures.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';
// import 'package:snappy_list_view/snappy_list_view.dart';

///listView 联动 listView
class ScrollPic extends StatefulWidget {
  final SlidedPicDetailScreenArgument? arguments;

  const ScrollPic({super.key, this.arguments});
  @override
  _ScrollPicState createState() => _ScrollPicState();
}

class _ScrollPicState extends State<ScrollPic> {
  ScrollController _primaryScrollController = ScrollController();
  ScrollController _subScrollController = ScrollController();

  Drag? _primaryDrag;
  Drag? _subDrag;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _primaryScrollController.dispose();
    _subScrollController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _primaryDrag = _primaryScrollController.position.drag(details, _disposePrimaryDrag);
    _subDrag = _subScrollController.position.drag(details, _disposeSubDrag);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    print("hahaha == ${details}");
    _primaryDrag?.update(details);

    ///除以10实现差量效果
    _subDrag?.update(DragUpdateDetails(
        sourceTimeStamp: details.sourceTimeStamp,
        delta: details.delta / 30,
        primaryDelta: (details.primaryDelta ?? 0) / 30,
        globalPosition: details.globalPosition,
        localPosition: details.localPosition));
  }

  void _handleDragEnd(DragEndDetails details) {
    print("_handleDragEnd == ${details}");
    // _primaryDrag?.end(details);

    _primaryScrollController.position.pointerScroll(
      300,
    );
    _primaryScrollController.animateTo(
      300,
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
    );
    _subDrag?.end(details);
  }

  void _handleDragCancel() {
    _primaryDrag?.cancel();
    // _subDrag?.cancel();
  }

  void _disposePrimaryDrag() {
    _primaryDrag = null;
  }

  void _disposeSubDrag() {
    // _subDrag = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("ScrollPic"),
        ),
        body: RawGestureDetector(
          gestures: <Type, GestureRecognizerFactory>{
            VerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer(), (VerticalDragGestureRecognizer instance) {
              instance
                ..onStart = _handleDragStart
                ..onUpdate = _handleDragUpdate
                ..onEnd = _handleDragEnd
                ..onCancel = _handleDragCancel;
            })
          },
          behavior: HitTestBehavior.opaque,
          child: ScrollConfiguration(
            ///去掉 Android 上默认的边缘拖拽效果
            behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
            child: Row(
              children: [
                new Expanded(
                    child: ListView.builder(

                        ///屏蔽默认的滑动响应
                        physics: NeverScrollableScrollPhysics(),
                        controller: _primaryScrollController,
                        itemCount: 55,
                        itemBuilder: (context, index) {
                          return Container(
                              height: 600,
                              color: Colors.greenAccent,
                              child: Center(
                                child: Text(
                                  "Item $index",
                                  style: TextStyle(fontSize: 40, color: Colors.blue),
                                ),
                              ));
                        })),
                new SizedBox(
                  width: 5,
                ),
                new Expanded(
                  child: ListView.builder(

                      ///屏蔽默认的滑动响应
                      physics: NeverScrollableScrollPhysics(),
                      controller: _subScrollController,
                      itemCount: 55,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 300,
                          color: Colors.deepOrange,
                          child: Center(
                            child: Text(
                              "Item $index",
                              style: TextStyle(fontSize: 40, color: Colors.white),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ));
  }
}
// -----------------------------------
// ©著作权归作者所有：来自51CTO博客作者GSYTech的原创作品，请联系作者获取转载授权，否则将追究法律责任
// Flutter 小技巧之 ListView 和 PageView 的各种花式嵌套
// https://blog.51cto.com/u_15641473/5479646

class AllowMultipleScaleRecognizer extends ScaleGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}
