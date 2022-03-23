import 'package:better_player/better_player.dart';
import 'package:story_view/services/stream_service.dart';
import 'package:story_view/handlers/video_event_handler.dart';
import 'package:story_view/arguments/result_video_player_argument.dart';

abstract class EventHandler {}

class EventService {
  EventService._internal();

  static final EventService _singleton = EventService._internal();

  factory EventService() {
    return _singleton;
  }

  Map<String, VideoEventHandler> _videoHandlers = {};

  StreamService get streamService => StreamService();

  void addVideoHandler(String identifier, VideoEventHandler handler) {
    if (getVideoEventHandler(identifier) == null) {
      _videoHandlers[identifier] = handler;
    }
  }

  void removeVideoHandler(String identifier) {
    _videoHandlers.remove(identifier);
  }

  VideoEventHandler? getVideoEventHandler(String identifier) {
    return _videoHandlers[identifier];
  }

  void cleanUp() {
    _videoHandlers = {};
  }

  void notifyInitVideoProgress(ResultVideoPlayerArgument argument) {
    streamService.initVideo.add(argument);

    for (var element in _videoHandlers.values) {
      element.onDoneInitNextVideo(argument);
    }
  }

  void notifyBetterPlayerEvent(BetterPlayerEvent event) {
    streamService.betterPlayerEvent.add(event);

    for (var element in _videoHandlers.values) {
      element.onBetterPlayerEventChange(event);
    }
  }
}
