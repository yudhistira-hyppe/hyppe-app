// import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
// import 'package:hyppe/ui/constant/widget/custom_loading.dart';
// import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
// import 'package:hyppe/ui/inner/home/content/wallet/notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:tuple/tuple.dart';

// class BottomButton extends StatelessWidget {
//   const BottomButton({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final notifier = context.select((WalletNotifier value) => Tuple3(value.isLoading, value.isEditPhoneNumber, value.isValidPhoneNumber));

//     return CustomElevatedButton(
//       child: !notifier.item1
//           ? CustomTextWidget(
//               textToDisplay: 'Sambungkan',
//               textStyle: Theme.of(context).textTheme.button,
//             )
//           : CustomLoading(),
//       width: MediaQuery.of(context).size.width,
//       height: 40,
//       function: () => context.read<WalletNotifier>().syncToDana(fromHome: false),
//       buttonStyle: ButtonStyle(
//         backgroundColor: MaterialStateProperty.all(
//           notifier.item2 || !notifier.item3 ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.primaryVariant,
//         ),
//       ),
//     );
//   }
// }
