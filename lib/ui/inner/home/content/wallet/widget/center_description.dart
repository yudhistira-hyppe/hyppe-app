// import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
// import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
// import 'package:hyppe/ui/inner/home/content/wallet/notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class CenterDescription extends StatelessWidget {
//   const CenterDescription({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final language = context.select((WalletNotifier value) => value.language);

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         CustomTextWidget(
//           textAlign: TextAlign.left,
//           textToDisplay: "Sambungkan Akun",
//           textStyle: Theme.of(context).textTheme.headline6,
//         ),
//         twentyPx,
//         CustomTextWidget(
//           textAlign: TextAlign.left,
//           textToDisplay: language.createAccountAndConnect,
//           textStyle: Theme.of(context).textTheme.bodyText1,
//           maxLines: null,
//           textOverflow: TextOverflow.visible,
//         ),
//       ],
//     );
//   }
// }
