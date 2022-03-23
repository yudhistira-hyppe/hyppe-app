import 'package:better_player/better_player.dart';

class ResultVideoPlayerArgument {
  final String videoUrl;
  final BetterPlayerController playerController;

  ResultVideoPlayerArgument({
    required this.videoUrl,
    required this.playerController,
  });
}
