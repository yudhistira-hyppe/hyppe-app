import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/collection/badge.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({Key? key}) : super(key: key);

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> with RouteAware, AfterFirstLayoutMixin, SingleTickerProviderStateMixin {
  LocalizationModelV2? lang;
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'Chalange Screen');

    lang = context.read<TranslateNotifierV2>().translate;

    Future.delayed(Duration.zero, () {
      var cn = context.read<ChallangeNotifier>();
      cn.initLeaderboard(context);
    });

    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    var cn = context.watch<ChallangeNotifier>();
    isFromSplash = false;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_sharp,
              color: kHyppeTextLightPrimary,
              size: 16,
            ),
            onPressed: () {
              Routing().moveBack();
            },
          ),
          title: const Text(
            'Halaman Pencapaian',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
            ),
          ),
          titleSpacing: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: kHyppeLightSurface,
                child: Container(
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(1.00, 0.00),
                      end: Alignment(-1, 0),
                      colors: [Color(0xFF7551C0), Color(0xFFAB22AF)],
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    children: [Text("sdsd")],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Badge Challenge Aktif',
                      style: TextStyle(
                        color: Color(0xFF3E3E3E),
                        fontSize: 14,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    twentyFourPx,
                  ],
                ),
              ),
              Container(
                height: 24,
                color: kHyppeLightSurface,
              ),
            ],
          ),
        ));
  }
}
