import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/asset_path.dart';
import '../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../../constant/widget/custom_icon_widget.dart';
import '../../../../constant/widget/custom_spacer.dart';
import '../../../../constant/widget/custom_text_widget.dart';
import '../../../../constant/widget/icon_button_widget.dart';
import 'music_status_selected_widget.dart';

class PreviewImageContent extends StatefulWidget {
  final bool validateUrl;
  final int currIndex;
  const PreviewImageContent({Key? key, required this.validateUrl, required this.currIndex}) : super(key: key);

  @override
  State<PreviewImageContent> createState() => _PreviewImageContentState();
}

class _PreviewImageContentState extends State<PreviewImageContent> with AfterFirstLayoutMixin {

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreviewContentNotifier>(context);

    return !widget.validateUrl
        ? Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
              child: notifier.featureType == FeatureType.pic
              ? Image.memory(
                  File(notifier.fileContent?[widget.currIndex] ?? '').readAsBytesSync(),
                )
              : Image.file(
                 File(notifier.fileContent?[widget.currIndex] ?? ''),
                  filterQuality: FilterQuality.high,
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
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
            if (notifier.fixSelectedMusic != null)
              Positioned(
                top: notifier.featureType == FeatureType.story ||
                    notifier.featureType == FeatureType.diary ? 16 : 96,
                left: 52,
                child: MusicStatusSelected(
                  music: notifier.fixSelectedMusic!,
                  onClose: () {
                    notifier.setDefaultVideo(context);
                  },
                ),
              ),
              for (var i = 0; i < notifier.onScreenStickers.length; i++) notifier.onScreenStickers[i],
              Visibility(
                visible: notifier.isDragging,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 86,
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomIconWidget(
                          defaultColor: false,
                          color: notifier.isDeleteButtonActive ? Colors.red : null,
                          iconData: "${AssetPath.vectorPath}circle_delete.svg",
                        ),
                        const SizedBox(height: 4),
                        CustomTextWidget(
                          textToDisplay: notifier.language.delete ?? 'delete',
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!notifier.isDragging)
                Positioned(
                  right: 16,
                  bottom: context.getHeight() * 0.4,
                  child: Column(
                    children: [
                      // Column(
                      //   children: [
                      //     Container(
                      //       height: 48,
                      //       width: 48,
                      //       decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(24)), color: Colors.black.withOpacity(0.5)),
                      //       child: CustomIconButtonWidget(
                      //         onPressed: () async {
                      //           notifier.openImageCropper(context, widget.currIndex);
                      //         },
                      //         iconData: "${AssetPath.vectorPath}edit.svg",
                      //       ),
                      //     ),
                      //     eightPx,
                      //     CustomTextWidget(
                      //       textToDisplay: notifier.language.edit ?? 'Rotate',
                      //       textStyle: const TextStyle(
                      //         fontWeight: FontWeight.normal,
                      //         color: Colors.white,
                      //         fontSize: 14,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // twentyFourPx,
                      InkWell(
                        onTap: () async {
                          notifier.audioPreviewPlayer.pause();
                          final tempMusic = notifier.fixSelectedMusic;
                          notifier.fixSelectedMusic = null;
                          await ShowBottomSheet.onChooseMusic(context, isPic: true, isInit: false);
                          notifier.fixSelectedMusic ??= tempMusic;
                          // notifier.audioPreviewPlayer.resume();
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CustomIconWidget(
                              defaultColor: false,
                              iconData: "${AssetPath.vectorPath}circle_music.svg",
                            ),
                            fourPx,
                            CustomTextWidget(
                              maxLines: 1,
                              textToDisplay: notifier.language.music ?? '',
                              textAlign: TextAlign.left,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (notifier.featureType == FeatureType.pic) twentyFourPx,
                      if (notifier.featureType == FeatureType.pic)
                        InkWell(
                          onTap: () async {
                            Routing().move(Routes.editPhoto);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CustomIconWidget(
                                defaultColor: false,
                                iconData: "${AssetPath.vectorPath}edit-v2.svg",
                              ),
                              fourPx,
                              CustomTextWidget(
                                maxLines: 1,
                                textToDisplay: notifier.language.edit ?? '',
                                textAlign: TextAlign.left,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      twentyFourPx,
                      if (notifier.featureType == FeatureType.story || notifier.featureType == FeatureType.diary)
                      InkWell(
                        onTap: () async {
                          notifier.initStickerScroll(context);
                          notifier.stickerScrollPosition = 0.0;
                          ShowBottomSheet.onShowSticker(context: context, whenComplete: () {
                            notifier.removeStickerScroll(context);
                            notifier.stickerSearchActive = false;
                            notifier.stickerSearchText = '';
                            notifier.stickerTextController.text = '';
                          });
                          notifier.getSticker(context, index: notifier.stickerTabIndex);
                        },
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              defaultColor: false,
                              iconData: "${AssetPath.vectorPath}circle_sticker.svg",
                            ),
                            fourPx,
                            CustomTextWidget(
                              maxLines: 1,
                              textToDisplay: 'Stiker',
                              textAlign: TextAlign.left,
                              textStyle:  TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
          ],
        )
        : Image.network(
            notifier.fileContent?[widget.currIndex] ?? '',
            filterQuality: FilterQuality.high,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) {
                return child;
              }
              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOut,
                      child: child,
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: context.getHeight() * 0.4,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(24)), color: Colors.black.withOpacity(0.5)),
                              child: CustomIconButtonWidget(
                                onPressed: () async {
                                  try {
                                    final pathFile = notifier.fileContent?[widget.currIndex];
                                    if (pathFile != null) {
                                      final newFile = await ImageCropper().cropImage(
                                        sourcePath: pathFile,
                                        compressFormat: ImageCompressFormat.jpg,
                                        compressQuality: 100,
                                        aspectRatioPresets: [
                                          CropAspectRatioPreset.square,
                                          CropAspectRatioPreset.ratio3x2,
                                          CropAspectRatioPreset.original,
                                          CropAspectRatioPreset.ratio4x3,
                                          // CropAspectRatioPreset.ratio16x9
                                        ],
                                        uiSettings: [
                                          AndroidUiSettings(
                                            toolbarTitle: notifier.language.editImage,
                                            toolbarColor: kHyppePrimary,
                                            toolbarWidgetColor: Colors.white,
                                            initAspectRatio: CropAspectRatioPreset.original,
                                            lockAspectRatio: true,
                                            showCropGrid: true,
                                          ),
                                          IOSUiSettings(
                                            title: notifier.language.editImage,
                                          ),
                                          WebUiSettings(
                                            context: context,
                                            presentStyle: CropperPresentStyle.page,
                                            // boundary: const CroppieBoundary(
                                            //   width: 520,
                                            //   height: 520,
                                            // ),
                                            // viewPort:
                                            // const CroppieViewPort(width: 480, height: 480, type: 'circle'),
                                            enableExif: true,
                                            enableZoom: true,
                                            showZoomer: true,
                                          ),
                                        ],
                                      );
                                      if (newFile != null) {
                                        await File(pathFile).delete();
                                        notifier.setFileContent(newFile.path, widget.currIndex);
                                      } else {
                                        throw 'file result is null';
                                      }
                                    } else {
                                      throw 'file is null';
                                    }
                                  } catch (e) {
                                    // ShowBottomSheet().onShowColouredSheet(context, e.toString(), color: kHyppeDanger, maxLines: 2);
                                  }
                                },
                                iconData: "${AssetPath.vectorPath}edit.svg",
                              ),
                            ),
                            eightPx,
                            CustomTextWidget(
                              textToDisplay: notifier.language.edit ?? 'Rotate',
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        twentyFourPx,
                        InkWell(
                          onTap: () async {
                            notifier.audioPreviewPlayer.pause();
                            final tempMusic = notifier.fixSelectedMusic;
                            notifier.fixSelectedMusic = null;
                            await ShowBottomSheet.onChooseMusic(context, isPic: true, isInit: false);
                            notifier.fixSelectedMusic ??= tempMusic;
                            // notifier.audioPreviewPlayer.resume();
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CustomIconWidget(
                                defaultColor: false,
                                iconData: "${AssetPath.vectorPath}circle_music.svg",
                              ),
                              fourPx,
                              CustomTextWidget(
                                  maxLines: 1,
                                  textToDisplay: notifier.language.music ?? '',
                                  textAlign: TextAlign.left,
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  // if (notifier.fixSelectedMusic != null)
                  //   Positioned(
                  //     top: _y == 0 ? (context.getHeight() / 2) : _y,
                  //     left: _x == 0 ? (context.getWidth() * 0.1) : _x,
                  //     child: Draggable(
                  //       childWhenDragging: const SizedBox.shrink(),
                  //       feedback: MusicStatusSelected(
                  //         music: notifier.fixSelectedMusic!,
                  //         onClose: () {
                  //           notifier.setDefaultVideo(context);
                  //         },
                  //         isDrag: true,
                  //         isPlay: false,
                  //       ),
                  //       child: MusicStatusSelected(
                  //         music: notifier.fixSelectedMusic!,
                  //         onClose: () {
                  //           notifier.setDefaultVideo(context);
                  //         },
                  //       ),
                  //       onDragEnd: (dragDetail) {
                  //         setState(() {
                  //           _x = dragDetail.offset.dx;
                  //           _y = dragDetail.offset.dy;
                  //         });
                  //       },
                  //     ),
                  //   ),
                ],
              );
            },
          );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = context.read<PreviewContentNotifier>();
    notifier.currentMusic = null;
    notifier.selectedMusic = null;
    notifier.selectedType = null;
    notifier.fixSelectedMusic = null;
  }
}
