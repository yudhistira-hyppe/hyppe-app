import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/inner/home/content_v2/tutor_landing/notifier.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/size_config.dart';
import '../../../../../../core/models/collection/posts/content_v2/content_data.dart';
import '../../../../../constant/widget/custom_icon_widget.dart';

class PicTopItem extends StatefulWidget {
  final GlobalKey? globalKey;
  final ContentData? data;
  final bool? isShow;
  final FlutterAliplayer? fAliplayer;
  final String? postId;

  const PicTopItem({Key? key, this.data, this.globalKey, this.isShow, this.fAliplayer, this.postId}) : super(key: key);

  @override
  State<PicTopItem> createState() => _PicTopItemState();
}

class _PicTopItemState extends State<PicTopItem> {
  GlobalKey keyOwn = GlobalKey();
  MainNotifier? mn;
  LocalizationModelV2? lang;
  int indexKeySell = 0;
  int indexKeyProtection = 0;

  @override
  void initState() {
    super.initState();
    // final newUser = SharedPreference().readStorage(SpKeys.newUser) ?? '';
    mn = Provider.of<MainNotifier>(context, listen: false);
    lang = Provider.of<TranslateNotifierV2>(context, listen: false).translate;
    if (mn?.tutorialData.isNotEmpty ?? [].isEmpty && !globalChallengePopUp) {
      indexKeySell = mn?.tutorialData.indexWhere((element) => element.key == 'sell') ?? 0;
      indexKeyProtection = mn?.tutorialData.indexWhere((element) => element.key == 'protection') ?? 0;
    }
  }

  void show() {
    ShowCaseWidget.of(context).startShowCase([widget.globalKey ?? GlobalKey()]);
  }

  @override
  void didUpdateWidget(covariant PicTopItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // if (widget.isShow == true && widget.postId == widget.data?.postID) {
    //   Future.delayed(const Duration(milliseconds: 200), () {
    //     GlobalKey key = widget.globalKey ?? GlobalKey();
    //     if ((widget.data?.saleAmount ?? 0) > 0) {
    //       if (key == widget.data?.keyGlobal) {
    //         if (widget.data?.fAliplayer != null) {
    //           widget.data?.fAliplayer?.pause();
    //         }
    //         // ShowCaseWidget.of(context).startShowCase([widget.globalKey ?? GlobalKey()]);
    //       }
    //     }
    //     if (((widget.data?.certified ?? false) && (widget.data?.saleAmount ?? 0) == 0) && mn?.tutorialData[indexKeyProtection].status == false) {
    //       if (key == widget.data?.keyGlobal) {
    //         if (widget.data?.fAliplayer != null) {
    //           widget.data?.fAliplayer?.pause();
    //         }
    //         // ShowCaseWidget.of(context).startShowCase([widget.globalKey ?? GlobalKey()]);
    //       }
    //     }
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'PicTopItem');
    SizeConfig().init(context);
    return VisibilityDetector(
      key: Key(widget.postId ?? indexKeySell.toString()),
      onVisibilityChanged: (VisibilityInfo info) {
        if ((widget.data?.saleAmount ?? 0) > 0 || ((widget.data?.certified ?? false) && (widget.data?.saleAmount ?? 0) == 0)) {
          if (info.visibleFraction < 0.5) {
            if (globalTultipShow) {
              closeTooltip(indexKeySell);
            }
          }
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if ((widget.data?.saleAmount ?? 0) > 0)
            Showcase(
              key: widget.globalKey ?? GlobalKey(),
              tooltipBackgroundColor: kHyppeTextLightPrimary,
              overlayOpacity: 0,
              targetPadding: const EdgeInsets.all(0),
              tooltipPosition: TooltipPosition.top,
              description: (mn?.tutorialData.isEmpty ?? [].isEmpty)
                  ? lang?.localeDatetime == 'id'
                      ? 'Temukan ikon ini pada konten dan beli karya digital dari kreator favoritmu dengan mengetuk ikon keranjang!'
                      : 'Find this icon on content and purchase digital works from your favorite creators by tapping the cart!'
                  : lang?.localeDatetime == 'id'
                      ? mn?.tutorialData[indexKeySell].textID ?? ''
                      : mn?.tutorialData[indexKeySell].textEn ?? '',
              descTextStyle: const TextStyle(fontSize: 10, color: kHyppeNotConnect),
              descriptionPadding: const EdgeInsets.all(6),
              textColor: Colors.white,
              targetShapeBorder: const CircleBorder(),
              positionYplus: 25,
              onToolTipClick: () {
                closeTooltip(indexKeySell);
              },
              closeWidget: GestureDetector(
                onTap: () {
                  closeTooltip(indexKeySell);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CustomIconWidget(
                    iconData: '${AssetPath.vectorPath}close.svg',
                    defaultColor: false,
                    height: 16,
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  if (widget.globalKey != null) {
                    if (widget.fAliplayer != null) {
                      widget.fAliplayer?.pause();
                    }
                    globalTultipShow = true;
                    show();
                  }
                },
                child: const CustomIconWidget(
                  iconData: '${AssetPath.vectorPath}sale.svg',
                  defaultColor: false,
                  height: 24,
                ),
              ),
            ),
          // Center(child: Text("${mn?.tutorialData}")),
          if ((widget.data?.certified ?? false) && (widget.data?.saleAmount ?? 0) == 0)
            Showcase(
              key: widget.globalKey ?? GlobalKey(),
              tooltipBackgroundColor: kHyppeTextLightPrimary,
              overlayOpacity: 0,
              targetPadding: const EdgeInsets.all(0),
              tooltipPosition: TooltipPosition.top,
              description: (mn?.tutorialData.isEmpty ?? [].isEmpty)
                  ? lang?.localeDatetime == 'id'
                      ? 'Konten dengan ikon ini menunjukkan konten telah memiliki hak kepemilikan yang di lindungi oleh Hyppe!'
                      : 'The icon shows that the content has been registered for ownership and is protected by Hyppe.'
                  : lang?.localeDatetime == 'id'
                      ? mn?.tutorialData[indexKeyProtection].textID ?? ''
                      : mn?.tutorialData[indexKeyProtection].textEn ?? '',
              descTextStyle: TextStyle(fontSize: 10, color: kHyppeNotConnect),
              descriptionPadding: EdgeInsets.all(6),
              textColor: Colors.white,
              positionYplus: 25,
              onToolTipClick: () {
                closeTooltip(indexKeyProtection);
              },
              closeWidget: GestureDetector(
                onTap: () {
                  closeTooltip(indexKeyProtection);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CustomIconWidget(
                    iconData: '${AssetPath.vectorPath}close.svg',
                    defaultColor: false,
                    height: 16,
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  if (widget.globalKey != null) {
                    if (widget.fAliplayer != null) {
                      widget.fAliplayer?.pause();
                    }
                    globalTultipShow = true;
                    show();
                  }
                },
                child: const CustomIconWidget(
                  iconData: '${AssetPath.vectorPath}ownership.svg',
                  defaultColor: false,
                  height: 24,
                ),
              ),
            )
        ],
      ),
    );
  }

  void closeTooltip(int index) {
    globalTultipShow = false;
    ShowCaseWidget.of(context).dismiss();
    mn?.tutorialData[index].status = true;
    context.read<TutorNotifier>().postTutor(context, mn?.tutorialData[index].key ?? '');
    if (widget.fAliplayer != null) {
      widget.fAliplayer?.play();
    }
  }
}
