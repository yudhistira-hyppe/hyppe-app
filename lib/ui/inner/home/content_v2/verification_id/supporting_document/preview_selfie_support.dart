import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class PreviewSelfieSupport extends StatefulWidget {
  const PreviewSelfieSupport({Key? key}) : super(key: key);

  @override
  State<PreviewSelfieSupport> createState() => _PreviewSelfieSupportState();
}

class _PreviewSelfieSupportState extends State<PreviewSelfieSupport> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'PreviewSelfieSupport');

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    });
  }

  @override
  void dispose() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          Routing().moveBack();
          return false;
        },
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(File(notifier.selfiePath)),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 16, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextButton(onPressed: () => Routing().moveBack(), child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg", defaultColor: false)),
                      GestureDetector(
                        onTap: () {
                          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
                          if (notifier.selfieOnSupportDocs) {
                            notifier.onSaveSupportedDocument(context);
                          } else {
                            notifier.postVerificationData(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          decoration: BoxDecoration(
                            color: kHyppePrimary,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            notifier.language.confirm ?? '',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // Image.file(File(notifier.selfiePath)),
            ],
          ),
        ),
      ),
    );
  }
}
