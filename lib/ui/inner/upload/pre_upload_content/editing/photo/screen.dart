import 'dart:io';

import 'package:colorfilter_generator/addons.dart';
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/editing/photo/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/editing/photo/widget/custom_slider_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class EditPhotoScreen extends StatefulWidget {
  const EditPhotoScreen({super.key});

  @override
  State<EditPhotoScreen> createState() => _EditPhotoScreenState();
}

class _EditPhotoScreenState extends State<EditPhotoScreen> {
  late EditPhotoNotifier provider;
  final GlobalKey paintKey = GlobalKey();

  @override
  void initState() {
    provider = EditPhotoNotifier();
    provider.translate(context.read<TranslateNotifierV2>().translate);
    provider.copyFile(context);
    provider.initFilterCollection();
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
    return Consumer<EditPhotoNotifier>(
      builder: (_, notifier, __) {
        return WillPopScope(
          onWillPop: () async {
            ShowGeneralDialog.generalDialog(
              context,
              titleText: "${notifier.language.discardEdit}?",
              bodyText: "${notifier.language.discardEditDesc}",
              maxLineTitle: 1,
              maxLineBody: 4,
              functionPrimary: () async {
                Routing().moveBack();
                Routing().moveBack();
              },
              functionSecondary: () {
                Routing().moveBack();
              },
              titleButtonPrimary: "${notifier.language.delete}",
              titleButtonSecondary: "${notifier.language.cancel}",
              barrierDismissible: true,
            );
            return true;
          },
          child: Scaffold(
            backgroundColor: kHyppeBackground,
            body: Stack(
              children: [
                FilterBodyWidget(notifier: notifier, paintKey: paintKey),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: notifier.activeFilter != null
                      ? FilterSliderWidget(notifier: notifier)
                      : FilterCollectionWidget(notifier: notifier),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FilterBodyWidget extends StatelessWidget {
  final EditPhotoNotifier notifier;
  final GlobalKey paintKey;

  const FilterBodyWidget({
    super.key,
    required this.notifier,
    required this.paintKey,
  });

  @override
  Widget build(BuildContext context) {
    ColorFilterGenerator myFilter = ColorFilterGenerator(
      name: "CustomFilter",
      filters: [
        ColorFilterAddons.brightness(
            notifier.filters[0].value / notifier.filters[0].max),
        ColorFilterAddons.contrast(
            notifier.filters[1].value / notifier.filters[1].max),
        ColorFilterAddons.saturation(
            notifier.filters[2].value / notifier.filters[2].max),
        ColorFilterAddons.hue(
            notifier.filters[3].value / notifier.filters[3].max),
        ColorFilterAddons.sepia(
            notifier.filters[4].value / notifier.filters[4].max),
      ],
    );

    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (notifier.activeFilter == null)
                  const BackButton(color: kHyppeLightButtonText),
                if (notifier.activeFilter != null)
                  Expanded(
                    child: CustomTextWidget(
                      textToDisplay: notifier.activeFilter == null
                          ? ''
                          : notifier.filters[notifier.activeFilter ?? 0].name,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: kHyppeTextPrimary,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (notifier.activeFilter == null)
                  TextButton(
                    onPressed: () async {
                      ShowGeneralDialog.loadingDialog(context);
                      await notifier.saveImage(context, paintKey);
                      Routing().moveBack();
                      Routing().moveBack();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        '${notifier.language.done}',
                        style: const TextStyle(color: kHyppeTextPrimary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: notifier.tempFilePath!.isEmpty
                ? const CustomLoading()
                : Center(
                    child: RepaintBoundary(
                      key: paintKey,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(myFilter.matrix),
                        child: Image.file(
                          File(notifier.tempFilePath ?? ''),
                          filterQuality: FilterQuality.high,
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                            return wasSynchronouslyLoaded
                                ? child
                                : AnimatedOpacity(
                                    opacity: frame == null ? 0 : 1,
                                    duration: const Duration(seconds: 1),
                                    curve: Curves.easeOut,
                                    child: child,
                                  );
                          },
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class FilterCollectionWidget extends StatelessWidget {
  final EditPhotoNotifier notifier;

  const FilterCollectionWidget({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 32),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: notifier.filters.length,
        itemBuilder: (context, index) {
          return Row(
            children: [
              if (index == 0)
                InkWell(
                  onTap: () {
                    notifier.cropImage(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Text(
                          '${notifier.language.perspective}',
                          style: const TextStyle(
                            color: kHyppeTextPrimary,
                          ),
                        ),
                        eightPx,
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(
                              width: 1,
                              color: kHyppeDividerColor,
                            ),
                          ),
                          child: const CustomIconWidget(
                            height: 32,
                            iconData: "${AssetPath.vectorPath}perspective.svg",
                            defaultColor: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              InkWell(
                onTap: () {
                  notifier.activeFilter = index;
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
                  child: Column(
                    children: [
                      Text(
                        notifier.filters[index].name,
                        style: const TextStyle(
                          color: kHyppeTextPrimary,
                        ),
                      ),
                      eightPx,
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(36),
                          border: Border.all(
                            width: 1,
                            color: kHyppeDividerColor,
                          ),
                        ),
                        child: CustomIconWidget(
                          height: 32,
                          iconData:
                              "${AssetPath.vectorPath}${notifier.filters[index].icon}",
                          defaultColor: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class FilterSliderWidget extends StatelessWidget {
  final EditPhotoNotifier notifier;

  const FilterSliderWidget({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CustomSliderWidget(
            value: notifier.filters[notifier.activeFilter ?? 0].value,
            min: notifier.filters[notifier.activeFilter ?? 0].min,
            max: notifier.filters[notifier.activeFilter ?? 0].max,
            onChanged: (double value) {
              if (notifier.activeFilter != null) {
                notifier.setFilterValue(
                    index: notifier.activeFilter!, value: value);
              }
            },
          ),
          sixteenPx,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () async {
                  if (notifier.activeFilter != null) {
                    notifier.filters[notifier.activeFilter!].value =
                        notifier.filters[notifier.activeFilter!].previousValue;
                  }
                  notifier.activeFilter = null;
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    '${notifier.language.cancel}',
                    style: const TextStyle(color: kHyppeTextPrimary),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (notifier.activeFilter != null) {
                    notifier.filters[notifier.activeFilter!].previousValue =
                        notifier.filters[notifier.activeFilter!].value;
                  }
                  notifier.activeFilter = null;
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                  ),
                  child: Text(
                    '${notifier.language.done}',
                    style: const TextStyle(
                      color: kHyppeTextPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
