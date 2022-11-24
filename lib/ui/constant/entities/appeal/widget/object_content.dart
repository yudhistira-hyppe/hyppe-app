import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:provider/provider.dart';

class OnjectContentWidget extends StatelessWidget {
  final ContentData data;
  final String cat;
  const OnjectContentWidget({Key? key, required this.data, this.cat = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Provider.of<TranslateNotifierV2>(context, listen: false).translate;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translate.videoDetails ?? '',
                  style: Theme.of(context).primaryTextTheme.bodyText2,
                  textAlign: TextAlign.start,
                ),
                sixPx,
                Text(
                  "${translate.postedOn} ${System().dateFormatter(data.createdAt ?? '', 2)}",
                  style: Theme.of(context).textTheme.bodyText2,
                  textAlign: TextAlign.start,
                ),
              ],
            )),
            const SizedBox(width: 10),
            CustomCacheImage(
              imageUrl: data.isApsara ?? false ? data.mediaThumbEndPoint : data.fullThumbPath,
              imageBuilder: (_, imageProvider) {
                return Container(
                  width: 48 * SizeConfig.scaleDiagonal,
                  height: 48 * SizeConfig.scaleDiagonal,
                  alignment: Alignment.topRight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                );
              },
              errorWidget: (_, __, ___) {
                return Container(
                  width: 48 * SizeConfig.scaleDiagonal,
                  height: 48 * SizeConfig.scaleDiagonal,
                  alignment: Alignment.topRight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    image: const DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage('${AssetPath.pngPath}content-error.png'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        thirtySixPx,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              translate.categories ?? '',
              style: Theme.of(context).primaryTextTheme.bodyText2,
              textAlign: TextAlign.start,
            ),
            Text(
              cat,
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.start,
            ),
          ],
        ),
        twentyPx,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              translate.violationType ?? '',
              style: Theme.of(context).primaryTextTheme.bodyText2,
              textAlign: TextAlign.start,
            ),
            Text(
              "Adult nudity and sexual activity",
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.start,
              maxLines: 2,
            ),
          ],
        ),
      ],
    );
  }
}
