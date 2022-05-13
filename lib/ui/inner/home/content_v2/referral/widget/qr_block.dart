import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/notifier.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRBlock extends StatefulWidget {
  const QRBlock({Key? key}) : super(key: key);

  @override
  State<QRBlock> createState() => _QRBlockState();
}

class _QRBlockState extends State<QRBlock> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ReferralNotifier>(
      builder: (_, notifier, __) => Column(
        children: [
          QrImage(
            data: notifier.referralLink,
            version: QrVersions.auto,
            size: 140.0,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextWidget(
              textToDisplay: notifier.language.shareYourQR!,
              textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primaryVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
