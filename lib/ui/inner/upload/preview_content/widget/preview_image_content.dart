import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
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

class _PreviewImageContentState extends State<PreviewImageContent> with AfterFirstLayoutMixin{



  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreviewContentNotifier>(context);

    return InteractiveViewer(
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(notifier.filterMatrix(widget.currIndex)),
        child: !widget.validateUrl
            ? Image.file(
          File(notifier.fileContent?[widget.currIndex] ?? ''),
          filterQuality: FilterQuality.high,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            // if (wasSynchronouslyLoaded) {
            //   return child;
            // }
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: wasSynchronouslyLoaded ? child : AnimatedOpacity(
                    child: child,
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOut,
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
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(24)),
                                color: Colors.black.withOpacity(0.5)
                            ),
                            child: CustomIconButtonWidget(
                              onPressed: () async{
                                try{
                                  final pathFile = notifier.fileContent?[widget.currIndex];
                                  if(pathFile != null){
                                    final newFile = await ImageCropper().cropImage(
                                      sourcePath: pathFile,
                                      compressFormat: ImageCompressFormat.jpg,
                                      compressQuality: 100,
                                      uiSettings: [
                                        AndroidUiSettings(
                                            toolbarTitle: notifier.language.editImage,
                                            toolbarColor: kHyppePrimary,
                                            toolbarWidgetColor: Colors.white,
                                            initAspectRatio: CropAspectRatioPreset.original,
                                            lockAspectRatio: false),
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
                                    if(newFile != null){
                                      await File(pathFile).delete();
                                      notifier.setFileContent(newFile.path, widget.currIndex);
                                    }else{
                                      throw 'file result is null';
                                    }
                                  }else{
                                    throw 'file is null';
                                  }
                                }catch(e){
                                  print('Error ImageCropper: $e');
                                  // ShowBottomSheet().onShowColouredSheet(context, e.toString(), color: kHyppeDanger, maxLines: 2);
                                }

                              },
                              iconData: "${AssetPath.vectorPath}edit.svg",
                            ),
                          ),
                          eightPx,
                          CustomTextWidget(textToDisplay: notifier.language.edit ?? 'Rotate', textStyle: const TextStyle(fontWeight: FontWeight.normal, color: Colors.white, fontSize: 14, ))
                        ],
                      ),
                      twentyFourPx,
                      InkWell(
                        onTap: (){
                          ShowBottomSheet.onChooseMusic(context, isPic: true, isInit: false);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CustomIconWidget(
                              defaultColor: false,
                              iconData: "${AssetPath.vectorPath}circle_music.svg",
                            ),
                            fourPx,
                            CustomTextWidget(maxLines: 1, textToDisplay: notifier.language.music ?? '', textAlign: TextAlign.left, textStyle: const TextStyle(fontWeight: FontWeight.normal, color: Colors.white, fontSize: 14, ))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                if (notifier.fixSelectedMusic != null)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: MusicStatusSelected(music: notifier.fixSelectedMusic!, onClose: (){
                        notifier.setDefaultVideo(context);
                      },),
                    ),
                  ),
              ],
            );
          },
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
                    child: child,
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOut,
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
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(24)),
                                color: Colors.black.withOpacity(0.5)
                            ),
                            child: CustomIconButtonWidget(
                              onPressed: () async{
                                try{
                                  final pathFile = notifier.fileContent?[widget.currIndex];
                                  if(pathFile != null){
                                    final newFile = await ImageCropper().cropImage(
                                      sourcePath: pathFile,
                                      compressFormat: ImageCompressFormat.jpg,
                                      compressQuality: 100,
                                      uiSettings: [
                                        AndroidUiSettings(
                                            toolbarTitle: notifier.language.editImage,
                                            toolbarColor: kHyppePrimary,
                                            toolbarWidgetColor: Colors.white,
                                            initAspectRatio: CropAspectRatioPreset.original,
                                            lockAspectRatio: false),
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
                                    if(newFile != null){
                                      await File(pathFile).delete();
                                      notifier.setFileContent(newFile.path, widget.currIndex);
                                    }else{
                                      throw 'file result is null';
                                    }
                                  }else{
                                    throw 'file is null';
                                  }
                                }catch(e){
                                  print('Error ImageCropper: $e');
                                  // ShowBottomSheet().onShowColouredSheet(context, e.toString(), color: kHyppeDanger, maxLines: 2);
                                }

                              },
                              iconData: "${AssetPath.vectorPath}edit.svg",
                            ),
                          ),
                          eightPx,
                          CustomTextWidget(textToDisplay: notifier.language.edit ?? 'Rotate', textStyle: const TextStyle(fontWeight: FontWeight.normal, color: Colors.white, fontSize: 14, ))
                        ],
                      ),
                      twentyFourPx,
                      InkWell(
                        onTap: (){
                          ShowBottomSheet.onChooseMusic(context, isPic: true, isInit: false);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CustomIconWidget(
                              defaultColor: false,
                              iconData: "${AssetPath.vectorPath}circle_music.svg",
                            ),
                            fourPx,
                            CustomTextWidget(maxLines: 1, textToDisplay: notifier.language.music ?? '', textAlign: TextAlign.left, textStyle: const TextStyle(fontWeight: FontWeight.normal, color: Colors.white, fontSize: 14, ))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                if (notifier.fixSelectedMusic != null)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: MusicStatusSelected(music: notifier.fixSelectedMusic!, onClose: (){
                        notifier.setDefaultVideo(context);
                      },),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      onInteractionEnd: (details) {
        notifier.transformationController.value = Matrix4.identity();
      },
      transformationController: notifier.transformationController,
    );
  }

  @override
  void initState() {
    super.initState();
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
