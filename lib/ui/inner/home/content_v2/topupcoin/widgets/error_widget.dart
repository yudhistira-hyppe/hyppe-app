import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/disccount/notifier.dart';
import 'package:provider/provider.dart';

class ErrorCouponsWidget extends StatelessWidget {
  final LocalizationModelV2? lang;
  const ErrorCouponsWidget({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(18.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextWidget(textToDisplay: lang?.noInternet??'Hyppe needs the internetto groove 🕺🌐', textStyle: const TextStyle(fontWeight: FontWeight.bold)),
            tenPx,
            CustomTextWidget(textToDisplay: lang?.noInternetLabel??'Check your Wi-Fi or data  and let\'s get Hyppe groovin\' again! ',),
            fortyEightPx,
            SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: ElevatedButton(
                onPressed: () {
                  context.read<DiscNotifier>().initDisc(context);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(
                      color: kHyppePrimary
                    )
                  ),
                ),
                child: Center(
                    child: Text(lang?.retry??'Retry',
                        textAlign: TextAlign.center, style: const TextStyle(color: kHyppePrimary),),
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}