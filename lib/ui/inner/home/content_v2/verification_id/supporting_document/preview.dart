import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:path/path.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:provider/provider.dart';

class VerificationIDStepSupportingDocsPreview extends StatefulWidget {
  const VerificationIDStepSupportingDocsPreview({Key? key}) : super(key: key);

  @override
  State<VerificationIDStepSupportingDocsPreview> createState() => _VerificationIDStepSupportingDocsPreviewState();
}

class _VerificationIDStepSupportingDocsPreviewState extends State<VerificationIDStepSupportingDocsPreview> {

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'VerificationIDStepSupportingDocsPreview');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          notifier.retrySelfie(context);
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            leadingWidth: 50 * (SizeConfig.screenWidth ?? context.getWidth()) / SizeWidget.baseWidthXD,
            leading: CustomIconButtonWidget(
              defaultColor: true,
              iconData: "${AssetPath.vectorPath}back-arrow.svg",
              onPressed: () => notifier.retrySelfie(context),
            ),
            titleSpacing: 0,
            title: CustomTextWidget(
              textToDisplay: notifier.language.supportDoc ?? '',
              textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
            ),
            centerTitle: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () => ShowBottomSheet.onShowHelpSupportDocs(context),
                  child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}info-icon.svg"),
                ),
              )
            ],
          ),
          body: Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                itemCount: notifier.pickedSupportingDocs?.length ?? 0,
                itemBuilder: (context, index) => ListTile(
                  title: Text(basename(notifier.pickedSupportingDocs?[index].path ?? '')),
                  subtitle: Text(notifier.pickedSupportingDocs?[index].lengthSync().toString() ?? ''),
                  leading: notifier.pickedSupportingDocs?[index] != null ? Image.file(notifier.pickedSupportingDocs![index]) : null,
                  trailing: GestureDetector(
                    onTap: () {
                      setState(() {
                        notifier.pickedSupportingDocs?.removeAt(index);
                      });
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(border: Border.all(color: kHyppePrimary), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          notifier.language.delete ?? '',
                          style: const TextStyle(color: kHyppePrimary),
                        )),
                  ),
                ),
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    color: Colors.black12,
                  );
                },
              ),
              GestureDetector(
                onTap: () {
                  notifier.onPickSupportedDocument(context, true);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        notifier.language.addDocument ?? 'Add Document',
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: kHyppePrimary, fontWeight: FontWeight.bold),
                      ),
                      const Icon(
                        Icons.add,
                        color: kHyppePrimary,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Container(
            color: kHyppeLightBackground,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: CustomElevatedButton(
              width: SizeConfig.screenWidth,
              height: 44.0 * SizeConfig.scaleDiagonal,
              function: () {
                if (!notifier.isLoading) {
                  notifier.onSaveSupportedDocument(context);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (notifier.isLoading)
                    Container(
                      padding: const EdgeInsets.all(5),
                      height: 30,
                      width: 30,
                      child: const CircularProgressIndicator(color: Colors.white),
                    ),
                  const SizedBox(width: 10),
                  CustomTextWidget(
                    textToDisplay: notifier.language.save ?? '',
                    textStyle: textTheme.button?.copyWith(color: kHyppeLightButtonText),
                  ),
                ],
              ),
              buttonStyle: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                shadowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
