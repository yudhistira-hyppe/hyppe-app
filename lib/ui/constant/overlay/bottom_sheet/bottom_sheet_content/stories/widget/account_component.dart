import 'package:hyppe/core/constants/thumb/profile_image.dart';
import 'package:hyppe/core/models/collection/stories/viewer_stories_data.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:flutter/material.dart';

class AccountComponent extends StatelessWidget {
  final StoryViewsData data;

  const AccountComponent({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomProfileImage(
      width: 40,
      height: 40,
      onTap: null,
      onFollow: null,
      following: true,
      imageUrl: '${data.profilePicture}$SMALL',
    );
  }
}
