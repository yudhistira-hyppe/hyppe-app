import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class FailedGetKTPDialog extends StatefulWidget {
  final String? titleText;
  final String? bodyText;
  final int? maxLineTitle;
  final int? maxLineBody;
  final Function functionPrimary;
  final Function? functionSecondary;
  final String? titleButtonPrimary;
  final String? titleButtonSecondary;
  final bool? isLoading;
  final bool isHorizontal;
  final bool fillColor;
  const FailedGetKTPDialog(
      {Key? key,
      this.titleText,
      this.bodyText,
      this.maxLineTitle,
      this.maxLineBody,
      required this.functionPrimary,
      this.functionSecondary,
      this.titleButtonPrimary,
      this.titleButtonSecondary,
      this.isLoading = false,
      this.isHorizontal = true,
      this.fillColor = true})
      : super(key: key);

  @override
  State<FailedGetKTPDialog> createState() => _FailedGetKTPDialogState();
}

class _FailedGetKTPDialogState extends State<FailedGetKTPDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final size = MediaQuery.of(context).size;
    final _language = context.read<TranslateNotifierV2>().translate;
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CustomTextWidget(
            textToDisplay: _language.uploadeKTPFailed ?? 'Upload e-KTP Gagal',
            maxLines: widget.maxLineTitle,
            textStyle: theme.textTheme.subtitle1?.copyWith(fontWeight: FontWeight.w600),
          ),
          sixteenPx,
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: _language.descFailedktp1 ?? 'Kami mengalami kesulitan dalam membaca e-KTPmu. ',
              style: const TextStyle(color: Colors.black, fontSize: 14, height: 1.3),
              children: [
                TextSpan(
                  text: _language.descFailedktp2 ?? 'Coba lagi atau gunakan dokumen lain seperti SIM, Kartu Keluarga, atau Paspor untuk melengkapi data.',
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
                  caption: _language.retake ?? 'Foto Ulang',
                  color: kHyppePrimary,
                  // function: widget.functionSecondary ?? () {},
                  textColor: Colors.white,
                  function: () => Routing().moveBack(),
                  theme: theme,
                ),
              ),
            ],
          ),
          SizedBox(
            width: SizeConfig.screenWidth,
            child: TextButton(
              onPressed: () {
                context.read<VerificationIDNotifier>().toSupportDoc();
              },
              style: ButtonStyle(side: MaterialStateProperty.all<BorderSide>(const BorderSide(color: kHyppePrimary))),
              child: Text(_language.uploadSupportingDocuments ?? 'Upload Dokumen Pendukung'),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  caption: _language.back ?? 'Kembali',
                  color: Colors.transparent,
                  function: () {
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
