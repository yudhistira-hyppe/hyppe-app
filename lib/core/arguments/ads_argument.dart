import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';

class AdsArgument {
  final AdsData data;
  final String adsUrl;
  final bool isSponsored;
  final Function()? afterReport;

  const AdsArgument({required this.data, required this.adsUrl, required this.isSponsored, this.afterReport});
}
