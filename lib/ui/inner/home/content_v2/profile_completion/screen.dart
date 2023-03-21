import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/account_preference_screen_argument.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile_completion/widget/profile_completion_action.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile_completion/widget/profile_completion_form.dart';
import 'package:provider/provider.dart';

class ProfileCompletion extends StatefulWidget {
  final AccountPreferenceScreenArgument argument;
  const ProfileCompletion({Key? key, required this.argument}) : super(key: key);

  @override
  State<ProfileCompletion> createState() => _ProfileCompletionState();
}

class _ProfileCompletionState extends State<ProfileCompletion> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ProfileCompletion');
    final notifier =
        Provider.of<AccountPreferencesNotifier>(context, listen: false);
    Future.delayed(
        Duration.zero, () => notifier.onInitial(context, widget.argument));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            ProfileCompletionForm(),
            ProfileCompletionAction(),
          ],
        ),
      ),
    );
  }
}
