import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class FailedGetKTPDialog extends StatefulWidget {
  final bool faceVerification;
  const FailedGetKTPDialog({Key? key, this.faceVerification = false}) : super(key: key);

  @override
  State<FailedGetKTPDialog> createState() => _FailedGetKTPDialogState();
}

class _FailedGetKTPDialogState extends State<FailedGetKTPDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final size = MediaQuery.of(context).size;
    final _language = context.read<TranslateNotifierV2>().translate;

    String title = '';
    String body1 = '';
    String body2 = '';
    String titlePrimary = '';
    String titleSecondary = '';

    if (widget.faceVerification) {
      title = _language.localeDatetime == 'id' ? 'Selfie & e-KTP tidak cocok' : 'Selfie & e-KTP Don`t Match';
      body1 = _language.localeDatetime == 'id' ? 'Kami tidak menemukan kemiripan antara foto selfie dengan e-KTPmu. ' : 'We couldn`t find a match between your selfie and e-KTP photo. ';
      body2 =
          _language.localeDatetime == 'id' ? 'Pastikan wajahmu terlihat jelas dan tidak terpotong dengan pencahayaan yang cukup.' : 'Try taking another selfie with a clear face and good lighting.';

      titlePrimary = _language.localeDatetime == 'id' ? 'Selfie Ulang' : 'Retake Selfie';
      titleSecondary = _language.localeDatetime == 'id' ? 'Banding' : 'Appeal';
    } else {
      title = _language.uploadeKTPFailed ?? 'Upload e-KTP Gagal';
      body1 = _language.descFailedktp1 ?? 'Kami mengalami kesulitan dalam membaca e-KTPmu. ';
      body2 = _language.descFailedktp2 ?? 'Coba lagi atau gunakan dokumen lain seperti SIM, Kartu Keluarga, atau Paspor untuk melengkapi data.';
      titlePrimary = _language.retake ?? 'Foto Ulang';
      titleSecondary = _language.uploadSupportingDocuments ?? 'Upload Dokumen Pendukung';
    }

    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CustomTextWidget(
            textToDisplay: title,
            maxLines: 2,
            textStyle: theme.textTheme.subtitle1?.copyWith(fontWeight: FontWeight.w600),
          ),
          sixteenPx,
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: body1,
              style: const TextStyle(color: Colors.black, fontSize: 14, height: 1.3),
              children: [
                TextSpan(
                  text: body2,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          twentyFourPx,
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  caption: titlePrimary,
                  color: kHyppePrimary,
                  // function: widget.functionSecondary ?? () {},
                  textColor: Colors.white,
                  function: () {
                    if (widget.faceVerification) {
                      Routing().moveBack();
                      Routing().moveAndPop(Routes.cameraSelfieVerification);
                    } else {
                      Routing().moveBack();
                    }
                  },
                  theme: theme,
                ),
              ),
            ],
          ),
          SizedBox(
            width: SizeConfig.screenWidth,
            child: TextButton(
              onPressed: () {
                if (widget.faceVerification) {
                  Routing().moveBack();
                  Routing().moveReplacement(Routes.verificationIDStep6);
                } else {
                  context.read<VerificationIDNotifier>().toSupportDoc();
                }
              },
              style: ButtonStyle(side: MaterialStateProperty.all<BorderSide>(const BorderSide(color: kHyppePrimary))),
              child: Text(titleSecondary),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  caption: _language.back ?? 'Kembali',
                  color: Colors.transparent,
                  function: () {
                    if (widget.faceVerification) {
                      Routing().moveBack();
                    }
                    Routing().moveBack();
                    Routing().moveBack();
                    Routing().moveBack();
                  },
                  textColor: kHyppePrimary,
                  // function: () => _routing.moveBack(),
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton({required ThemeData theme, required String caption, required Function function, required Color color, Color? textColor, bool matchParent = false}) {
    return CustomTextButton(
      onPressed: () async {
        try {
          await function();
        } catch (_) {}
      },
      style: theme.elevatedButtonTheme.style?.copyWith(
        backgroundColor: MaterialStateProperty.all(color),
      ),
      child: matchParent
          ? SizedBox(
              width: double.infinity,
              child: CustomTextWidget(textToDisplay: caption, textStyle: theme.textTheme.button?.copyWith(color: textColor, fontSize: 14)),
            )
          : CustomTextWidget(textToDisplay: caption, textStyle: theme.textTheme.button?.copyWith(color: textColor, fontSize: 14)),
    );
  }
}
