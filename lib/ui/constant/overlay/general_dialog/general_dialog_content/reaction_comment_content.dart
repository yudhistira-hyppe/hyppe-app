import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/collection/comment/comments.dart';
import 'package:hyppe/core/models/collection/utils/reaction/reaction.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/widget/show_reactions_icon.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReactionCommentContent extends StatelessWidget {
  final Comments comment;
  const ReactionCommentContent({Key? key, required this.comment});

  @override
  Widget build(BuildContext context) {
    Reaction? reaction = Provider.of<MainNotifier>(context, listen: false).reactionData;
    return Consumer<LikeNotifier>(
      builder: (_, notifier, __) => ShowReactionsIcon(
        onTap: () => Routing().moveBack(),
        data: reaction!.data,
        crossAxisCount: 3,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              comment.isReacted = true;
              comment.count = comment.count! + 1;
              notifier.onLikeComment(context, comment: comment, rData: reaction.data[index]);
              Routing().moveBack();
            },
            child: Material(
              color: Colors.transparent,
              child: Text(
                reaction.data[index].icon!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 35 * SizeConfig.scaleDiagonal),
              ),
            ),
          );
        },
      ),
    );
  }
}
