// import 'package:hyppe/core/constants/asset_path.dart';
// import 'package:hyppe/core/constants/size_config.dart';
// import 'package:hyppe/core/models/collection/report/report.dart';
// import 'package:hyppe/ui/constant/entities/report/notifier.dart';
// import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/report/widget/conditional_bottom.dart';
// import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/report/widget/conditional_header.dart';
// import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
// import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
// import 'package:hyppe/ui/constant/widget/custom_loading.dart';
// import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
// import 'package:hyppe/ux/routing.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

// class HyppeReport extends StatefulWidget {
//   @override
//   _HyppeReportState createState() => _HyppeReportState();
// }

// class _HyppeReportState extends State<HyppeReport> {
//   @override
//   void initState() {
//     super.initState();
//     final notifier = Provider.of<ReportNotifier>(context, listen: false);
//     notifier.initializeData(context);
//     if (notifier.fromLandscapeMode) SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//   }

//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     final _themes = Theme.of(context);
//     final notifier = Provider.of<ReportNotifier>(context);
//     return WillPopScope(
//         onWillPop: () async {
//           notifier.initData = Report();
//           if (notifier.fromLandscapeMode) SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
//           return true;
//         },
//         child: Scaffold(
//             appBar: AppBar(
//                 backgroundColor: Theme.of(context).backgroundColor,
//                 automaticallyImplyLeading: false,
//                 elevation: 0.0,
//                 title: CustomTextWidget(
//                     textAlign: TextAlign.left, textToDisplay: notifier.appBar!, textStyle: _themes.textTheme.labelLarge.apply(fontWeightDelta: 1)),
//                 actions: [
//                   GestureDetector(
//                     child: Container(
//                       height: 50.0 * SizeConfig.scaleDiagonal,
//                       width: 50.0 * SizeConfig.scaleDiagonal,
//                       color: Colors.transparent,
//                       child: const UnconstrainedBox(
//                         child: CustomIconWidget(iconData: '${AssetPath.vectorPath}close.svg'),
//                       ),
//                     ),
//                     onTap: () {
//                       if (notifier.fromLandscapeMode) {
//                         SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
//                       }
//                       Routing().moveBack();
//                       notifier.initData = Report();
//                     },
//                   )
//                 ],
//                 centerTitle: false,
//                 bottom: PreferredSize(
//                     child: Container(color: Colors.grey[800], height: 1.0 * SizeConfig.scaleDiagonal),
//                     preferredSize: Size.fromHeight(1.0 * SizeConfig.scaleDiagonal))),
//             body: Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Column(children: [
//                   conditionalHeader(context),
//                   SizedBox(
//                       height: SizeConfig.screenHeight! * 0.5,
//                       child: notifier.initData == null
//                           ? const Center(child: CustomLoading())
//                           : ListView.builder(
//                               scrollDirection: Axis.vertical,
//                               physics: const BouncingScrollPhysics(),
//                               itemCount: notifier.initData!.data.length,
//                               itemBuilder: (context, index) {
//                                 return RadioListTile(
//                                     value: index,
//                                     toggleable: true,
//                                     title: CustomTextWidget(
//                                         maxLines: 2,
//                                         textAlign: TextAlign.left,
//                                         textStyle: _themes.textTheme.bodyMedium,
//                                         textToDisplay: notifier.initData!.data[index].remark!
//                                         ),
//                                     groupValue: notifier.selectedIndex,
//                                     activeColor: const Color(0xff7F2D6C),
//                                     controlAffinity: ListTileControlAffinity.trailing,
//                                     onChanged: (int? v) {
//                                       notifier.selectedIndex = v;
//                                       if (v != null) {
//                                         // notifier.remarkID = notifier.initData!.data[v].remarkID;
//                                       } else {
//                                         notifier.remarkID = '';
//                                       }
//                                     });
//                               })),
//                   conditionalBottom(context)
//                 ])),
//             backgroundColor: Colors.black,
//             floatingActionButton: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: CustomElevatedButton(
//                     child: notifier.isLoading
//                         ? SizedBox(width: 30 * SizeConfig.scaleDiagonal, height: 30 * SizeConfig.scaleDiagonal, child: const CustomLoading())
//                         : CustomTextWidget(textAlign: TextAlign.left, textToDisplay: notifier.fABCaption, textStyle: _themes.textTheme.labelLarge),
//                     function: () => notifier.onClickButton(context),
//                     width: 375.0 * SizeConfig.scaleDiagonal,
//                     height: 44.0 * SizeConfig.scaleDiagonal,
//                     buttonStyle: ButtonStyle(
//                         backgroundColor: notifier.remarkID.isNotEmpty
//                             ? MaterialStateProperty.all<Color>(_themes.colorScheme.primary)
//                             : MaterialStateProperty.all<Color>(_themes.colorScheme.surface)))),
//             floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat));
//   }
// }
