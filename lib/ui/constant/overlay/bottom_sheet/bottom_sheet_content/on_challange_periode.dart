import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

class OnChallangePeriodeBottomSheet extends StatefulWidget {
  final int? session;
  const OnChallangePeriodeBottomSheet({super.key, this.session});

  @override
  State<OnChallangePeriodeBottomSheet> createState() => _OnChallangePeriodeBottomSheetState();
}

class _OnChallangePeriodeBottomSheetState extends State<OnChallangePeriodeBottomSheet> {
  int _currentSession = 1;
  @override
  void initState() {
    setState(() {
      _currentSession = (widget.session ?? 1) - 1;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id', null);
    SizeConfig().init(context);
    TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();
    return Consumer<ChallangeNotifier>(
      builder: (_, cn, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(8 * SizeConfig.scaleDiagonal),
              child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg", defaultColor: false),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "${tn.translate.selectChallengePeriod}",
                  style: const TextStyle(
                    color: Color(0xFF3E3E3E),
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                sixteenPx,
                GestureDetector(
                  onTap: () {
                    ShowBottomSheet.onDatePickerMonth(context);
                  },
                  child: Container(
                    padding: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: kHyppeBorderTab, width: 2.0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          // "${cn.challangeOption} ${tn.translate.localeDatetime}",
                          "${System().dateFormatter(cn.challangeOption.toString(), 8, lang: tn.translate.localeDatetime ?? '')}",
                          style: TextStyle(
                            color: Color(0xFF3E3E3E),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: false,
              itemCount: cn.optionData.detail?.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: RadioListTile<int>(
                    contentPadding: EdgeInsets.zero,
                    groupValue: cn.optionData.detail?[index].session,
                    value: _currentSession,
                    onChanged: (_) {
                      if (mounted) {
                        setState(() {
                          _currentSession = cn.optionData.detail?[index].session ?? 1;
                        });
                      }
                    },
                    toggleable: true,
                    title: CustomTextWidget(
                      textAlign: TextAlign.left,
                      textToDisplay: "Period ${cn.optionData.detail?[index].session}",
                      textStyle: Theme.of(context).primaryTextTheme.titleMedium,
                    ),
                    subtitle: CustomTextWidget(
                      textAlign: TextAlign.left,
                      textToDisplay: "${System().dateFormatter(cn.optionData.detail?[index].startDatetime ?? '', 5)} - ${System().dateFormatter(cn.optionData.detail?[index].endDatetime ?? '', 5)}",
                      textStyle: Theme.of(context).primaryTextTheme.subtitle2,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ButtonChallangeWidget(bgColor: kHyppePrimary, text: "${tn.translate.apply}", function: () {}),
          ),
        ],
      ),
    );
  }
}
