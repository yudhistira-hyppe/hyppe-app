import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/constants/size_config.dart';
import '../../../../../../inner/upload/preview_content/notifier.dart';
import '../../../../../widget/custom_text_button.dart';
import '../../../../../widget/custom_text_widget.dart';

class MusicTabsScreen extends StatefulWidget {
  const MusicTabsScreen({Key? key}) : super(key: key);

  @override
  State<MusicTabsScreen> createState() => _MusicTabsScreenState();
}

class _MusicTabsScreenState extends State<MusicTabsScreen> {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreviewContentNotifier>(context);
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        eightPx,
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CustomTextWidget(
                      textAlign: TextAlign.center,
                      textToDisplay: notifier.language.popular ?? '',
                      textStyle: TextStyle(fontSize: 14, color: notifier.pageMusic == 0 ? Theme.of(context).colorScheme.primaryVariant : Theme.of(context).tabBarTheme.unselectedLabelColor),
                    ),
                  ],
                ),
                onPressed: () => notifier.pageMusic = 0,
              ),
              SizedBox(
                height: 2 * SizeConfig.scaleDiagonal,
                width: 125 * SizeConfig.scaleDiagonal,
                child: Container(color: notifier.pageMusic == 0 ? Theme.of(context).colorScheme.primaryVariant : null),
              ),
            ],
          ),
        ),
        eightPx,
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CustomTextWidget(
                      textAlign: TextAlign.center,
                      textToDisplay: notifier.language.explore ?? '',
                      textStyle: TextStyle(fontSize: 14, color: notifier.pageMusic == 1 ? Theme.of(context).colorScheme.primaryVariant : Theme.of(context).tabBarTheme.unselectedLabelColor),
                    ),
                  ],
                ),
                onPressed: () => notifier.pageMusic = 1,
              ),
              SizedBox(
                height: 2 * SizeConfig.scaleDiagonal,
                width: 125 * SizeConfig.scaleDiagonal,
                child: Container(color: notifier.pageMusic == 1 ? Theme.of(context).colorScheme.primaryVariant : null),
              ),
            ],
          ),
        ),
        eightPx
      ],
    );
  }
}
