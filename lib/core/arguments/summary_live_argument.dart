import 'package:hyppe/core/models/collection/live_stream/live_summary_model.dart';

class SummaryLiveArgument {
  Duration duration;
  LiveSummaryModel data;
  bool? blockLive;
  SummaryLiveArgument({required this.duration, required this.data, this.blockLive = false});
}