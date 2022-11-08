import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/preview_content/widget/preview_video_content.dart';

import '../../../../constant/widget/custom_loading.dart';

class BuildAnyContentPreviewer extends StatelessWidget {
  final GlobalKey? globalKey;
  final PageController pageController;

  const BuildAnyContentPreviewer({Key? key, this.globalKey, required this.pageController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreviewContentNotifier>(context);
    return RepaintBoundary(
      key: globalKey,
      child: Stack(
        children: [
          PageView.builder(
            onPageChanged: (v) => notifier.indexView = v,
            controller: pageController,
            physics: notifier.addTextItemMode ? const NeverScrollableScrollPhysics() : null,
            itemCount: notifier.fileContent?.length,
            itemBuilder: (context, index) {
              final _isImage = System().lookupContentMimeType(notifier.fileContent?[index] ?? '')?.contains('image');

              if ((_isImage ?? false) || _isImage == null) {
                return InteractiveViewer(
                  child: ColorFiltered(
                    colorFilter: ColorFilter.matrix(notifier.filterMatrix(index)),
                    child: !System().validateUrl(notifier.fileContent?[index] ?? '')
                        ? Image.file(
                            File(notifier.fileContent?[index] ?? ''),
                            filterQuality: FilterQuality.high,
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
                          )
                        : Image.network(
                            notifier.fileContent?[index] ?? '',
                            filterQuality: FilterQuality.high,
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
                          ),
                  ),
                  onInteractionEnd: (details) {
                    notifier.transformationController.value = Matrix4.identity();
                  },
                  transformationController: notifier.transformationController,
                );
              }
              notifier.toDiaryVideoPlayer(index, SourceFile.local);
              return PreviewVideoContent();

            },
          ),
          for (int index = 0; index < notifier.additionalItem.length; index++) ...[
            Positioned(
              top: notifier.positions[index].dy,
              left: notifier.positions[index].dx,
              child: Draggable<Widget>(
                maxSimultaneousDrags: 1,
                data: notifier.additionalItem[index],
                childWhenDragging: const SizedBox.shrink(),
                child: notifier.additionalItem[index],
                feedback: notifier.additionalItem[index],
                onDragStarted: () => notifier.onDragStarted(index),
                onDragEnd: (details) => notifier.setPositions(index, details.offset),
              ),
            ),
          ],
          if (notifier.isDraggingItem)
            Align(
              alignment: const Alignment(0.0, 0.7),
              child: AnimatedContainer(
                curve: Curves.bounceOut,
                width: notifier.sizeDragTarget,
                height: notifier.sizeDragTarget,
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: notifier.dragTargetColor,
                  border: Border.all(color: Colors.white),
                ),
                child: DragTarget<Widget>(
                  onWillAccept: (_) {
                    notifier.setOnWillAccept();
                    return true;
                  },
                  onLeave: (_) => notifier.setOnLeave(),
                  onAccept: (_) => notifier.removeAdditionalItem(),
                  builder: (_, __, ___) => const Icon(Icons.remove_circle, size: 50, color: Colors.white),
                ),
              ),
            )
        ],
      ),
    );
  }
}
