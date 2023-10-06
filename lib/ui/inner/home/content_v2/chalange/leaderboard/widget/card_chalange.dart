import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/chalange/challange_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

class CardChalange extends StatelessWidget {
  final ChallangeModel? data;
  final String? dateText;
  final bool last;
  const CardChalange({super.key, this.data, this.dateText, this.last = false});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id', null);
    TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();

    return GestureDetector(
      onTap: () {
        context.read<ChallangeNotifier>().leaderBoardDetailData = null;
        Routing().move(Routes.chalengeDetail, argument: GeneralArgument(id: data?.sId));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 257,
            margin: EdgeInsets.only(left: 16, right: last ? 16 : 0),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Color(0xFFFCFCFC),
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 0.38, color: kHyppeBorderTab),
                borderRadius: BorderRadius.circular(12),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 15,
                  offset: Offset(0.75, 0.75),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 257.25,
                  height: 77.25,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: CustomCacheImage(
                    imageUrl: data?.searchBanner ?? '',
                    imageBuilder: (_, imageProvider) {
                      return Container(
                        alignment: Alignment.topRight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                        ),
                      );
                    },
                    errorWidget: (_, __, ___) {
                      return Container(
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
                    emptyWidget: Container(
                      alignment: Alignment.topRight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        image: const DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage('${AssetPath.pngPath}content-error.png'),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: ShapeDecoration(
                              color: data?.statusFormalChallenge == 'Berlangsung' ? kHyppeSoftYellow : kHyppeGreenLight,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                            ),
                            child: Text(
                              data?.statusFormalChallenge == 'Berlangsung' ? "${tn.translate.goingOn}" : "${tn.translate.comingSoon}",
                              style: TextStyle(
                                color: data?.statusFormalChallenge == 'Berlangsung' ? const Color(0xFFB74D00) : kHyppeGreen,
                                fontSize: 10,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          sixPx,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: data?.statusJoined == 'Bukan Partisipan' ? kHyppeNotConnect : kHyppePrimaryTransparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                            ),
                            child: Text(
                              data?.statusJoined == 'Bukan Partisipan' ? "${tn.translate.nonParticipant}" : "${tn.translate.participant}",
                              style: TextStyle(
                                color: data?.statusJoined == 'Bukan Partisipan' ? Color(0xFF9B9B9B) : kHyppePrimary,
                                fontSize: 10,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      SizedBox(
                        child: Text(
                          "${data?.nameChallenge}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Color(0xFF3E3E3E),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 234.38,
                              child: Text(
                                '${System().dateFormatter(data?.startChallenge ?? "2023-01-01", 8, lang: tn.translate.localeDatetime ?? '')} s/d ${System().dateFormatter(data?.endChallenge ?? "2023-01-01", 7, lang: tn.translate.localeDatetime ?? '')} ',
                                style: const TextStyle(
                                  color: Color(0xFF9B9B9B),
                                  fontSize: 10,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 9),
                      Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 234.38,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const CustomIconWidget(
                                    iconData: "${AssetPath.vectorPath}clock.svg",
                                    defaultColor: false,
                                  ),
                                  sixPx,
                                  Container(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          child: Text(
                                            dateText ?? '',
                                            style: TextStyle(
                                              color: Color(0xFF3E3E3E),
                                              fontSize: 10,
                                              fontFamily: 'Lato',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
