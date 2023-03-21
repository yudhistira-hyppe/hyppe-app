import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';

import 'package:hyppe/ui/view/follower/widget/user_item.dart';

import 'package:hyppe/ui/constant/widget/custom_loading.dart';

import 'package:hyppe/ui/view/follower/follower_notifier.dart';

class UserFollowingList extends StatefulWidget {
  const UserFollowingList({Key? key}) : super(key: key);

  @override
  State<UserFollowingList> createState() => _UserFollowingListState();
}

class _UserFollowingListState extends State<UserFollowingList> {

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'UserFollowersList');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<FollowerNotifier>();

    return _buildView(notifier);
  }

  Widget _buildView(FollowerNotifier notifier) {
    return RefreshIndicator(
      onRefresh: () async {
        await notifier.requestFollowing(context, reload: true);
      },
      child: ListView.builder(
        itemCount: notifier.followingItemCount,
        controller: notifier.listFollowingController,
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemBuilder: (context, index) {
          if (notifier.followingData == null) {
            return CustomShimmer(
              radius: 8,
              height: 168,
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              margin: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 4.5),
            );
          } else if (index == notifier.followingData?.length && notifier.followingHasNext) {
            return const CustomLoading();
          }
          return UserItem(
            data: notifier.followingData?[index],
            onTap: () => System().navigateToProfile(context, notifier.followingData?[index].senderOrReceiverInfo?.email ?? ''),
          );
        },
      ),
    );
  }
}
