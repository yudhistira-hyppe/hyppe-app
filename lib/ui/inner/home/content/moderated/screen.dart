import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content/moderated/widget/content_detail.dart';
import 'package:hyppe/ui/inner/home/content/moderated/widget/information_detail.dart';
import 'package:flutter/material.dart';

class ModeratedContent extends StatelessWidget {
  final ContentData arguments;
  const ModeratedContent({Key? key, required this.arguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            ContentDetail(data: arguments),
            const InformationDetail(),
          ],
        ),
      ),
    );
  }
}
