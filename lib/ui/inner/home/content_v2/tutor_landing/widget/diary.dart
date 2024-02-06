import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_newdesc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/widget/user_template.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import '../../../../../../ux/path.dart';
import '../../../../../constant/entities/report/notifier.dart';

class DiaryTutor extends StatefulWidget {
  final ScrollController? scrollController;
  final VoidCallback? onScaleStart;
  final VoidCallback? onScaleStop;
  final bool? appbarSeen;

  const DiaryTutor({
    Key? key,
    this.scrollController,
    this.onScaleStart,
    this.onScaleStop,
    this.appbarSeen,
  }) : super(key: key);

  @override
  _DiaryTutorState createState() => _DiaryTutorState();
}

class _DiaryTutorState extends State<DiaryTutor> with WidgetsBindingObserver, TickerProviderStateMixin, RouteAware {
  ScrollController innerScrollController = ScrollController();

  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;
  bool isloading = false;

  // int _curIdx = 0;
  // int _lastCurIndex = -1;
  // String _curPostId = '';
  // String _lastCurPostId = '';

  String auth = '';
  String url = '';
  // final Map _dataSourceMap = {};
  // ModeTypeAliPLayer? _playMode = ModeTypeAliPLayer.auth;
  LocalizationModelV2? lang;
  ContentData? dataSelected;
  bool isMute = true;
  String email = '';
  // String statusKyc = '';
  bool isInPage = true;
  // bool _scroolEnabled = true;
  double itemHeight = 0;
  ScrollController controller = ScrollController();
  ScrollPhysics scrollPhysic = const NeverScrollableScrollPhysics();
  double lastOffset = 0;
  bool scroolUp = false;

  List pictData = [
    {
      'user': 'nataliajesehat',
      'avatar': "${AssetPath.pngPath}tutorstory2.png",
      'image': "${AssetPath.pngPath}tutordiary.png",
      'desc': "Jalan-jalan ke luar negeri pake uang yang udah ditabung dari 10 tahun lalu. Healing ",
      'like': '500',
      'comments': '200'
    },
  ];

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'PicTutor');
    // final notifier = Provider.of<PreviewPicNotifier>(context, listen: false);
    lang = context.read<TranslateNotifierV2>().translate;
    // notifier.scrollController.addListener(() => notifier.scrollListener(context));
    email = SharedPreference().readStorage(SpKeys.email);
    // statusKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);
    // stopwatch = new Stopwatch()..start();
    lastOffset = -10;
    super.initState();
    // _primaryScrollController = widget.scrollController!;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      WidgetsBinding.instance.addObserver(this);
    });
    context.read<HomeNotifier>().removeWakelock();

    super.initState();
  }

  @override
  void dispose() {
    print("---=-=-=-=--===-=-=-=-DiSPOSE--=-=-=-=-=-=-=-=-=-=-=----==-=");

    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  // int _currentItem = 0;

  List heightItem = [600, 400, 400];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Consumer2<PreviewPicNotifier, HomeNotifier>(
      builder: (_, notifier, home, __) => Container(
        width: SizeConfig.screenWidth,
        height: SizeWidget.barHyppePic,
        // margin: const EdgeInsets.only(top: 16.0, bottom: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  print(overscroll);
                  overscroll.disallowIndicator();
                  return true;
                },
                child: NotificationListener<UserScrollNotification>(
                  onNotification: (notification) {
                    // final ScrollDirection direction = notification.direction;

                    return true;
                  },
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pictData.length,
                    padding: const EdgeInsets.symmetric(horizontal: 11.5),
                    itemBuilder: (context, index) {
                      return Visibility(
                        // visible: (_curIdx - 1) == index || _curIdx == index || (_curIdx + 1) == index,
                        visible: true,
                        child: itemPict(context, index),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final Map cacheDesc = {};

  Widget itemPict(BuildContext context, int index) {
    var picData = pictData[index];
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      picData?['avatar'],
                      height: 37,
                    ),
                  ),
                  twelvePx,
                  Expanded(
                    child: UserTemplate(
                      username: picData?['user'] ?? 'No Username',
                      isVerified: false,
                    ),
                  ),
                  const Icon(
                    Icons.more_vert,
                    color: kHyppeTextLightPrimary,
                  ),
                ],
              ),

              tenPx,
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                width: SizeConfig.screenWidth,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                  ),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Center(
                          child: Container(
                            color: Colors.transparent,
                            // height: picData?.imageHeightTemp == 0 ? null : picData?.imageHeightTemp,

                            // width: SizeConfig.screenWidth,
                            // height: picData?.imageHeightTemp,
                            child: Image.asset(
                              picData['image'],
                              fit: BoxFit.fitHeight,
                              width: SizeConfig.screenWidth,
                            ),
                          ),
                        ),
                      ),
                      // _buildBody(context, SizeConfig.screenWidth, picData ?? ContentData()),
                      // blurContentWidget(context, picData ?? ContentData()),
                    ],
                  ),
                ),
              ),
              Consumer<LikeNotifier>(
                builder: (context, likeNotifier, child) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: InkWell(
                              child: CustomIconWidget(
                                defaultColor: false,
                                color: kHyppeTextLightPrimary,
                                iconData: '${AssetPath.vectorPath}none-like.svg',
                                height: 28,
                              ),
                              onTap: () {
                                if (picData != null) {}
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 21.0),
                          child: GestureDetector(
                            onTap: () {
                              Routing().move(Routes.commentsDetail, argument: CommentsArgument(postID: picData?.postID ?? '', fromFront: true, data: picData ?? ContentData()));
                              // ShowBottomSheet.onShowCommentV2(context, postID: picData?.postID);
                            },
                            child: const CustomIconWidget(
                              defaultColor: false,
                              color: kHyppeTextLightPrimary,
                              iconData: '${AssetPath.vectorPath}comment2.svg',
                              height: 24,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.read<PicDetailNotifier>().createdDynamicLink(context, data: picData);
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 21.0),
                            child: CustomIconWidget(
                              defaultColor: false,
                              color: kHyppeTextLightPrimary,
                              iconData: '${AssetPath.vectorPath}share2.svg',
                              height: 24,
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await ShowBottomSheet.onBuyContent(
                                context,
                                data: picData,
                              );
                            },
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: CustomIconWidget(
                                defaultColor: false,
                                color: kHyppeTextLightPrimary,
                                iconData: '${AssetPath.vectorPath}cart.svg',
                                height: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    twelvePx,
                    Text(
                      "Like",
                      style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ],
                ),
              ),
              fourPx,
              CustomNewDescContent(
                // desc: "${data?.description}",
                email: picData?['email']??'',
                username: picData?['user'] ?? '',
                desc: "${picData?['desc']}",
                trimLines: 3,
                textAlign: TextAlign.start,
                seeLess: ' ${lang?.seeLess}', // ${notifier2.translate.seeLess}',
                seeMore: '  ${lang?.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
                normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
                hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary, fontSize: 12),
                expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),

              GestureDetector(
                onTap: () {
                  // Routing().move(Routes.commentsDetail, argument: CommentsArgument(postID: picData?.postID ?? '', fromFront: true, data: picData ?? ContentData()));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "${lang?.seeAll} ${picData['avatar']} ${lang?.comment}",
                    style: const TextStyle(fontSize: 12, color: kHyppeBurem),
                  ),
                ),
              ),
              // (picData?.comment?.length ?? 0) > 0
              //     ? Padding(
              //         padding: const EdgeInsets.only(top: 0.0),
              //         child: ListView.builder(
              //           shrinkWrap: true,
              //           physics: const NeverScrollableScrollPhysics(),
              //           itemCount: (picData?.comment?.length ?? 0) >= 2 ? 2 : 1,
              //           itemBuilder: (context, indexComment) {
              //             return Padding(
              //               padding: const EdgeInsets.only(bottom: 6.0),
              //               child: CustomNewDescContent(
              //                 // desc: "${picData??.description}",
              //                 username: picData?.comment?[indexComment].userComment?.username ?? '',
              //                 desc: picData?.comment?[indexComment].txtMessages ?? '',
              //                 trimLines: 2,
              //                 textAlign: TextAlign.start,
              //                 seeLess: ' seeLess', // ${notifier2.translate.seeLess}',
              //                 seeMore: '  Selengkapnya ', //${notifier2.translate.seeMoreContent}',
              //                 normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
              //                 hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
              //                 expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
              //               ),
              //             );
              //           },
              //         ),
              //       )
              //     : Container(),
              // Padding(
              //   padding: EdgeInsets.symmetric(vertical: 4.0),
              //   child: Text(
              //     "${System().readTimestamp(
              //       DateTime.parse(System().dateTimeRemoveT(picData?.createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
              //       context,
              //       fullCaption: true,
              //     )}",
              //     style: TextStyle(fontSize: 12, color: kHyppeBurem),
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildBody(BuildContext context, width, ContentData data) {
  //   return Positioned.fill(
  //     child: Stack(
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: PicTopItem(data: data),
  //         ),
  //         if (data.tagPeople?.isNotEmpty ?? false)
  //           Positioned(
  //             bottom: 18,
  //             left: 12,
  //             child: GestureDetector(
  //               child: const CustomIconWidget(
  //                 iconData: '${AssetPath.vectorPath}tag_people.svg',
  //                 defaultColor: false,
  //                 height: 24,
  //               ),
  //             ),
  //           ),
  //         if (data.music != null)
  //           Align(
  //             alignment: Alignment.bottomRight,
  //             child: GestureDetector(
  //               onTap: () {
  //                 setState(() {
  //                   isMute = !isMute;
  //                 });
  //               },
  //               child: Padding(
  //                 padding: const EdgeInsets.all(16.0),
  //                 child: CustomIconWidget(
  //                   iconData: isMute ? '${AssetPath.vectorPath}sound-off.svg' : '${AssetPath.vectorPath}sound-on.svg',
  //                   defaultColor: false,
  //                   height: 24,
  //                 ),
  //               ),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  Widget blurContentWidget(BuildContext context, ContentData data) {
    final transnot = Provider.of<TranslateNotifierV2>(context, listen: false);
    return data.reportedStatus == 'BLURRED'
        ? Positioned.fill(
            child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Spacer(),
                      const CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}eye-off.svg",
                        defaultColor: false,
                        height: 30,
                      ),
                      Text(transnot.translate.sensitiveContent ?? 'Sensitive Content', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      Text("HyppePic ${transnot.translate.contentContainsSensitiveMaterial}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          )),
                      // data.email == SharedPreference().readStorage(SpKeys.email)
                      //     ? GestureDetector(
                      //         onTap: () => Routing().move(Routes.appeal, argument: data),
                      //         child: Container(
                      //             padding: const EdgeInsets.all(8),
                      //             margin: const EdgeInsets.all(18),
                      //             decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(10)),
                      //             child: Text(transnot.translate.appealThisWarning ?? 'Appeal This Warning', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                      //       )
                      //     : const SizedBox(),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          System().increaseViewCount2(context, data);
                          context.read<ReportNotifier>().seeContent(context, data, hyppePic);
                        },
                        child: Container(
                          padding: const EdgeInsets.only(top: 8),
                          margin: const EdgeInsets.only(bottom: 20, right: 8, left: 8),
                          width: SizeConfig.screenWidth,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            "${transnot.translate.see} HyppePic",
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          )
        : Container();
  }
}
