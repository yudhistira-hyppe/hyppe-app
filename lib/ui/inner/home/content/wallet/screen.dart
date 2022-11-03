// import 'package:hyppe/core/constants/asset_path.dart';
// import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
// import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
// import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
// import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
// import 'package:hyppe/ui/constant/widget/keyboard_disposal.dart';
// import 'package:hyppe/ui/inner/home/content/wallet/notifier.dart';
// import 'package:hyppe/ui/inner/home/content/wallet/widget/bottom_button.dart';
// import 'package:hyppe/ui/inner/home/content/wallet/widget/center_description.dart';
// import 'package:hyppe/ui/inner/home/content/wallet/widget/hint_phone_number.dart';
// import 'package:hyppe/ui/inner/home/content/wallet/widget/phone_number_text_field.dart';
// import 'package:hyppe/ui/inner/home/content/wallet/widget/top_icon.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class Wallet extends StatefulWidget {
//   const Wallet({Key? key}) : super(key: key);

//   @override
//   _WalletState createState() => _WalletState();
// }

// class _WalletState extends State<Wallet> with AfterFirstLayoutMixin {
//   late WalletNotifier _notifier;

//   @override
//   void afterFirstLayout(BuildContext context) {
//     _notifier = Provider.of<WalletNotifier>(context, listen: false);
//     _notifier.initial();
//   }

//   @override
//   void dispose() {
//     _notifier.onDispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: KeyboardDisposal(
//         child: WillPopScope(
//           onWillPop: context.read<WalletNotifier>().onWillPop,
//           child: Scaffold(
//             body: Stack(
//               children: [
//                 CustomTextButton(
//                   onPressed: () => context.read<WalletNotifier>().backToHome(),
//                   child: CustomIconWidget(
//                     defaultColor: false,
//                     iconData: '${AssetPath.vectorPath}back-arrow.svg',
//                     color: Theme.of(context).appBarTheme.iconTheme.color,
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Align(
//                     alignment: const Alignment(0.0, -0.3),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         TopIcon(),
//                         fortyEightPx,
//                         CenterDescription(),
//                         twentyPx,
//                         PhoneNumberTextField(),
//                         fourPx,
//                         HintPhoneNumber(),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Align(
//                     alignment: Alignment.bottomCenter,
//                     child: BottomButton(),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
