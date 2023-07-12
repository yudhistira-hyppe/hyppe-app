import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionBadgeScreen extends StatefulWidget {
  const CollectionBadgeScreen({Key? key}) : super(key: key);

  @override
  State<CollectionBadgeScreen> createState() => _CollectionBadgeScreenState();
}

class _CollectionBadgeScreenState extends State<CollectionBadgeScreen> with RouteAware, AfterFirstLayoutMixin, SingleTickerProviderStateMixin {
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
            icon: Icon(
              Icons.arrow_back_ios_new_sharp,
              color: kHyppeTextLightPrimary,
              size: 16,
            ),
            onPressed: () {},
          ),
          title: Text(
            'Koleksi Badge Saya',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
            ),
          ),
          titleSpacing: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [],
          ),
        ));
  }
}
