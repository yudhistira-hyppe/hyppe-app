import 'package:flutter/material.dart';

import '../../../../../../constant/widget/custom_spacer.dart';
import 'form_comment.dart';
import 'list_comment.dart';

class ViewerComment extends StatelessWidget {
  final FocusNode? commentFocusNode;
  const ViewerComment({super.key, this.commentFocusNode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ListCommentViewer(commentFocusNode: commentFocusNode),
          twentyEightPx,
          FormCommentViewer(commentFocusNode: commentFocusNode),
        ],
      ),
    );
  }
}
