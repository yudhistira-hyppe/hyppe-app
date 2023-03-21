import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/services/system.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';

import 'package:hyppe/core/extension/custom_extension.dart';

import 'package:hyppe/core/models/collection/follow/interactive_follow.dart';

class UserItem extends StatefulWidget {
  final Function() onTap;
  final InteractiveFollow? data;
  const UserItem({
    Key? key,
    required this.data,
    required this.onTap,
  }) : super(key: key);

  @override
  State<UserItem> createState() => _UserItemState();
}

class _UserItemState extends State<UserItem> {

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'UserItem');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 16,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // profile picture
            CustomProfileImage(
              width: 50,
              height: 50,
              following: true,
              imageUrl: System().showUserPicture(widget.data?.senderOrReceiverInfo?.avatar?.mediaEndpoint),
              onTap: () => System().navigateToProfile(context, widget.data?.senderOrReceiverInfo?.email ?? ''),
            ),
            sixteenPx,
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // title and subtitle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextWidget(
                        textToDisplay: widget.data?.senderOrReceiverInfo?.username ?? '',
                        textStyle: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      fourPx,
                      CustomTextWidget(
                        maxLines: 1,
                        textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold),
                        textToDisplay: widget.data?.senderOrReceiverInfo?.fullname ?? widget.data?.senderOrReceiverInfo?.username.camelCase ?? '',
                      )
                    ],
                  ),

                  // button
                  // ButtonWidget(
                  //   data: widget.data,
                  // ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
