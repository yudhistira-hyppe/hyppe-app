import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/notifier.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRBlock extends StatefulWidget {
  const QRBlock({Key? key}) : super(key: key);

  @override
  State<QRBlock> createState() => _QRBlockState();
}

class _QRBlockState extends State<QRBlock> {

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'QRBlock');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReferralNotifier>(
        builder: (_, notifier, __) => Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Container(
                    height: 360,
                    width: 383,
                    decoration: BoxDecoration(color: kHyppeLightSurface, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 80),
                          color: kHyppeLightSurface,
                          height: 180,
                          width: 180,
                          child: QrImage(
                            data: notifier.referralLink,
                            version: QrVersions.auto,
                            size: 140.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: CustomTextWidget(
                              textToDisplay: notifier.language.shareYourQR ?? '', textStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary, fontWeight: FontWeight.w400)),
                        ),
                      ],
                    ),
                  ),
                ),
                Consumer<SelfProfileNotifier>(
                  builder: (_, notifier, __) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          CustomProfileImage(
                            following: true,
                            width: 80 * SizeConfig.scaleDiagonal,
                            height: 80 * SizeConfig.scaleDiagonal,
                            imageUrl: notifier.displayPhotoProfile("${notifier.user.profile?.avatar?.mediaEndpoint}"),
                            onTap: () => notifier.viewStory(context),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            notifier.displayUserName(),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ));
  }
}
