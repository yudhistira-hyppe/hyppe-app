import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/contents/user_interest_screen_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/keyboard_disposal.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_interest/content/interest_content.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_interest/user_interest_notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class UserInterestScreen extends StatefulWidget {
  final UserInterestScreenArgument arguments;
  const UserInterestScreen({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<UserInterestScreen> createState() => _UserInterestScreenState();
}

class _UserInterestScreenState extends State<UserInterestScreen> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'UserInterestScreen');
    print(widget.arguments.userInterested);
    final notifier = Provider.of<UserInterestNotifier>(context, listen: false);
    Future.delayed(Duration.zero, () => notifier.initUserInterest(context, widget.arguments));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async => widget.arguments.fromSetting,
      child: KeyboardDisposal(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Stack(
              children: [
                SizedBox(
                  width: SizeConfig.screenWidth,
                  child: InterestContent(fromSetting: widget.arguments.fromSetting, userInterested: widget.arguments.userInterested),
                ),
                if (widget.arguments.fromSetting)
                  Padding(
                    padding: const EdgeInsets.only(top: 50, left: 16),
                    child: GestureDetector(
                      onTap: () {
                        context.read<UserInterestNotifier>().onBackPress(widget.arguments.fromSetting);
                        Routing().moveBack();
                      },
                      child: const CustomIconWidget(iconData: '${AssetPath.vectorPath}back-arrow.svg'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
