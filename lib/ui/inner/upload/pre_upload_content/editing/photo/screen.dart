import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/filter/layer_model.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/editing/photo/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/editing/photo/widget/custom_slider_widget.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:fhoto_editor/fhoto_editor.dart';

class EditPhotoScreen extends StatefulWidget {
  const EditPhotoScreen({super.key});

  @override
  State<EditPhotoScreen> createState() => _EditPhotoScreenState();
}

class _EditPhotoScreenState extends State<EditPhotoScreen> {
  final colorGen = ColorFilterGenerator.getInstance();
  late EditPhotoNotifier provider;

  @override
  void initState() {
    provider = EditPhotoNotifier();
    provider.activeFilter = 1;
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
    return Consumer2<EditPhotoNotifier, PreviewContentNotifier>(
      builder: (_, notifier, previewContentNotifier, __) {
        ColorMultiFilterGenerator myFilter =
            ColorMultiFilterGenerator(filters: [
          colorGen.getHueMatrix(
              value: notifier.filters[0].value / notifier.filters[0].max),
          colorGen.getContrastMatrix(
              value: notifier.filters[1].value / notifier.filters[1].max),
          // colorGen.getBrightnessMatrix(
          //     value: notifier.filters[2].value / notifier.filters[2].max),
          // colorGen.getSaturationMatrix(
          //     value: notifier.filters[3].value / notifier.filters[3].max),
          // colorGen.getExposureMatrix(
          //     value: notifier.filters[4].value / notifier.filters[4].max),
          // colorGen.getShadowMatrix(
          //     value: notifier.filters[5].value / notifier.filters[5].max),
          // colorGen.getHighlightedMatrix(
          //     value: notifier.filters[6].value / notifier.filters[6].max),
          // colorGen.getFadedMatrix(
          //     value: notifier.filters[7].value / notifier.filters[7].max),
          // colorGen.getVibrancyMatrix(
          //     value: notifier.filters[8].value / notifier.filters[8].max),
          // colorGen.getTemperatureMatrix(
          //     value: notifier.filters[9].value / notifier.filters[9].max),
        ]);
        return Scaffold(
          backgroundColor: kHyppeBackground,
          body: Stack(
            children: [
              Center(
                child: Column(
                  children: [
                    sixteenPx,
                    CustomTextWidget(
                      textToDisplay: notifier.activeFilter == null
                          ? ''
                          : notifier.filters[notifier.activeFilter ?? 0].name,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        color: kHyppeTextPrimary,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    sixteenPx,
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(myFilter.matrix),
                        child: Image.file(
                          File(
                            previewContentNotifier.fileContent?[0] ?? '',
                          ),
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
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: notifier.activeFilter != null
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            CustomSliderWidget(
                              value: notifier
                                  .filters[notifier.activeFilter ?? 0].value,
                              min: notifier
                                  .filters[notifier.activeFilter ?? 0].min,
                              max: notifier
                                  .filters[notifier.activeFilter ?? 0].max,
                              onChanged: (double value) {
                                notifier.setFilterValue(
                                  index: notifier.activeFilter ?? 0,
                                  value: value,
                                );
                              },
                            ),
                            sixteenPx,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    notifier.activeFilter = null;
                                  },
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.0),
                                    child: Text(
                                      'Batal',
                                      style:
                                          TextStyle(color: kHyppeTextPrimary),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    // notifier.activeFilter = null;
                                    final image = img.decodeImage(File(previewContentNotifier.fileContent?[0] ?? '').readAsBytesSync());
                                    final result = img.adjustColor(image!, hue: 1, brightness: 1);
                                    // final thumbnail = img.copyResize(image!, width: 120);
                                    // encodeToJpgFile('/storage/emulated/0/Download/thumbnail-test.png', thumbnail);
                                    // final directory = Directory('/storage/emulated/0/Download');
                                    // final File file = File('${directory.path}/filtered_image.png');
                                    // await file.writeAsBytes(result.getBytes());
                                    img.encodeJpg(image);
                                  },
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.0),
                                    child: Text(
                                      'Selesai',
                                      style:
                                          TextStyle(color: kHyppeTextPrimary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Container(
                        height: 100,
                        margin: const EdgeInsets.only(bottom: 32),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: notifier.filters.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                notifier.activeFilter = index;
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      notifier.filters[index].name,
                                      style: const TextStyle(
                                          color: kHyppeTextPrimary),
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
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
