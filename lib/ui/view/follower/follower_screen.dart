import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';

import 'package:hyppe/ui/constant/widget/keyboard_disposal.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import 'package:hyppe/core/arguments/follower_screen_argument.dart';

import 'package:hyppe/ui/view/follower/follower_notifier.dart';
import 'package:hyppe/ui/view/follower/widget/user_followers_list.dart';
import 'package:hyppe/ui/view/follower/widget/user_following_list.dart';

class FollowerScreen extends StatefulWidget {
  final FollowerScreenArgument argument;

  const FollowerScreen({
    Key? key,
    required this.argument,
  }) : super(key: key);

  @override
  State<FollowerScreen> createState() => _FollowerScreenState();
}

class _FollowerScreenState extends State<FollowerScreen> with SingleTickerProviderStateMixin {
  final notifier = FollowerNotifier();

  late TabController _tabController;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'FollowerScreen');
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.argument.eventType == InteractiveEventType.follower ? 0 : 1);
    notifier.initState(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themes = Theme.of(context);
    final _language = context.watch<TranslateNotifierV2>().translate;
    return ChangeNotifierProvider<FollowerNotifier>(
      create: (context) => notifier,
      child: DefaultTabController(
        length: 2,
        child: KeyboardDisposal(
          child: Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              leading: const BackButton(),
              title: CustomTextWidget(
                textAlign: TextAlign.left,
                textStyle: themes.textTheme.bodyText1,
                textToDisplay: widget.argument.username ?? '',
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: _language.followers ?? ''),
                  Tab(text: _language.following ?? ''),
                ],
                onTap: (value) {
                  if (_tabController.index == 0) {
                    notifier.requestFollowers(context, reload: true);
                  } else {
                    notifier.requestFollowing(context, reload: true);
                  }
                },
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.background,
            body: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                UserFollowersList(),
                UserFollowingList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
