// import 'package:flutter/material.dart';
// import 'package:hyppe/core/constants/asset_path.dart';
// import 'package:hyppe/core/constants/enum.dart';
// import 'package:hyppe/core/constants/size_config.dart';
// import 'package:hyppe/initial/hyppe/translate_v2.dart';
// import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
// import 'package:hyppe/ui/constant/widget/custom_loading.dart';
// import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
// import 'package:hyppe/ux/routing.dart';
// import 'package:provider/provider.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// import 'notifier.dart';
// import 'widgets/beforelive.dart';

// class StreamerIOSScreen extends StatefulWidget {
//   const StreamerIOSScreen({super.key});

//   @override
//   State<StreamerIOSScreen> createState() => _StreamerIOSScreenState();
// }

// class _StreamerIOSScreenState extends State<StreamerIOSScreen> {
//   @override
//   void initState() {
//     final stream = Provider.of<StreameriOSNotifier>(context, listen: false);
//     stream.init(context);
//     WidgetsBinding.instance.addPostFrameCallback((_) {});
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tn = context.read<TranslateNotifierV2>().translate;
//     return Consumer<StreameriOSNotifier>(
//       builder: (_, notifier, __) => Scaffold(
//         resizeToAvoidBottomInset: false,
//         backgroundColor: Colors.black,
//         body: WillPopScope(
//           child: notifier.isloading
//               ? SizedBox(
//                   height: SizeConfig.screenHeight,
//                   child: Stack(
//                     children: [
//                       const Center(child: CustomLoading()),
//                       Align(
//                         alignment: Alignment.topRight,
//                         child: SafeArea(
//                           child: CustomIconButtonWidget(
//                             padding: const EdgeInsets.all(0),
//                             alignment: Alignment.center,
//                             iconData: "${AssetPath.vectorPath}close.svg",
//                             defaultColor: false,
//                             onPressed: () {
//                               Routing().moveBack();
//                             },
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 )
//               : Stack(children: [
//                   _buildPreviewWidget(context, notifier),
//                   notifier.statusLive == StatusStream.offline
//                   ? BeforeLive(mounted: mounted)
//                   : Container()
//                   // if (notifier.isloadingPreview)
//                   //   SizedBox(
//                   //     height: SizeConfig.screenHeight,
//                   //     child: Stack(
//                   //       children: [
//                   //         const Center(child: CustomLoading()),
//                   //         Align(
//                   //           alignment: Alignment.topRight,
//                   //           child: SafeArea(
//                   //             child: CustomIconButtonWidget(
//                   //               padding: const EdgeInsets.all(0),
//                   //               alignment: Alignment.center,
//                   //               iconData: "${AssetPath.vectorPath}close.svg",
//                   //               defaultColor: false,
//                   //               onPressed: () {
//                   //                 Routing().moveBack();
//                   //               },
//                   //             ),
//                   //           ),
//                   //         )
//                   //       ],
//                   //     ),
//                   //   )
//                 ]),
//           onWillPop: () async {
//             if (notifier.statusLive == StatusStream.offline) {
//               Routing().moveBack();
//               notifier.destoryPusher();
//             } else if (notifier.statusLive == StatusStream.standBy) {
//               notifier.cancelLive(context, mounted);
//               notifier.destoryPusher();
//             } else {
//               await ShowGeneralDialog.generalDialog(
//                 context,
//                 titleText: tn.endofLIVEBroadcast,
//                 bodyText: tn.areYouSureYouWantToEndTheLIVEBroadcast,
//                 maxLineTitle: 1,
//                 maxLineBody: 4,
//                 functionPrimary: () async {
//                   notifier.endLive(context, context.mounted);
//                 },
//                 functionSecondary: () {
//                   Routing().moveBack();
//                 },
//                 titleButtonPrimary: "${tn.endNow}",
//                 titleButtonSecondary: "${tn.cancel}",
//                 barrierDismissible: true,
//                 isHorizontal: false,
//               );
//             }
//             return false;
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildPreviewWidget(
//       BuildContext context, StreameriOSNotifier notifier) {
//     var width = MediaQuery.of(context).size.width;
//     var height = MediaQuery.of(context).size.height;
//     return Positioned(
//       child: Container(
//         color: Colors.black,
//         width: width,
//         height: height,
//         child: AgoraVideoView(
//           controller: VideoViewController(
//             rtcEngine: notifier.engine,
//             canvas: const VideoCanvas(uid: 0),
//           ),
//         ),
//       ),
//     );
//   }
// }
