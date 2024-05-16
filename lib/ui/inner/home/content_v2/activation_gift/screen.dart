import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/activation_gift/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ActivationGiftScreen extends StatefulWidget {
  const ActivationGiftScreen({super.key});

  @override
  State<ActivationGiftScreen> createState() => _ActivationGiftScreenState();
}

class _ActivationGiftScreenState extends State<ActivationGiftScreen> {
  LocalizationModelV2? lang;
  bool isToggled = false;
  double size = 30;
  double innerPadding = 0;


  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'activationgift');
    lang = context.read<TranslateNotifierV2>().translate;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var notifier =
          Provider.of<ActivationGiftNotifier>(context, listen: false);
      notifier.initPage();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivationGiftNotifier>(builder: (context, notifier, _) {
      return Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leading: IconButton(
              onPressed: () => Routing().moveBack(),
              icon: const Icon(Icons.arrow_back_ios)),
          title: CustomTextWidget(
            textStyle: Theme.of(context).textTheme.titleMedium,
            textToDisplay: lang?.contentgift ?? 'Kontent Gift',
          ),
          actions: [
            IconButton(
                onPressed: () => notifier.showButtomSheetInfo(context, lang!),
                icon: const Icon(Icons.info_outline))
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                  textToDisplay: lang?.localeDatetime == 'id' ? 'Aktifkan Gift' : 'Content Gift',
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),  
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: CustomTextWidget(
                        textToDisplay: lang?.localeDatetime == 'id' ? 'Aktifkan fitur kirim gift di kontenmu.' : 'Enable the send gift feature on your content',
                      ),
                    ),
                    GestureDetector(
                    onTap: () async {
                      await notifier.checkPosts(context, mounted);
                      if (!notifier.countContent){
                         if (!mounted) return;
                          notifier.showButtomSheetInfo(context, lang!);
                      }
                    },
                    child: AnimatedContainer(
                      height: size,
                      width: size * 2,
                      padding: EdgeInsets.all(innerPadding),
                      alignment: notifier.giftActivation ? Alignment.centerRight : Alignment.centerLeft,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: notifier.giftActivation ?  kHyppePrimary : Colors.grey.shade300,
                      ),
                      child: Container(
                        width: size - innerPadding * 1.5,
                        height: size - innerPadding * 1.5,
                        margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: notifier.giftActivation ? Colors.white : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
