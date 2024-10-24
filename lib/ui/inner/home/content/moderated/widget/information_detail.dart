import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InformationDetail extends StatefulWidget {
  const InformationDetail({Key? key}) : super(key: key);

  @override
  _InformationDetailState createState() => _InformationDetailState();
}

class _InformationDetailState extends State<InformationDetail> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    FirebaseCrashlytics.instance.setCustomKey('layout', 'InformationDetail');
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVisibilityCard(),
          sixteenPx,
          _buildContentPolicy(),
          fortyPx,
          _buildButton(),
        ],
      ),
    );
  }

  Widget _buildVisibilityCard() {
    return Container(
      height: 91,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomIconWidget(
                defaultColor: false,
                iconData: "${AssetPath.vectorPath}info-moderate.svg",
              ),
              eightPx,
              CustomTextWidget(
                textAlign: TextAlign.left,
                textToDisplay: 'Visibility',
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              )
            ],
          ),
          eightPx,
          CustomTextWidget(
              maxLines: 2,
              textAlign: TextAlign.left,
              textStyle: Theme.of(context).textTheme.bodyMedium,
              textToDisplay:
                  'Your content contains pornographic or violent content so we have to block your content.')
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: Theme.of(context).colorScheme.surface),
    );
  }

  Widget _buildButton() {
    return CustomElevatedButton(
      height: 50,
      function: () => Routing().moveBack(),
      width: MediaQuery.of(context).size.width,
      buttonStyle: Theme.of(context).elevatedButtonTheme.style?.copyWith(
          backgroundColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.background),
          overlayColor:
              MaterialStateProperty.all(Theme.of(context).colorScheme.surface),
          side: MaterialStateProperty.all(
              BorderSide(color: Theme.of(context).colorScheme.primary))),
      child: CustomTextWidget(
        textToDisplay: context.read<TranslateNotifierV2>().translate.back ?? "",
        textStyle: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Widget _buildContentPolicy() {
    return Text.rich(
      TextSpan(
        text: 'Content Policy\n\n',
        children: [
          TextSpan(
            text:
                'Explicit content meant to be sexually gratifying is not allowed on Hyppe. Posting pornography may result in content removal. Videos containing fetish content will be removed or age-restricted. In most cases, violent, graphic, or humiliating fetishes are not allowed on Hyppe.\n\n',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          TextSpan(
            text:
                "If you find content that violates this policy, report it. If you've found a few videos or comments that you would like to report, you can report the content.\n\n",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          TextSpan(
            text:
                "Sexually explicit content featuring minors and content that sexually exploits minors is not allowed on Hyppe. We report content containing child sexual abuse imagery to the National Center for Missing and Exploited Children, who work with global law enforcement agencies.",
            style: Theme.of(context).textTheme.bodyMedium,
          )
        ],
      ),
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('class', 'InformationDetail');
    super.initState();
  }
}
