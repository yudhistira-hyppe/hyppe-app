import 'package:flutter/material.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';

import 'package:hyppe/ui/view/follower/widget/user_item.dart';

import 'package:hyppe/ui/constant/widget/custom_loading.dart';

import 'package:hyppe/ui/view/follower/follower_notifier.dart';

class UserFollowersList extends StatefulWidget {
  const UserFollowersList({Key? key}) : super(key: key);

  @override
  State<UserFollowersList> createState() => _UserFollowersListState();
}

class _UserFollowersListState extends State<UserFollowersList> {
  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<FollowerNotifier>();

    return _buildView(notifier);
  }

  Widget _buildView(FollowerNotifier notifier) {
    return RefreshIndicator(
      onRefresh: () async {
        await notifier.requestFollowers(context, reload: true);
      },
      child: ListView.builder(
        itemCount: notifier.followersItemCount,
        controller: notifier.listFollowersController,
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemBuilder: (context, index) {
          if (notifier.followersData == null) {
            return CustomShimmer(
              radius: 8,
              height: 168,
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              margin: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 4.5),
            );
          } else if (index == notifier.followersData?.length && notifier.followersHasNext) {
            return const CustomLoading();
          }

          return UserItem(
            data: notifier.followersData?[index],
            onTap: () => System().navigateToProfile(context, notifier.followersData?[index].senderOrReceiverInfo?.email ?? '', isReplaced: false),
          );
        },
      ),
    );
  }
}
