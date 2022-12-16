import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/size_config.dart';
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
              inputAreaHeight: 50 * SizeConfig.scaleDiagonal,
              readOnly: false,
            ),
            TextInputAccountPreferences(
              controller: notifier.emailController,
              labelText: "${notifier.language.email}*",
              hintText: notifier.language.email,
              readOnly: true,
              inputAreaHeight: 50 * SizeConfig.scaleDiagonal,
            ),
            TextInputAccountPreferences(
              controller: notifier.fullNameController,
              labelText: "${notifier.language.fullName}*",
              hintText: notifier.language.fullName,
              inputAreaHeight: 50 * SizeConfig.scaleDiagonal,
              maxLength: 30,
              minLines: 2,
              counterText: false,
            ),
            TextInputAccountPreferences(
              controller: notifier.bioController,
              labelText: "Bio",
              hintText: "Bio",
              inputFormatter: [LengthLimitingTextInputFormatter(150)],
              maxLength: 150,
              inputAreaHeight: 200 * SizeConfig.scaleDiagonal,
              minLines: 3,
              keyboardNewline: true,
            ),
            const ProofPicture(),
          ],
        ),
      ),
    );
  }
}
