import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/appeal/notifier.dart';
import 'package:hyppe/ui/constant/entities/appeal/widget/object_content.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class SuccessAppeal extends StatelessWidget {
  final ContentData data;
  const SuccessAppeal({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate =
        Provider.of<TranslateNotifierV2>(context, listen: false).translate;
    return Consumer<AppealNotifier>(
      builder: (context, notifier, child) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: CustomTextWidget(
            textStyle: Theme.of(context).textTheme.titleMedium,
            textToDisplay: '${translate.contentViolation}',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Center(
                child: CustomIconWidget(
                  height: 40,
                  iconData: "${AssetPath.vectorPath}valid-thin.svg",
                  defaultColor: false,
                ),
              ),
              twentyPx,
              Text(
                translate.congrats ?? '',
                style: Theme.of(context)
                    .primaryTextTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Center(
                  child: Text(
                translate.weWillSendYouaNotificationasSoonasweHaveanUpdate ??
                    '',
                textAlign: TextAlign.center,
              )),
              twentyPx,
              OnjectContentWidget(
                data: data,
                cat: notifier.getCategory(data.cats),
                reason: notifier.reason,
                isCategory: false,
              ),
              const Spacer(),
              SizedBox(
                width: SizeConfig.screenWidth,
                height: 50,
                child: CustomTextButton(
                  onPressed: () {
                    Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
                  },
                  style: ButtonStyle(
                      backgroundColor: notifier.appealReason == ''
                          ? MaterialStateProperty.all(kHyppeDisabled)
                          : MaterialStateProperty.all(kHyppePrimary)),
                  child: CustomTextWidget(
                    textToDisplay: translate.backToHome ?? '',
                    textStyle: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: kHyppeLightButtonText),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
