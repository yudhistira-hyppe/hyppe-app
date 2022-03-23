import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:story_view/arguments/result_video_player_argument.dart';

class StreamService {
  late StreamController<ResultVideoPlayerArgument> _videoController;
  late StreamController<BetterPlayerEvent> _betterPlayerEventController;

  StreamService() {
    _videoController = StreamController<ResultVideoPlayerArgument>.broadcast();
    _betterPlayerEventController = StreamController<BetterPlayerEvent>.broadcast();
  }

  StreamController<ResultVideoPlayerArgument> get initVideo => _videoController;
  StreamController<BetterPlayerEvent> get betterPlayerEvent => _betterPlayerEventController;

  void reset() {
    _videoController.close();
    _betterPlayerEventController.close();

    _videoController = StreamController<ResultVideoPlayerArgument>.broadcast();
    _betterPlayerEventController = StreamController<BetterPlayerEvent>.broadcast();
  }
}
