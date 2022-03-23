import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';

import 'package:hyppe/ui/inner/home/content_v2/account_preferences/widget/proof_picture.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/widget/build_personal_profile_pic.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/widget/text_input_account_preferences.dart';

class BuildProfileBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AccountPreferencesNotifier>(
      builder: (_, notifier, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25.0),
        child: Column(
          children: [
            BuildPersonalProfilePic(),
            TextInputAccountPreferences(
              controller: notifier.userNameController,
              labelText: "${notifier.language.userName}*",
              hintText: notifier.language.userName,
            ),
            TextInputAccountPreferences(
              controller: notifier.emailController,
              labelText: "${notifier.language.email}*",
              hintText: notifier.language.email,
              readOnly: true,
            ),
            TextInputAccountPreferences(
              controller: notifier.fullNameController,
              labelText: "${notifier.language.fullName}*",
              hintText: notifier.language.fullName,
            ),
            TextInputAccountPreferences(
              controller: notifier.bioController,
              labelText: "Bio",
              hintText: "Bio",
              inputFormatter: [LengthLimitingTextInputFormatter(150)],
            ),
            const ProofPicture(),
          ],
        ),
      ),
    );
  }
}
