import 'package:flutter/material.dart';

import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';

import 'package:hyppe/core/arguments/image_preview_argument.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';

import '../../../../../core/constants/asset_path.dart';

class ContentMessageLayout extends StatelessWidget {
  final DisqusLogs? message;

  const ContentMessageLayout({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: message.hashCode,
      child: InkWell(
        onTap: () {
          Routing().move(
            Routes.imagePreviewScreen,
            argument: ImagePreviewArgument(
              heroTag: message.hashCode,
              sourceImage: message?.content.first.fullThumbPath ?? '',
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomCacheImage(
            imageBuilder: (context, imageProvider) {
              return Container(
                height: 226,
                width: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
            imageUrl: message?.content.first.fullThumbPath,
            emptyWidget: Container(
            height: 50,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.contain,
                image: AssetImage('${AssetPath.pngPath}content-error.png'),
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}
