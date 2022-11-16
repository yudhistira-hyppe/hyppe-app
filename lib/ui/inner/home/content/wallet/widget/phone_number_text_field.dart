// import 'package:hyppe/core/constants/size_config.dart';
// import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
// import 'package:hyppe/ui/constant/widget/custom_loading.dart';
// import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
// import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
// import 'package:hyppe/ui/inner/home/content/wallet/notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

// class PhoneNumberTextField extends StatelessWidget {
//   const PhoneNumberTextField({Key? key});

//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     final theme = Theme.of(context);

//     return Consumer<WalletNotifier>(
//       builder: (_, notifier, __) => CustomTextFormField(
//         style: theme.textTheme.bodyText1,
//         readOnly: !notifier.isEditPhoneNumber,
//         onChanged: (value) => notifier.phoneNumber = value,
//         textAlign: TextAlign.left,
//         inputFormatter: [FilteringTextInputFormatter.digitsOnly],
//         textInputType: TextInputType.text,
//         textEditingController: notifier.phoneNumberController,
//         inputDecoration: InputDecoration(
//           hintText: 'Nomor telepon',
//           hintStyle: TextStyle(
//             height: 2.5,
//             fontWeight: FontWeight.w400,
//             color: const Color(0xffA8A6A6),
//             fontSize: 16 * SizeConfig.scaleDiagonal,
//           ),
//           contentPadding: const EdgeInsets.only(bottom: 2),
//           floatingLabelBehavior: FloatingLabelBehavior.always,
//           enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: const Color(0xff707070), width: 1)),
//           focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: const Color(0xff822E6E), width: 1)),
//           suffixIcon: notifier.loadingForObject(notifier.completeProfileKey)
//               ? CustomLoading()
//               : CustomElevatedButton(
//                   child: CustomTextWidget(
//                     textToDisplay: !notifier.isEditPhoneNumber ? 'Ubah nomor' : 'Selesai',
//                     textStyle: theme.textTheme.caption!.copyWith(
//                       color: notifier.isValidPhoneNumber ? theme.colorScheme.primaryVariant : theme.colorScheme.secondaryVariant,
//                     ),
//                   ),
//                   width: 80,
//                   height: 0, // ignore this, because this widget is constarined to the parent
//                   function: () {
//                     if (notifier.isEditPhoneNumber) {
//                       notifier.onClickSaveProfile(context);
//                     } else {
//                       notifier.isEditPhoneNumber = true;
//                     }
//                   },
//                   buttonStyle: theme.elevatedButtonTheme.style.copyWith(
//                     alignment: Alignment.centerRight,
//                     padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 8.0)),
//                     overlayColor: MaterialStateProperty.all(Colors.transparent),
//                     backgroundColor: MaterialStateProperty.all(Colors.transparent),
//                   ),
//                 ),
//         ),
//         inputAreaWidth: SizeConfig.screenWidth,
//         inputAreaHeight: 50 * SizeConfig.scaleDiagonal,
//       ),
//     );
//   }
// }
