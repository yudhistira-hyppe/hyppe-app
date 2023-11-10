import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/cache_and_download/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class CacheAndDownloadScreen extends StatefulWidget {
  const CacheAndDownloadScreen({super.key});

  @override
  State<CacheAndDownloadScreen> createState() => _CacheAndDownloadScreenState();
}

class _CacheAndDownloadScreenState extends State<CacheAndDownloadScreen> {
  late CacheAndDownloadNotifier provider;
  final indicator = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    provider = CacheAndDownloadNotifier();
    provider.getCacheDirSize();
    provider.getStorageDirSize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      builder: (context, child) => buildPage(context),
    );
  }

  Widget buildPage(BuildContext context) {
    return Consumer2<CacheAndDownloadNotifier, TranslateNotifierV2>(
        builder: (_, notifier, translateNotifier, __) {
      return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: CustomTextWidget(
            textStyle: Theme.of(context).textTheme.subtitle1,
            textToDisplay: '${translateNotifier.translate.cacheAndDownload}',
          ),
        ),
        body: RefreshIndicator(
          key: indicator,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 800));
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StorageItemWidget(
                  onTap: () {
                    ShowGeneralDialog.generalDialog(
                      context,
                      titleText: "${translateNotifier.translate.clear} ${translateNotifier.translate.cache}",
                      bodyText: "",
                      maxLineTitle: 1,
                      maxLineBody: 1,
                      functionPrimary: () async {
                        Routing().moveBack();
                        indicator.currentState?.show();
                        notifier.deleteCacheDir();
                      },
                      functionSecondary: () {
                        Routing().moveBack();
                      },
                      titleButtonPrimary: "${translateNotifier.translate.clear}",
                      titleButtonSecondary: "${translateNotifier.translate.cancel}",
                      barrierDismissible: false,
                    );
                  },
                  title:
                      '${translateNotifier.translate.cache}: ${notifier.cacheSize}',
                  description:
                      translateNotifier.translate.cacheDescription ?? '',
                  buttonText: translateNotifier.translate.clear ?? '',
                ),
                twelvePx,
                const Divider(thickness: 1, color: kHyppeBgNotSolve),
                twelvePx,
                StorageItemWidget(
                  onTap: () {
                    ShowGeneralDialog.generalDialog(
                      context,
                      titleText: "${translateNotifier.translate.clear} ${translateNotifier.translate.download}",
                      bodyText: "",
                      maxLineTitle: 1,
                      maxLineBody: 1,
                      functionPrimary: () async {
                        Routing().moveBack();
                        indicator.currentState?.show();
                        notifier.deleteStorageDir();
                      },
                      functionSecondary: () {
                        Routing().moveBack();
                      },
                      titleButtonPrimary: "${translateNotifier.translate.clear}",
                      titleButtonSecondary: "${translateNotifier.translate.cancel}",
                      barrierDismissible: false,
                    );
                  },
                  title:
                      '${translateNotifier.translate.download}: ${notifier.storageSize}',
                  description:
                      translateNotifier.translate.downloadDescription ?? '',
                  buttonText: translateNotifier.translate.clear ?? '',
                ),
                twentyFourPx,
                InkWell(
                  onTap: () {
                    ShowGeneralDialog.generalDialog(
                      context,
                      titleText: "${translateNotifier.translate.clearAll}",
                      bodyText: "",
                      maxLineTitle: 1,
                      maxLineBody: 1,
                      functionPrimary: () async {
                        Routing().moveBack();
                        indicator.currentState?.show();
                        notifier.deleteCacheDir();
                        notifier.deleteStorageDir();
                      },
                      functionSecondary: () {
                        Routing().moveBack();
                      },
                      titleButtonPrimary: "${translateNotifier.translate.clear}",
                      titleButtonSecondary: "${translateNotifier.translate.cancel}",
                      barrierDismissible: false,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CustomIconWidget(
                          defaultColor: false,
                          height: 20,
                          width: 20,
                          color: Colors.black,
                          iconData: '${AssetPath.vectorPath}delete.svg',
                        ),
                        const SizedBox(width: 8),
                        CustomTextWidget(
                          textToDisplay:
                              translateNotifier.translate.clearAll ?? '',
                          textStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class StorageItemWidget extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onTap;

  const StorageItemWidget({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextWidget(
          textToDisplay: title,
          textStyle: Theme.of(context).textTheme.subtitle1,
        ),
        eightPx,
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextWidget(
                textToDisplay: description,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: kHyppeBurem),
                maxLines: 5,
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: kHyppeBorderTab),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: CustomTextWidget(
                  textToDisplay: buttonText,
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
