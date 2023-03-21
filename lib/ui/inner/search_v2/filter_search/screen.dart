import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class FilterSearchScreen extends StatelessWidget {
  const FilterSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    FirebaseCrashlytics.instance.setCustomKey('layout', 'FilterSearchScreen');
    return Consumer<SearchNotifier>(
      builder: (context, notifier, child) => Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Routing().moveBack(),
            child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}close.svg"),
          ),
          title: CustomTextWidget(
            textToDisplay: notifier.language.filters ?? 'filters',
            textStyle: Theme.of(context).primaryTextTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
          ),
          actions: [
            CustomTextButton(
              child: CustomTextWidget(
                textToDisplay: "Reset",
                textStyle: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold, color: kHyppePrimary),
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: 0, // _genders.length,
              padding: const EdgeInsets.all(0),
              itemBuilder: (context, index) {
                return RadioListTile<String>(
                  groupValue: "", //_genders[index],
                  value: "", //_value,
                  onChanged: (value) {
                    // setState(() {
                    //   _value = _genders[index];
                    //   widget.onChange(_genders[index]);
                    // });
                  },
                  toggleable: true,
                  activeColor: Theme.of(context).colorScheme.primary,
                  title: CustomTextWidget(
                    textAlign: TextAlign.left,
                    textToDisplay: "", //_genders[index],
                    textStyle: Theme.of(context).primaryTextTheme.bodyText1,
                  ),
                  controlAffinity: ListTileControlAffinity.trailing,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
