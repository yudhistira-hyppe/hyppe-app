// import 'package:hyppe/core/constants/enum.dart';
// import 'package:hyppe/core/constants/size_config.dart';
// import 'package:hyppe/core/services/error_service.dart';
// import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
// import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
// import 'package:hyppe/ui/constant/widget/custom_loading.dart';
// import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
// import 'package:hyppe/ui/outer/sign_up/content/complete_profile/notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// class CompleteProfileDocumentContent extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final notifier = context.watch<SignUpCompleteProfileNotifier>();
//     final error = context
//         .select((ErrorService value) => value.getError(ErrorType.getDocuments));
//
//     if (context.read<ErrorService>().isInitialError(
//         error, notifier.listDocument.isEmpty ? null : notifier.listDocument.isEmpty)) {
//       return Center(
//         child: Container(
//           height: SizeConfig.screenHeight * 0.8,
//           child: CustomErrorWidget(
//             function: () => notifier.onDocTypeShowDropDown(context),
//             errorType: ErrorType.getDocuments,
//           ),
//         ),
//       );
//     }
//
//     return Container(
//       height: SizeConfig.screenHeight * 0.8,
//       width: SizeConfig.screenWidth,
//       child: Center(
//           child: notifier.listDocument.isNotEmpty
//               ? ListView.builder(
//                   itemCount: notifier.listDocument.length,
//                   shrinkWrap: true,
//                   padding: EdgeInsets.all(0),
//                   itemBuilder: (context, index) => Container(
//                     padding: EdgeInsets.all(11),
//                     child: CustomElevatedButton(
//                       height: 42,
//                       width: SizeConfig.screenWidth,
//                       function: () => notifier.documentSelect(index, context),
//                       buttonStyle: ButtonStyle(),
//                       child: CustomTextWidget(
//                         textToDisplay:
//                             notifier.listDocument[index].documentName,
//                         textStyle: Theme.of(context).textTheme.bodyText1,
//                       ),
//                     ),
//                   ),
//                 )
//               : CustomLoading()),
//     );
//   }
// }
