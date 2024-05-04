import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/summary_live_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/feedback/notifier.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../ux/routing.dart';
import '../../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../../../constant/widget/icon_button_widget.dart';
import '../widget/react_stream_item.dart';

class StreamingFeedbackScreen extends StatefulWidget {
  final SummaryLiveArgument? arguments;
  const StreamingFeedbackScreen({super.key, this.arguments});

  @override
  State<StreamingFeedbackScreen> createState() =>
      _StreamingFeedbackScreenState();
}

class _StreamingFeedbackScreenState extends State<StreamingFeedbackScreen> {
  ReactStream? reactChosen;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final stream = Provider.of<StreamingFeedbackNotifier>(context, listen: false);
      if (widget.arguments!.blockLive??false){
        openBlockComponent(stream);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StreamingFeedbackNotifier>(builder: (context, notifier, _) {
      final language = notifier.language;
      return Scaffold(
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  alignment: Alignment.topRight,
                  child: CustomIconButtonWidget(
                    height: 24,
                    width: 24,
                    onPressed: () => Routing().moveBack(),
                    iconData: '${AssetPath.vectorPath}close_ads.svg',
                  ),
                ),
                twentyPx,
                CustomTextWidget(
                  textToDisplay:
                      language.liveVideoHasEnded ?? 'LIVE telah berakhir',
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                eightPx,
                CustomTextWidget(
                  textToDisplay:
                      '${System().dateFormatter(DateTime.now().toString(), 3)} • ${language.duration} ${widget.arguments?.duration.inMinutes} : ${(widget.arguments?.duration.inSeconds ?? 0) % 60}',
                  textStyle: const TextStyle(fontSize: 12, color: kHyppeBurem),
                ),
                twentyPx,
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: kHyppeBorderTab),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextWidget(
                        textToDisplay: language.engagement ?? 'Keterlibatan',
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      sixteenPx,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              itemStatus(
                                  language.totalViewers ?? 'Jumlah Penonton',
                                  (widget.arguments?.data.totalViews ?? 0)
                                      .toString()),
                              twentyPx,
                              itemStatus(
                                  language.totalPemberiGift ??
                                      'Total Pemberi Gift',
                                  (widget.arguments?.data.totalGift ?? 0)
                                      .toString()),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              itemStatus(
                                  language.totalShares ?? 'Jumlah Membagikan',
                                  (widget.arguments?.data.totalShare ?? 0)
                                      .toString()),
                              twentyPx,
                              itemStatus(
                                  language.totalGift ?? 'Total Gift',
                                  (widget.arguments?.data.totalGifter ?? 0)
                                      .toString()),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              itemStatus(
                                  language.newFollowers ?? 'Pengikut Baru',
                                  (widget.arguments?.data.totalFollower ?? 0)
                                      .toString()),
                              twentyPx,
                              itemStatus(
                                  language.totalComments ?? 'Jumlah Komentar',
                                  (widget.arguments?.data.totalComment ?? 0)
                                      .toString()),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      itemStatus(language.totalLikes ?? 'Jumlah Suka',
                          (widget.arguments?.data.totalLike ?? 0).toString()),
                    ],
                  ),
                ),
                twelvePx,
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: kHyppeBorderTab),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextWidget(
                          textToDisplay: language.income ?? 'Pendapatan',
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CustomIconWidget(
                                iconData: "${AssetPath.vectorPath}ic-coin.svg",
                                defaultColor: false,
                              ),
                              const SizedBox(
                                width: 12.0,
                              ),
                              CustomTextWidget(
                                textToDisplay:
                                    (widget.arguments?.data.totalCoin ?? 0)
                                        .toString(),
                                textStyle: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: CustomTextWidget(
                            textToDisplay: language.totalIncomeLive ??
                                'Total Pendapatan LIVE',
                            textStyle: const TextStyle(
                                fontSize: 12, color: kHyppeBurem),
                          ),
                        ),
                      ],
                    )),
                twelvePx,
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: kHyppeBorderTab),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      ShowBottomSheet.onListOfWatcher(context);
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextWidget(
                            textToDisplay:
                                language.viewerList ?? 'Daftar Penonton',
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          CustomTextWidget(
                            textToDisplay:
                                (widget.arguments?.data.totalViews ?? 0)
                                    .toString(),
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.getColorScheme().primary,
                            ),
                          ),
                        ]),
                  ),
                ),
                twelvePx,
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: kHyppeBorderTab),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      ShowBottomSheet.onListOfGift(context);
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextWidget(
                            textToDisplay:
                                language.giftList ?? 'Hadiah yang Diterima',
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          CustomTextWidget(
                            textToDisplay:
                                (widget.arguments?.data.totalGifter ?? 0)
                                    .toString(),
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.getColorScheme().primary,
                            ),
                          ),
                        ]),
                  ),
                ),
                twelvePx,
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: kHyppeBorderTab),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextWidget(
                        textToDisplay: language.howWasYourLiveExperience ??
                            'Bagaimana pengalaman siaran LIVE-mu?',
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      twentyPx,
                      reactChosen != null
                          ? SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CustomIconWidget(
                                      defaultColor: false,
                                      iconData: reactChosen == ReactStream.bad
                                          ? '${AssetPath.vectorPath}bad_active.svg'
                                          : reactChosen == ReactStream.neutral
                                              ? '${AssetPath.vectorPath}neutral_active.svg'
                                              : '${AssetPath.vectorPath}good_active.svg'),
                                  eightPx,
                                  CustomTextWidget(
                                    textToDisplay:
                                        reactChosen == ReactStream.bad
                                            ? (language.poor ?? 'Buruk')
                                            : reactChosen == ReactStream.neutral
                                                ? (language.neutral ?? 'Netral')
                                                : (language.good ?? 'Baik'),
                                    textStyle: const TextStyle(
                                        fontSize: 12, color: kHyppeBurem),
                                  ),
                                ],
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ReactStreamItem(
                                    onTap: () async {
                                      reactChosen = await ShowBottomSheet()
                                          .onReactStreaming(
                                              context, ReactStream.bad, 1);
                                      setState(() {});
                                    },
                                    svg:
                                        '${AssetPath.vectorPath}bad_outline.svg',
                                    desc: (language.poor ?? 'Buruk')),
                                ReactStreamItem(
                                    onTap: () async {
                                      reactChosen = await ShowBottomSheet()
                                          .onReactStreaming(
                                              context, ReactStream.neutral, 2);
                                      setState(() {});
                                    },
                                    svg:
                                        '${AssetPath.vectorPath}neutral_outline.svg',
                                    desc: (language.neutral ?? 'Netral')),
                                ReactStreamItem(
                                    onTap: () async {
                                      reactChosen = await ShowBottomSheet()
                                          .onReactStreaming(
                                              context, ReactStream.good, 3);
                                      setState(() {});
                                    },
                                    svg:
                                        '${AssetPath.vectorPath}good_outline.svg',
                                    desc: (language.good ?? 'Baik'))
                              ],
                            )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget itemStatus(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextWidget(
          textToDisplay: title,
          textStyle: const TextStyle(fontSize: 12, color: kHyppeBurem),
        ),
        twoPx,
        CustomTextWidget(
          textToDisplay: value,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void openBlockComponent(StreamingFeedbackNotifier notifier) {
    final language = notifier.language;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * .3,
          padding: const EdgeInsets.all(0),
          child: Dialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Container(
              padding: const EdgeInsets.all(15),
              height: MediaQuery.of(context).size.height * .3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CustomIconWidget(
                    iconData: "${AssetPath.vectorPath}livewarningdark.svg",
                    defaultColor: false,
                  ),
                  Text(
                    language.labelBlockLive2 ?? 'Siaran LIVE dihentikan',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                  twelvePx,
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: language.labelBlockLive3 ?? 'Siaran LIVE telah dihentikan oleh sistem karena melanggar ',
                            style: const TextStyle(
                              color: kHyppeBurem
                            )
                          ),
                          TextSpan(
                            text: language.communityguidelines ?? 'Pedoman Komunitas Hyppe.',
                            style: const TextStyle(
                              color: kHyppePrimary,
                              fontWeight: FontWeight.bold
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () { launchUrl(Uri.parse('https://hyppe.id/en/privacy-policy'));
                            },
                          )
                        ]
                      ),
                    ),
                  ),
                  sixteenPx,
                    CustomTextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 48),
                        child: Text(
                          'OK',
                          style: TextStyle(
                            color: kHyppePrimary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}