import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:path/path.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class VerificationIDStepSupportingDocsPreview extends StatefulWidget {
  const VerificationIDStepSupportingDocsPreview({Key? key}) : super(key: key);

  @override
  State<VerificationIDStepSupportingDocsPreview> createState() =>
      _VerificationIDStepSupportingDocsPreviewState();
}

class _VerificationIDStepSupportingDocsPreviewState
    extends State<VerificationIDStepSupportingDocsPreview> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<VerificationIDNotifier>(
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
            textToDisplay: notifier.language.supportDoc!,
            textStyle:
                Theme.of(context).textTheme.headline6!.copyWith(fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: ListView.separated(
          itemCount: notifier.pickedSupportingDocs!.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(basename(notifier.pickedSupportingDocs![index].path)),
            subtitle: Text(
                notifier.pickedSupportingDocs![index].lengthSync().toString()),
            leading: Image.file(notifier.pickedSupportingDocs![index]),
          ),
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(
              color: Colors.black12,
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          color: kHyppeLightBackground,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: CustomElevatedButton(
            width: SizeConfig.screenWidth,
            height: 44.0 * SizeConfig.scaleDiagonal,
            function: () => notifier.onSaveSupportedDocument(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (notifier.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                const SizedBox(width: 10),
                CustomTextWidget(
                  textToDisplay: notifier.language.save!,
                  textStyle:
                      textTheme.button?.copyWith(color: kHyppeLightButtonText),
                ),
              ],
            ),
            buttonStyle: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primaryVariant),
              shadowColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primaryVariant),
              overlayColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primaryVariant),
              backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primaryVariant),
            ),
          ),
        ),
      ),
    );
  }
}
