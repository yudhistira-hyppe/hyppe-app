import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/widget/qr_block.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/widget/share_block.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Referral extends StatefulWidget {
  const Referral({Key? key}) : super(key: key);

  @override
  State<Referral> createState() => _ReferralState();
}

class _ReferralState extends State<Referral> {
  @override
  void initState() {
    final notifier = Provider.of<ReferralNotifier>(context, listen: false);
    Future.delayed(Duration.zero, () => notifier.onInitial(context));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<ReferralNotifier>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          leadingWidth: 50 * SizeConfig.screenWidth! / SizeWidget.baseWidthXD,
          leading: CustomIconButtonWidget(
            defaultColor: true,
            iconData: "${AssetPath.vectorPath}back-arrow.svg",
            onPressed: () => Routing().moveBack(),
          ),
          titleSpacing: 0,
          title: CustomTextWidget(
            textToDisplay: notifier.language.referralID!,
            textStyle: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ShareBlock(),
                    const Spacer(),
                    const QRBlock(),
                    const Spacer(),
                    notifier.modelReferral?.parent == null
                        ? GestureDetector(
                            onTap: () {
                              Routing().move(Routes.insertReferral);
                            },
                            child: const Text('Masukkan Referral', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppePrimary)),
                          )
                        : notifier.modelReferral?.parent == null || notifier.modelReferral?.parent == ""
                            ? GestureDetector(
                                onTap: () {
                                  Routing().move(Routes.insertReferral);
                                },
                                child: const Text('Masukkan Referral', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppePrimary)),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Diundang oleh: ', style: Theme.of(context).textTheme.subtitle1),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: kHyppeLightSurface),
                                    child: Text(
                                      '${notifier.modelReferral?.parent}',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primaryVariant),
                                    ),
                                  ),
                                ],
                              )

                    // CustomElevatedButton(
                    //   width: 375.0 * SizeConfig.scaleDiagonal,
                    //   height: 44.0 * SizeConfig.scaleDiagonal,
                    //   function: () => null,
                    //   child: CustomTextWidget(
                    //     textToDisplay: notifier.language.downloadQRCode,
                    //     textStyle: Theme.of(context)
                    //         .textTheme
                    //         .button
                    //         ?.copyWith(color: kHyppeLightButtonText),
                    //   ),
                    //   buttonStyle: ButtonStyle(
                    //     foregroundColor: MaterialStateProperty.all(
                    //         Theme.of(context).colorScheme.primaryVariant),
                    //     shadowColor: MaterialStateProperty.all(
                    //         Theme.of(context).colorScheme.primaryVariant),
                    //     overlayColor: MaterialStateProperty.all(
                    //         Theme.of(context).colorScheme.primaryVariant),
                    //     backgroundColor: MaterialStateProperty.all(
                    //         Theme.of(context).colorScheme.primaryVariant),
                    //   ),
                    // ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
