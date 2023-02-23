import 'package:flutter/material.dart';
import 'package:hyppe/core/services/system.dart';

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
          DateTime now = DateTime.now();
          // DateTime now = DateTime.parse('2023-02-21 15:11:14');
          DateTime imageDate = DateTime.parse(message?.medias.first.createdAt ?? '2020-01-01');
          var jumlahHari = System().menghitungJumlahHari(imageDate, now);
          print(imageDate);
          print(now);
          print('jumlah hari $jumlahHari');
          if (jumlahHari < 1) {
            Routing().move(
              Routes.imagePreviewScreen,
              argument: ImagePreviewArgument(
                heroTag: message.hashCode,
                sourceImage: message?.medias.first.mediaThumbEndpoint ?? '',
              ),
            );
          }
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
            imageUrl: (message?.medias.first.apsara ?? false) ? message?.medias.first.mediaThumbEndpoint ?? '' : System().showUserPicture(message?.medias.first.mediaThumbEndpoint),
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
