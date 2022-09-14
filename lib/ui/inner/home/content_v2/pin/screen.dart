import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/widget/custom_rectangle_input.dart';
import 'package:provider/provider.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({Key? key}) : super(key: key);

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PinAccountNotifier>().cekUserPin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PinAccountNotifier>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg"),
            splashRadius: 1,
            onPressed: () {
              notifier.onExit();
            },
          ),
          titleSpacing: 0,
          title: CustomTextWidget(
            textToDisplay: notifier.pinCreate
                ? 'Change Pin'
                : notifier.confirm
                    ? 'Confirm PIN'
                    : 'Set New Pin',
            textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 18 * SizeConfig.scaleDiagonal),
          ),
          centerTitle: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Center(
                child: CustomIconWidget(
                  height: 40,
                  iconData: "${AssetPath.vectorPath}lock-pin.svg",
                  defaultColor: false,
                  color: kHyppePrimary,
                ),
              ),
              CustomTextWidget(
                textToDisplay: !notifier.confirm ? 'Enter New PIN' : 'Confirm New PIN',
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
              ),
              sixPx,
              const CustomTextWidget(textToDisplay: 'Enter your 6 digit Hyppe PIN'),
              twelvePx,
              CustomRectangleInput(),
              notifier.confirm && !notifier.matchingPin
                  ? CustomTextWidget(
                      textToDisplay: notifier.language.enterThePinThatMatchesThePinYouFilledInEarlier!,
                      maxLines: 3,
                      textStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color: kHyppeRed),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
