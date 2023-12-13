import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
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
  const OnReactStreaming({super.key});

  @override
  State<OnReactStreaming> createState() => _OnReactStreamingState();
}

class _OnReactStreamingState extends State<OnReactStreaming> {

  ReactStream? reactStream;
  int textLenght = 0;

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    return Container(
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
          const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}handler.svg"),
          sixteenPx,
          CustomTextWidget(
            textToDisplay: "Bagaimana pengalaman siaran Live-mu?",
            textStyle: context
                .getTextTheme()
                .bodyText1
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          sixteenPx,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ReactStreamItem(svg: reactStream == ReactStream.bad ? '${AssetPath.vectorPath}bad_active.svg' : '${AssetPath.vectorPath}bad_outline.svg', desc: 'Buruk', onTap: (){
                setState(() {
                  reactStream = ReactStream.bad;
                });
              }),
              ReactStreamItem(svg: reactStream == ReactStream.neutral ? '${AssetPath.vectorPath}neutral_active.svg' : '${AssetPath.vectorPath}neutral_outline.svg', desc: 'Netral', onTap: (){
                setState(() {
                  reactStream = ReactStream.neutral;
                });
              }),
              ReactStreamItem(svg: reactStream == ReactStream.good ? '${AssetPath.vectorPath}good_active.svg' : '${AssetPath.vectorPath}good_outline.svg', desc: 'Baik', onTap: (){
                setState(() {
                  reactStream = ReactStream.good;
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
              maxLines: null, // Set this
              expands: true, // and this
              keyboardType: TextInputType.text,
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.top,
              onChanged: (text){
                setState(() {
                  textLenght = text.length;
                });
              },
              decoration: InputDecoration(
                hintText: "Beri tahu kami jika kamu memiliki pertanyaan, saran, ataupun masukan ",
                contentPadding: const EdgeInsets.only(left: 5, top: 5),
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
              ),
            ),
          ),
          sixteenPx,
          CustomGesture(
            margin: EdgeInsets.zero,
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 34,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.getColorScheme().primary.withOpacity(0.8),
                  // border: Border.all(color: kHyppeBurem, width: 1)
              ),
              alignment: Alignment.center,
              child: CustomTextWidget(
                textToDisplay: language.removeUser ?? '',
                textAlign: TextAlign.center,
                textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
          sixteenPx,
          const CustomTextWidget(
            textToDisplay: 'Tanggapanmu sangat berarti untuk Hyppe dapat meningkatkan  pengalamanmu secara personal.',
            textAlign: TextAlign.center,
            textStyle: TextStyle(
              fontSize: 12,
              color: kHyppeBurem,
            ),
          ),
        ],
      ),
    );
  }
}
