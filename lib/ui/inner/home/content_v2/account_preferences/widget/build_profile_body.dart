import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';

import 'package:hyppe/ui/inner/home/content_v2/account_preferences/widget/proof_picture.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/widget/build_personal_profile_pic.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/widget/text_input_account_preferences.dart';

class BuildProfileBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'BuildProfileBody');
    return Consumer<AccountPreferencesNotifier>(
      builder: (_, notifier, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25.0),
        child: Column(
          children: [
            const BuildPersonalProfilePic(),
            twentyPx,
            GestureDetector(
              onTap: () {
                Routing().move(Routes.chalengeCollectionBadge);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: ShapeDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(1.00, 0.00),
                    end: Alignment(-1, 0),
                    colors: [
                      Color(0xFFAB22AF),
                      Color(0xFF7551C0),
                    ],
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "${AssetPath.pngPath}avatarbadge.png",
                      height: 37,
                    ),
                    twelvePx,
                    Text(
                      "${notifier.language.seeMyBadgeCollection}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
            thirtyTwoPx,
            TextInputAccountPreferences(
              controller: notifier.userNameController,
              labelText: "${notifier.language.userName}*",
              hintText: notifier.language.userName,
              inputAreaHeight: 50 * SizeConfig.scaleDiagonal,
              readOnly: false,
              maxLength: 30,
              counterText: false,
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
              textInput: TextInputType.multiline,
              keyboardNewline: true,
            ),
            const ProofPicture(),
          ],
        ),
      ),
    );
  }
}
