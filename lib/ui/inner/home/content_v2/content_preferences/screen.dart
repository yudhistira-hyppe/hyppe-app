import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

class ContentPreferencesScreen extends StatefulWidget {
  const ContentPreferencesScreen({super.key});

  @override
  State<ContentPreferencesScreen> createState() => _ContentPreferencesScreenState();
}

class _ContentPreferencesScreenState extends State<ContentPreferencesScreen> {
  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    return Scaffold(
      appBar: AppBar(
        title: CustomTextWidget(
          textToDisplay: 'Pengaturan',
          textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg"),
          splashRadius: 1,
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomTextWidget(textToDisplay: '${language.contentPreferences}'),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: (SizeConfig.screenWidth! / 2) - 40,
                        child: Image.asset('${AssetPath.pngPath}default.png'),
                      ),
                      sixPx,
                      SizedBox(
                        height: 10,
                        width: 10,
                        child: Radio(
                          groupValue: 'preferensi',
                          value: "1",
                          onChanged: (val) {},
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: (SizeConfig.screenWidth! / 2) - 40,
                        child: Image.asset(
                          '${AssetPath.pngPath}custome.png',
                        ),
                      ),
                      SizedBox(
                        height: 10,
                        width: 10,
                        child: Radio(
                          groupValue: 'preferensi',
                          value: "1",
                          onChanged: (val) {},
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
