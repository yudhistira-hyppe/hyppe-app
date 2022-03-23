import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:provider/provider.dart';

class ButtonChangePassword extends StatelessWidget {
  final Color buttonColor;
  final Function? onTap;
  final TextStyle textStyle;
  final String? caption;
  final bool loading;
  const ButtonChangePassword({
    Key? key,
    required this.buttonColor,
    required this.textStyle,
    this.loading = false,
    this.caption,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Consumer<TranslateNotifierV2>(
          builder: (_, notifier, __) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomElevatedButton(
                width: SizeConfig.screenWidth,
                height: 50,
                buttonStyle: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(buttonColor),
                    overlayColor: MaterialStateProperty.all<Color>(buttonColor),
                    foregroundColor: MaterialStateProperty.all<Color>(buttonColor),
                    shadowColor: MaterialStateProperty.all<Color>(buttonColor)),
                function: onTap,
                child: loading
                    ? const CustomLoading()
                    : CustomTextWidget(
                        textToDisplay: caption ?? notifier.translate.next!,
                        textStyle: textStyle,
                      ),
              ),
            ],
          ),
        ),
      );
}
