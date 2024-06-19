import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/arguments/account_preference_screen_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_tab_page_selector.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';

class VerifiedScreen extends StatefulWidget {
  const VerifiedScreen({super.key});

  @override
  State<VerifiedScreen> createState() => _VerifiedScreenState();
}

class _VerifiedScreenState extends State<VerifiedScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  List slide = [
    {
      'title': 'Yeay, akunmu resmi terverifikasi!',
      'titleEn': 'Yay, your account is officially verified!',
      'desc': 'Dapatkan berbagai pengalaman eksklusif untuk verified Hyppers.',
      'descEn': 'Unlock various exclusive experiences for verified Hyppers.',
      'icon': 'verifi1.svg',
    },
    {
      'title': 'Raih Badge Pemenang & Rewards',
      'titleEn': 'Earn Badges & Rewards',
      'desc': 'Temukan berbagai tantangan seru! Dapatkan badge pemenang dan rewards dengan berpartisipasi dalam berbagai challenge.',
      'descEn': 'Ready for challenges? Earn badges and rewards in thrilling challenges.',
      'icon': 'verifi2.svg',
    },
    {
      'title': 'Perluas Jangakuanmu!',
      'titleEn': 'Boost Your Presence',
      'desc': 'Fitur Boost Post hadir untuk mengoptimalkan jangkauan postinganmu.',
      'descEn': 'Take center stage! Harness the power of Boost Post to amplify your reach.',
      'icon': 'verifi3.svg',
    },
    {
      'title': 'Mulai Jual Konten & Sertifikat Kepemilikan Konten',
      'titleEn': 'Monetize & Content Ownership',
      'desc': 'Waktunya meraih keuntungan dari konten tanpa takut ditiru dengan sertifikat kepemilikan konten.',
      'descEn': 'Turn creativity into earnings no imitations allowed. Grab your content ownership certificate now!',
      'hastag': '#ShareWhatInspiresYou',
      'icon': 'verifi4.svg',
    },
  ];

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SignUpWelcome');
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
    _tabController?.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.removeListener(() => this);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 5,
          child: Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
                  slideTemplate(0),
                  slideTemplate(1),
                  slideTemplate(2),
                  slideTemplate(3),
                ],
              ),
              Align(
                alignment: const Alignment(0, 0.6),
                child: CustomTabPageSelector(
                  controller: _tabController,
                  activeColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Align(
                alignment: const Alignment(0, 0.9),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: kHyppePrimary), borderRadius: BorderRadius.circular(8.0)),
                    child: CustomElevatedButton(
                      width: SizeConfig.screenWidth,
                      height: 50,
                      buttonStyle: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                          overlayColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
                          foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
                          shadowColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary)),
                      function: () {
                        // context.read<SignUpCompleteProfileNotifier>().onReset();
                        /// TODO: Changed rules complete profile
                        // Routing().move(userCompleteProfile);
                        Routing().moveBack();

                        /// End TODO
                      },
                      child: CustomTextWidget(
                        textToDisplay: System().bodyMultiLang(bodyEn: 'Close', bodyId: 'Tutup') ?? '',
                        textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppePrimary),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget slideTemplate(int index) {
    var data = slide[index];
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(height: 100 * SizeConfig.scaleDiagonal),
          CustomIconWidget(
            iconData: '${AssetPath.vectorPath}${data['icon']}',
            defaultColor: false,
          ),
          fortyPx,
          Text(
            System().bodyMultiLang(bodyEn: data['titleEn'], bodyId: data['title']) ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kHyppeTextLightPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          twelvePx,
          Text(
            System().bodyMultiLang(bodyEn: data['descEn'], bodyId: data['desc']) ?? '',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
