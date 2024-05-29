import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BoostCardWidget extends StatelessWidget {
  final ContentData? data;
  final LocalizationModelV2? language;
  const BoostCardWidget({Key? key, this.data, this.language}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'CardBoost');
    initializeDateFormatting('id', null);
    Color? statusColor;
    switch (data?.statusBoost) {
      case 'BERLANGSUNG':
        statusColor = kHyppeLightAds;
        break;
      case 'AKAN DATANG':
        statusColor = kHyppeRed;
        break;
      default:
        statusColor = kHyppeGreen;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(right: 16, left: 16, top: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: .05),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextWidget(
                          textToDisplay:
                              System().convertTypeContent(data?.postType ?? ''),
                          textStyle:
                              Theme.of(context).primaryTextTheme.labelLarge,
                        ),
                        CustomTextWidget(
                          textToDisplay: DateFormat(
                                  'dd MMM yyyy', language?.localeDatetime)
                              .format(DateTime.parse(
                                  data?.boosted[0].boostDate ??
                                      DateTime.now().toString())),
                          textStyle:
                              Theme.of(context).primaryTextTheme.labelMedium,
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: statusColor.withOpacity(.1),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: CustomTextWidget(
                        textToDisplay: System()
                            .getStatusBoost(context, '${data?.statusBoost}'),
                        textStyle: TextStyle(
                            color: statusColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 6,
                thickness: .1,
              ),
              sixteenPx,
              Row(
                children: [
                  CustomCacheImage(
                    imageUrl: (data?.isApsara ?? false)
                        ? (data?.mediaThumbEndPoint ?? '')
                        : data?.fullThumbPath ?? '',
                    imageBuilder: (_, imageProvider) {
                      return Container(
                        height: MediaQuery.of(context).size.width / 4,
                        width: MediaQuery.of(context).size.width / 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      );
                    },
                    errorWidget: (_, __, ___) {
                      return Container(
                        height: 50,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            image: AssetImage(
                                '${AssetPath.pngPath}content-error.png'),
                          ),
                        ),
                      );
                    },
                    emptyWidget: Container(
                      height: 50,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage(
                              '${AssetPath.pngPath}content-error.png'),
                        ),
                      ),
                    ),
                  ),
                  sixteenPx,
                  Expanded(
                    flex: 10,
                    child: CustomTextWidget(
                      maxLines: 5,
                      textToDisplay: '${data?.description}',
                      textStyle: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
              sixteenPx,
              GestureDetector(
                onTap: () {
                  switch (data?.postType) {
                    case 'pict':
                      Routing().move(Routes.picDetail, argument: PicDetailScreenArgument(picData: data));
                      break;
                    case 'vid':
                      return context.read<PreviewVidNotifier>().navigateToHyppeVidDetail(context, data);
                    case 'diary':
                      List<ContentData> data1 = [];
                      data1.add(data!);
                      Routing().move(Routes.diaryDetail, argument: DiaryDetailScreenArgument(diaryData: data1, type: TypePlaylist.none));
                      break;
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: kHyppeGreyLight.withOpacity(.8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4.0)
                            ),
                            child: const CustomIconWidget(
                              iconData: "${AssetPath.vectorPath}reach.svg",
                              defaultColor: false,
                              color: Colors.white,
                            ),
                          ),
                          sixPx,
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 12),
                              children: [
                                TextSpan(
                                  text: '${data?.boostJangkauan ?? '0'}',
                                  style: const TextStyle(fontWeight: FontWeight.bold)
                                ),
                                TextSpan(
                                  text: ' ${language?.reach}'
                                )
                              ]
                            ),
                          ),
                          
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios_outlined, size: 16, color: kHyppePrimary,)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
