import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

class EventBannerWidget extends StatefulWidget {
  const EventBannerWidget({super.key});

  @override
  State<EventBannerWidget> createState() => _EventBannerWidgetState();
}

class _EventBannerWidgetState extends State<EventBannerWidget> {
  @override
  Widget build(BuildContext context) {
    TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                textToDisplay: tn.translate.comeOnJoinTheInterestingCompetition ?? '',
                textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              CustomTextWidget(
                textToDisplay: tn.translate.otherCompetitions ?? '',
                textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kHyppePrimary),
              ),
            ],
          )
        ],
      ),
    );
  }
}
