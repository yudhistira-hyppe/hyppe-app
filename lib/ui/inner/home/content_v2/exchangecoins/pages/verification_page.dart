// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_verification_code/flutter_verification_code.dart';
// import 'package:hyppe/core/constants/asset_path.dart';
// import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
// import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
// import 'package:hyppe/initial/hyppe/translate_v2.dart';
// import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
// import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
// import 'package:hyppe/ui/constant/widget/loading_screen.dart';
// import 'package:hyppe/ux/path.dart';
// import 'package:hyppe/ux/routing.dart';
// import 'package:provider/provider.dart';

// class VerificationPinPage extends StatefulWidget {
//   const VerificationPinPage({super.key});

//   @override
//   State<VerificationPinPage> createState() => _VerificationPinPageState();
// }

// class _VerificationPinPageState extends State<VerificationPinPage> {
//   LocalizationModelV2? lang;
//   TextEditingController textEditingController = TextEditingController();

//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//   final formKey = GlobalKey<FormState>();
//   bool _onEditing = true;
//   String? pincode;

//   @override
//   void initState() {
//     FirebaseCrashlytics.instance.setCustomKey('layout', 'verificationpage');
//     lang = context.read<TranslateNotifierV2>().translate;
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   Future<void> verificationProccess() async {
//     LoadingScreen.show(context, lang?.processing??'Memproses');
//     Future.delayed(const Duration(seconds: 5), () {
//       LoadingScreen.hide(context);
//       Navigator.pop(context);
//       Navigator.pushReplacementNamed(context, Routes.finishTrxPage);
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(
//         titleSpacing: 0,
//         leading: IconButton(onPressed: () => Routing().moveBack(), icon: const Icon(Icons.arrow_back_ios)),
//         title: CustomTextWidget(
//           textStyle: theme.textTheme.titleMedium,
//           textToDisplay: '${lang?.pinverification}',
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const SizedBox(height: kToolbarHeight * 2,),
//             const CustomIconWidget(
//               iconData: "${AssetPath.vectorPath}pin-icon.svg",
//               defaultColor: false,
//             ),
//             Text(
//               'Masukkan PIN Kamu',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold
//               ),
//             ),
//             Text(
//               'Masukkan 6 digit Hyppe PIN Kamu',
//               style: Theme.of(context).textTheme.titleSmall?.copyWith(),
//             ),
//             Form(
//                 key: formKey,
//                 child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 8.0, horizontal: 30),
//                     child: VerificationCode(
//                       isSecure: true,
//                       textStyle: const TextStyle(fontSize: 18.0),
//                       keyboardType: TextInputType.number,
//                       underlineColor: kHyppePrimary,
//                       length: 6,
//                       cursorColor: kHyppePrimary,
//                       onCompleted: (String value) {
//                         setState(() {
//                           pincode = value;
//                         });
//                         verificationProccess();
//                       },
//                       onEditing: (bool value) {
//                         setState(() {
//                           _onEditing = value;
//                         });
//                         if (!_onEditing) FocusScope.of(context).unfocus();
//                       },
//                     ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }