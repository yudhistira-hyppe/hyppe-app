import 'package:hyppe/core/services/event_service.dart';

import 'package:hyppe/core/models/collection/utils/reaction/like_interactive.dart';
import 'package:hyppe/core/models/collection/utils/reaction/reaction_interactive.dart';

class InteractiveEventHandler implements EventHandler {
  void onReactionContent(ReactionInteractive respons) {}

  void onLikeContent(LikeInteractive respons) {}
}
