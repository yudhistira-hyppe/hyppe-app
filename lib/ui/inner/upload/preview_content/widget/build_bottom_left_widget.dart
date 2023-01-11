import 'dart:io';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildBottomLeftWidget extends StatefulWidget {
  final PageController pageController;
  const BuildBottomLeftWidget({Key? key, required this.pageController}) : super(key: key);

  @override
  State<BuildBottomLeftWidget> createState() => _BuildBottomLeftWidgetState();
}

class _BuildBottomLeftWidgetState extends State<BuildBottomLeftWidget> {
  @override
  void initState() {
    final notifier = Provider.of<PreviewContentNotifier>(context, listen: false);
    Future.delayed(Duration.zero, () {
      print('banyak kontent ${notifier.fileContent?.length}');
      for (var i = 0; i < (notifier.fileContent?.length ?? 0); i++) {
        notifier.makeThumbnail(materialAppKey.currentContext!, i);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Consumer<PreviewContentNotifier>(
        builder: (context, notifier, child) {
          if (notifier.addTextItemMode) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: SizeConfig.screenWidth,
                  height: 80.0 * SizeConfig.scaleDiagonal,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: notifier.fileContent?.length,
                    itemBuilder: (context, index) {
                      final _isImage = System().lookupContentMimeType(notifier.fileContent?[index] ?? '')?.contains('image');

                      return GestureDetector(
                          child: Container(
                            width: 80.0 * SizeConfig.scaleDiagonal,
                            height: 80.0 * SizeConfig.scaleDiagonal,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(color: const Color(0xff822E6E), width: notifier.indexView == index ? 2.0 : 0.0),
                              color: Theme.of(context).backgroundColor,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: ((_isImage ?? false) || _isImage == null)
                                  ? ColorFiltered(
                                      colorFilter: ColorFilter.matrix(notifier.filterMatrix(index)),
                                      child: Image.file(
                                        File(notifier.fileContent?[index] ?? ''),
                                        fit: BoxFit.cover,
                                        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                          if (wasSynchronouslyLoaded) {
                                            return child;
                                          }
                                          return AnimatedOpacity(
                                            child: child,
                                            opacity: frame == null ? 0 : 1,
                                            duration: const Duration(seconds: 1),
                                            curve: Curves.easeOut,
                                          );
                                        },
                                        filterQuality: FilterQuality.high,
                                      ),
                                    )
                                  : notifier.thumbNails != null && (notifier.thumbNails?.isNotEmpty ?? false) && notifier.thumbNails?[index] != null
                                      ? Image.memory(
                                          notifier.thumbNails![index]!,
                                          fit: BoxFit.cover, // '${AssetPath.pngPath}content-error.png'
                                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                            if (wasSynchronouslyLoaded) {
                                              return child;
                                            }
                                            return AnimatedOpacity(
                                              child: child,
                                              opacity: frame == null ? 0 : 1,
                                              duration: const Duration(seconds: 1),
                                              curve: Curves.easeOut,
                                            );
                                          },
                                          filterQuality: FilterQuality.high,
                                        )
                                      : Icon(
                                          Icons.warning_amber_rounded,
                                          size: 40.0 * SizeConfig.scaleDiagonal,
                                          color: Theme.of(context).colorScheme.primaryVariant,
                                        ),
                            ),
                          ),
                          onTap: () => notifier.animateToPage(index, widget.pageController));
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
}
