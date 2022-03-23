import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/image_preview_argument.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';

class ImagePreviewView extends StatelessWidget {
  final ImagePreviewArgument argument;

  ImagePreviewView({
    Key? key,
    required this.argument,
  }) : super(key: key);

  final ValueNotifier<TransformationController> controller = ValueNotifier(TransformationController());

  void resetController() {
    if (controller.value.value != Matrix4.identity()) {
      controller.value.value = Matrix4.identity();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onDoubleTap: () => resetController(),
      child: Scaffold(
        body: Center(
          child: ValueListenableBuilder<TransformationController>(
            valueListenable: controller,
            builder: (_, value, __) {
              return InteractiveViewer(
                transformationController: value,
                child: Hero(
                  tag: argument.heroTag,
                  child: CustomCacheImage(
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        width: size.width,
                        height: size.height * 0.5,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            image: imageProvider,
                          ),
                        ),
                      );
                    },
                    imageUrl: argument.sourceImage,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
