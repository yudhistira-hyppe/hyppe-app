import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AdsArgument {
  final AdsData data;
  final String adsUrl;
  final bool isSponsored;
  final Function()? afterReport;

  final Function(VisibilityInfo)? onVisibility;
  final FlutterAliplayer? player;
  final Function(FlutterAliplayer, String)? getPlayer;

  const AdsArgument({required this.data, required this.adsUrl, required this.isSponsored, this.afterReport, this.onVisibility, this.player, this.getPlayer});
}
