import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/widget/react_stream_item.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../initial/hyppe/translate_v2.dart';
import '../../../../widget/custom_gesture.dart';
import '../../../../widget/custom_icon_widget.dart';
import '../../../../widget/custom_spacer.dart';
import '../../../../widget/custom_text_widget.dart';

class OnReactStreaming extends StatefulWidget {
  final ReactStream react;
  final int? nilai;
  const OnReactStreaming({super.key, required this.react, this.nilai});

  @override
  State<OnReactStreaming> createState() => _OnReactStreamingState();
}

class _OnReactStreamingState extends State<OnReactStreaming> {
  late ReactStream reactStream;
  int textLenght = 0;
  int nilai = 0;

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    reactStream = widget.react;
    super.initState();
    setState(() {
      nilai = widget.nilai ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) => Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
        decoration: BoxDecoration(
          color: context.getColorScheme().background,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            topLeft: Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
            sixteenPx,
            CustomTextWidget(
              textToDisplay: language.howWasYourLiveExperience ?? "Bagaimana pengalaman siaran Live-mu?",
              textStyle: context.getTextTheme().bodyText1?.copyWith(fontWeight: FontWeight.w700),
            ),
            sixteenPx,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ReactStreamItem(
                    svg: reactStream == ReactStream.bad ? '${AssetPath.vectorPath}bad_active.svg' : '${AssetPath.vectorPath}bad_outline.svg',
                    desc: (language.poor ?? 'Buruk'),
                    onTap: () {
                      setState(() {
                        reactStream = ReactStream.bad;
                        nilai = 1;
                      });
                    }),
                ReactStreamItem(
                    svg: reactStream == ReactStream.neutral ? '${AssetPath.vectorPath}neutral_active.svg' : '${AssetPath.vectorPath}neutral_outline.svg',
                    desc: (language.neutral ?? 'Netral'),
                    onTap: () {
                      setState(() {
                        reactStream = ReactStream.neutral;
                        nilai = 2;
                      });
                    }),
                ReactStreamItem(
                    svg: reactStream == ReactStream.good ? '${AssetPath.vectorPath}good_active.svg' : '${AssetPath.vectorPath}good_outline.svg',
                    desc: (language.good ?? 'Baik'),
                    onTap: () {
                      setState(() {
                        reactStream = ReactStream.good;
                        nilai = 3;
                      });
                    }),
              ],
            ),
            sixteenPx,
            Container(
              alignment: Alignment.centerRight,
              child: CustomTextWidget(textToDisplay: '$textLenght/200'),
            ),
            eightPx,
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null, // Set this
                expands: true, // and this
                maxLength: 200,
                keyboardType: TextInputType.text,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (text) {
                  setState(() {
                    textLenght = text.length;
                  });
                },
                decoration: InputDecoration(
                  hintText: language.letUsKnowIfYouHaveAnyQuestionsOrFeedback ?? "Beri tahu kami jika kamu memiliki pertanyaan, saran, ataupun masukan ",
                  contentPadding: const EdgeInsets.only(left: 5, top: 5, right: 5),
                  hintMaxLines: 3,
                  hintStyle: const TextStyle(fontSize: 14, color: kHyppeBurem, fontWeight: FontWeight.normal),
                  border: InputBorder.none,
                  filled: true,
                  // focusedBorder: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(width: 2, color: context.getColorScheme().primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(width: 1, color: context.getColorScheme().secondary),
                  ),
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
            sixteenPx,
            CustomGesture(
              margin: EdgeInsets.zero,
              onTap: () {
                if (!notifier.isloading) {
                  notifier.sendScoreLive(context, mounted, desc: controller.text, score: nilai).then((value) {
                    Navigator.pop(context, reactStream);
                  });
                }
              },
              child: Container(
                width: double.infinity,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.getColorScheme().primary,
                  // border: Border.all(color: kHyppeBurem, width: 1)
                ),
                alignment: Alignment.center,
                child: notifier.isloading
                    ? CustomLoading()
                    : CustomTextWidget(
                        textToDisplay: language.send ?? '',
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
              ),
            ),
            sixteenPx,
            CustomTextWidget(
              textToDisplay: language.yourFeedbackIsValuableToHyppeForEnhancingYourPersonalizedExperience ?? 'Tanggapanmu sangat berarti untuk Hyppe dapat meningkatkan  pengalamanmu secara personal.',
              maxLines: 2,
              textAlign: TextAlign.center,
              textStyle: const TextStyle(
                fontSize: 12,
                color: kHyppeBurem,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
