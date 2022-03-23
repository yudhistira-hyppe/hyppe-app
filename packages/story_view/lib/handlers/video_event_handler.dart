import 'package:better_player/better_player.dart';
import 'package:story_view/arguments/result_video_player_argument.dart';
import 'package:story_view/services/event_service.dart';

class VideoEventHandler implements EventHandler {
  void onDoneInitNextVideo(ResultVideoPlayerArgument argument) {}
  
  void onBetterPlayerEventChange(BetterPlayerEvent event) {}
}
