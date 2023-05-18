import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/vid_player_page.dart';

import '../../../../../../core/config/ali_config.dart';
import '../../../../../../core/constants/enum.dart';
import '../../../../../../core/models/collection/posts/content_v2/content_data.dart';

class VideoFullscreenPage extends StatefulWidget {
  final ContentData data;
  final Function onClose;
  final int seekValue;
  const VideoFullscreenPage(
      {Key? key,
      required this.data,
      required this.onClose,
      required this.seekValue})
      : super(key: key);

  @override
  State<VideoFullscreenPage> createState() => _VideoFullscreenPageState();
}

class _VideoFullscreenPageState extends State<VideoFullscreenPage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    var map = {
      DataSourceRelated.vidKey: widget.data.apsaraId,
      DataSourceRelated.regionKey: DataSourceRelated.defaultRegion,
    };
    return Material(
      child: Container(
        width: context.getWidth(),
        height: context.getHeight(),
        decoration: const BoxDecoration(color: Colors.black),
        child: VidPlayerPage(
          playMode: (widget.data.isApsara ?? false)
              ? ModeTypeAliPLayer.auth
              : ModeTypeAliPLayer.url,
          dataSourceMap: map,
          data: widget.data,
          functionFullTriger: widget.onClose,
          inLanding: true,
          orientation: Orientation.landscape,
          seekValue: widget.seekValue,
        ),
      ),
    );
  }
}
