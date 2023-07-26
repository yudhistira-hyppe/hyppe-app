import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/chalange/leaderboard_challange_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';

class OnDatepickerMonth extends StatefulWidget {
  final bool? isDetail;

  const OnDatepickerMonth({super.key, this.isDetail});
  @override
  State<OnDatepickerMonth> createState() => _OnDatepickerMonthState();
}

class _OnDatepickerMonthState extends State<OnDatepickerMonth> {
  DateTime? _dateTime;
  String MIN_DATETIME = '2010-05-12';
  String MAX_DATETIME = '2100-11-25';
  String INIT_DATETIME = '2019-05-17';
  String DATE_FORMAT = 'MMMM,yyyy';

  @override
  void initState() {
    super.initState();
    final cn = context.read<ChallangeNotifier>();
    _dateTime = cn.challangeOption;
    INIT_DATETIME = _dateTime.toString();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle hintTextStyle = Theme.of(context).textTheme.subtitle1!.apply(color: Color(0xFF999999));
    TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();
    return Consumer<ChallangeNotifier>(
      builder: (_, notifier, __) => Column(
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
                  "${tn.translate.selectDate}",
                  style: const TextStyle(
                    color: Color(0xFF3E3E3E),
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                twelvePx,
                Divider(),
                sixteenPx,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "${tn.translate.month}",
                      style: TextStyle(
                        color: Color(0xFF9B9B9B),
                      ),
                    ),
                    Text(
                      "${tn.translate.year}",
                      style: TextStyle(
                        color: Color(0xFF9B9B9B),
                      ),
                    )
                  ],
                ),
                sixteenPx,
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // date picker widget
                      DateTimePickerWidget(
                        onMonthChangeStartWithFirstDate: false,
                        minDateTime: DateTime.parse(MIN_DATETIME),
                        maxDateTime: DateTime.parse(MAX_DATETIME),
                        initDateTime: DateTime.parse(INIT_DATETIME),
                        dateFormat: DATE_FORMAT,
                        onCancel: () {},
                        onConfirm: (dateTime, selectedIndex) {},
                        pickerTheme: DateTimePickerTheme(
                          backgroundColor: Colors.transparent,
                          cancelTextStyle: TextStyle(color: Colors.transparent),
                          confirmTextStyle: TextStyle(color: Colors.transparent),
                          itemTextStyle: TextStyle(color: kHyppeTextLightPrimary),
                          titleHeight: 0.0,
                          itemHeight: 50.0,
                          pickerHeight: 100,
                        ),
                        onChange: (dateTime, selectedIndex) {
                          setState(() {
                            _dateTime = dateTime;
                          });
                        },
                      ),

                      // selected date
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: <Widget>[
                      //     Text('Selected Date:', style: Theme.of(context).textTheme.subtitle1),
                      //     Container(
                      //       padding: EdgeInsets.only(left: 12.0),
                      //       child: Text(
                      //         _dateTime != null ? '${_dateTime!.year}-${_dateTime!.month.toString().padLeft(2, '0')}-${_dateTime!.day.toString().padLeft(2, '0')}' : '',
                      //         style: Theme.of(context).textTheme.headline6,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ButtonChallangeWidget(
                bgColor: kHyppePrimary,
                text: "${tn.translate.apply}",
                function: () {
                  print(_dateTime); // print(cn.leaderBoardData?.challengeId);
                  var cn = context.read<ChallangeNotifier>();
                  cn.getOption(
                    ((widget.isDetail ?? false) ? cn.leaderBoardDetailData : cn.leaderBoardData) ?? LeaderboardChallangeModel(),
                    dateTime: _dateTime,
                  );
                  Routing().moveBack();
                  // Routing().move(Routes.chalengeDetail, argument: GeneralArgument(id: cn.leaderBoardData?.challengeId));
                }),
          ),
        ],
      ),
    );
  }
}
