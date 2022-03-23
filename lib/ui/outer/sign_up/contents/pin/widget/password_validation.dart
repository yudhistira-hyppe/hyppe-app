// import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';
// import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
// import 'package:hyppe/ui/outer/sign_up/new_account/notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// class PasswordValidation extends StatelessWidget {
//   bool firstValidation() => emailController.value.text != text ? true : false;
//   bool secondValidation() => text.length > 8 ? true : false;
//   bool thirdValidation() => text.contains(RegExp(r'[a-zA-Z]')) && text.contains(RegExp(r'[0-9]')) ? true : false;
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<SignUpNewAccountNotifier>(
//       builder: (_, notifier, __) => Column(
//         children: [
//           Theme(
//             data: Theme.of(context).copyWith(
//               radioTheme: RadioThemeData(
//                 visualDensity: VisualDensity.adaptivePlatformDensity,
//                 fillColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.secondaryVariant),
//               ),
//             ),
//             child: Column(
//               children: [
//                 RadioListTile(
//                   contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
//                   title: CustomTextWidget(
//                     textToDisplay: notifier.language.mustNotContainYourEmail!,
//                     textAlign: TextAlign.start,
//                     textStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
//                   ),
//                   value: notifier.firstValidation(),
//                   activeColor: Theme.of(context).colorScheme.primaryVariant,
//                   groupValue: true,
//                   toggleable: false,
//                   onChanged: (dynamic v) => v,
//                 ),
//                 RadioListTile(
//                   contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
//                   title: CustomTextWidget(
//                     textToDisplay: notifier.language.atLeast8Characters!,
//                     textAlign: TextAlign.start,
//                     textStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
//                   ),
//                   value: notifier.secondValidation(),
//                   activeColor: Theme.of(context).colorScheme.primaryVariant,
//                   groupValue: true,
//                   toggleable: false,
//                   onChanged: (dynamic v) => v,
//                 ),
//                 RadioListTile(
//                   contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
//                   title: CustomTextWidget(
//                     textToDisplay: notifier.language.atLeastContain1CharacterAnd1Number!,
//                     textAlign: TextAlign.start,
//                     textStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
//                   ),
//                   value: notifier.thirdValidation(),
//                   activeColor: Theme.of(context).colorScheme.primaryVariant,
//                   groupValue: true,
//                   toggleable: false,
//                   onChanged: (dynamic v) => v,
//                 ),
//               ],
//             ),
//           ),
//           CustomRichTextWidget(
//             textSpan: TextSpan(
//               text: notifier.isEmail ? "" : notifier.language.bySigningUpYouAgreeToHyppe! + " ",
//               style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
//               children: [
//                 TextSpan(
//                   text: notifier.isEmail ? "\n" : notifier.language.privacyPolicy! + "\n",
//                   style: Theme.of(context).textTheme.bodyText2!.copyWith(
//                     color: Theme.of(context).colorScheme.primaryVariant,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 TextSpan(
//                   text: notifier.isEmail ? "" : notifier.language.and! + " ",
//                   style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
//                 ),
//                 TextSpan(
//                   text: notifier.isEmail ? "" : notifier.language.termsOfService!,
//                   style: Theme.of(context).textTheme.bodyText2!.copyWith(
//                     color: Theme.of(context).colorScheme.primaryVariant,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
