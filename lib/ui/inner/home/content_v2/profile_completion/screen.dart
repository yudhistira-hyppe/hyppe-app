import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile_completion/widget/profile_completion_action.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile_completion/widget/profile_completion_form.dart';

class ProfileCompletion extends StatelessWidget {
  const ProfileCompletion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          ProfileCompletionForm(),
          ProfileCompletionAction(),
        ],
      ),
    );
  }
}
