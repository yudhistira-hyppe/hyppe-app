import 'package:hyppe/core/models/collection/utils/reaction/reaction_interactive.dart';

class Reaction {
  List<ReactionInteractive> data = [];

  Reaction({this.data = const []});

  Reaction.fromJson(dynamic json) {
    data = (json as List<dynamic>?)?.map((e) => ReactionInteractive.fromJson(e as Map<String, dynamic>)).toList() ?? [];
  }
}
