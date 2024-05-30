import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:provider/provider.dart';

class LoadingKycDialog extends StatelessWidget {
  final bool uploadProses;
  const LoadingKycDialog({Key? key, this.uploadProses = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final translate = context.read<TranslateNotifierV2>().translate;
    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
            // height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    )),
                twelvePx,
                GestureDetector(
                  // onTap: () => Routing().moveBack(),
                  child: CustomTextWidget(
                    textToDisplay: "${translate.process} ${notifier.proses1 ? '' : '(2)'}",
                    textStyle: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
