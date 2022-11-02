import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';

class OnSignOutSheet extends StatefulWidget {
  final Function() onSignOut;

  const OnSignOutSheet({
    Key? key,
    required this.onSignOut,
  }) : super(key: key);

  @override
  State<OnSignOutSheet> createState() => _OnSignOutSheetState();
}

class _OnSignOutSheetState extends State<OnSignOutSheet> with LoadingNotifier {
  @override
  Widget build(BuildContext context) {
    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier, __) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
              CustomTextWidget(
                textToDisplay: notifier.translate.keepSignIn ?? '',
                textStyle: Theme.of(context).textTheme.headline6,
              ),
              CustomElevatedButton(
                child: CustomTextWidget(
                  textToDisplay: notifier.translate.yesSure ?? '',
                  textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText),
                ),
                width: double.infinity,
                height: 50,
                function: () => Routing().moveBack(),
                buttonStyle: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                    overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant)),
              ),
              CustomElevatedButton(
                child: !isLoading
                    ? CustomTextWidget(
                        textToDisplay: notifier.translate.noLogout ?? '',
                        textStyle: Theme.of(context).textTheme.button,
                      )
                    : const CustomLoading(),
                width: double.infinity,
                height: 50,
                function: () async {
                  if (isLoading) return;
                  try {
                    setState(() => setLoading(true));
                    await widget.onSignOut();
                  } finally {
                    setState(() => setLoading(false));
                  }
                },
                buttonStyle: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.transparent), overlayColor: MaterialStateProperty.all(Colors.transparent)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
