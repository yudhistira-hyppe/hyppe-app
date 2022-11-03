// import 'package:hyppe/core/constants/asset_path.dart';
// import 'package:hyppe/core/constants/size_config.dart';
// import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
// import 'package:hyppe/ui/constant/widget/custom_loading.dart';
// import 'package:hyppe/ui/constant/widget/custom_switch_button.dart';
// import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
// // import 'package:hyppe/ui/inner/message/notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:hyppe/ui/inner/message_v2/notifier.dart';
// import 'package:provider/provider.dart';

// class OnLongPressTileUserMessageBottomSheet extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<MessageNotifier>(
//       builder: (_, notifier, __) => Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           const Expanded(
//             flex: 1,
//             child: CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
//           ),
//           Expanded(
//               flex: 4,
//               child: Column(
//                 children: [
//                   Container(
//                     child: ListTile(
//                       leading: Container(
//                         decoration: BoxDecoration(
//                           image: DecorationImage(
//                             fit: BoxFit.cover,
//                             image: NetworkImage(notifier.overview.profilePicture),
//                           ),
//                           shape: BoxShape.circle,
//                         ),
//                         height: 48 * SizeConfig.scaleDiagonal,
//                         width: 48 * SizeConfig.scaleDiagonal,
//                       ),
//                       title: CustomTextWidget(
//                         // "Demo user",
//                         textToDisplay: notifier.overview!.username,
//                         textAlign: TextAlign.start,
//                         textStyle: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                       subtitle: CustomTextWidget(textToDisplay: notifier.overview!.fullName, textAlign: TextAlign.start, textStyle: Theme.of(context).textTheme.caption),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 1,
//                     width: SizeConfig.screenWidth,
//                     child: Container(color: Color(0xff2C3236)),
//                   )
//                 ],
//               )),
//           Expanded(
//             flex: 5,
//             child: notifier.overview != null
//                 ? Padding(
//                     padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             CustomTextWidget(
//                               textToDisplay: notifier.language.muteMessage,
//                               textStyle: Theme.of(context).textTheme.subtitle1,
//                             ),
//                             CustomSwitchButton(
//                               onChanged: (v) => notifier.toggleValue = v,
//                               value: notifier.toggleValue,
//                             )
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             GestureDetector(
//                               onTap: () => print("Chat Deleted"),
//                               child: CustomTextWidget(
//                                 textToDisplay: notifier.language.deleteMessage,
//                                 textStyle: Theme.of(context).textTheme.subtitle1,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   )
//                 : SizedBox.shrink(),
//           )
//         ],
//       ),
//     );
//   }
// }
