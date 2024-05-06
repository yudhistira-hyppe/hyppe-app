import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/live_stream/link_stream_model.dart';

import '../../../../../../constant/widget/custom_spacer.dart';
import 'form_comment.dart';
import 'list_comment.dart';

class ViewerComment extends StatelessWidget {
  final FocusNode? commentFocusNode;
  final LinkStreamModel? data;
  const ViewerComment({super.key, this.commentFocusNode, this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ListCommentViewer(commentFocusNode: commentFocusNode, data: data),
          twentyEightPx,
          FormCommentViewer(commentFocusNode: commentFocusNode, data: data,),
        ],
      ),
    );
  }
}
