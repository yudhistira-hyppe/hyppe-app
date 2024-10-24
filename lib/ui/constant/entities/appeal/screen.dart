import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/appeal/notifier.dart';
import 'package:hyppe/ui/constant/entities/appeal/widget/object_content.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

class AppealScreen extends StatefulWidget {
  final ContentData data;
  const AppealScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<AppealScreen> createState() => _AppealScreenState();
}

class _AppealScreenState extends State<AppealScreen> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final noti = Provider.of<AppealNotifier>(context, listen: false);
    noti.initializeData(context, widget.data);
    noti.appealReason = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final translate =
        Provider.of<TranslateNotifierV2>(context, listen: false).translate;
    return Consumer<AppealNotifier>(
      builder: (context, notifier, child) => WillPopScope(
        onWillPop: () async {
          if (globalAliPlayer != null) {
            globalAliPlayer?.play();
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: CustomTextWidget(
              textStyle: Theme.of(context).textTheme.titleMedium,
              textToDisplay: '${translate.contentViolation}',
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: CustomIconWidget(
                      height: 40,
                      iconData: "${AssetPath.vectorPath}report.svg",
                      color: Colors.red,
                      defaultColor: false,
                    ),
                  ),
                  Center(
                    child: CustomTextWidget(
                      textToDisplay: translate.contentViolation ?? '',
                      textStyle: Theme.of(context).primaryTextTheme.titleMedium,
                    ),
                  ),
                  twelvePx,
                  RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleSmall,
                        text:
                            '${translate.yourContentViolatedOurCommunityGuidelinesYouCanFindOurGuidelinesHere}',
                        children: [
                          TextSpan(
                            text: "${translate.communityGuidelines}",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(color: kHyppeCyan),
                          ),
                        ],
                      )),
                  twentyFourPx,
                  OnjectContentWidget(
                    data: widget.data,
                    cat: notifier.getCategory(widget.data.cats),
                    reason: notifier.reason,
                  ),
                  twentyFourPx,
                  const Divider(
                    color: kHyppeLightSurface,
                  ),
                  Text(
                    translate.appeal ?? '',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  twentyPx,
                  Text(translate
                          .ifYouReviewedOurCommunityGuidelinesAndBelieveYourContentWasRemovedByMistakeLetUsKnowBySubmittingAnAppeal ??
                      ''),
                  const Divider(
                    color: kHyppeLightSurface,
                  ),
                  Row(
                    children: [
                      Text(
                        translate.chooseanAppealReason ?? '',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      sixPx,
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.red),
                      )
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notifier.appealReaseonData.length,
                    itemBuilder: (context, index) {
                      return RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        groupValue: notifier.appealReaseonData[index]['title'],
                        value: notifier.appealReason,
                        onChanged: (val) {
                          if (mounted) {
                            notifier.appealReason =
                                notifier.appealReaseonData[index]['title'] ??
                                    '';
                          }
                        },
                        toggleable: true,
                        title: CustomTextWidget(
                          textAlign: TextAlign.left,
                          textToDisplay: notifier.appealReaseonData[index]
                              ['title'],
                          textStyle:
                              Theme.of(context).primaryTextTheme.bodySmall,
                        ),
                        subtitle: CustomTextWidget(
                          textAlign: TextAlign.left,
                          textToDisplay: notifier.appealReaseonData[index]
                              ['desc'],
                          textStyle: Theme.of(context).textTheme.bodySmall,
                          maxLines: 5,
                        ),
                        activeColor: Theme.of(context).colorScheme.primary,
                      );
                    },
                  ),
                  fortyTwoPx,
                  Text(
                    translate.stateYourIssue ?? '',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  CustomTextFormField(
                    inputAreaWidth: SizeConfig.screenWidth!,
                    inputAreaHeight: 75.0 * SizeConfig.scaleDiagonal,
                    textEditingController: notifier.noteAppealController,
                    inputDecoration: InputDecoration(
                      hintText: translate.pleaseprovideadditionaldetails,
                      contentPadding: EdgeInsets.all(0),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLength: 80,
                  ),
                  fortyPx,
                  fortyPx,
                  SizedBox(
                    width: SizeConfig.screenWidth,
                    height: 50,
                    child: CustomTextButton(
                      onPressed: notifier.loadingAppel
                          ? null
                          : notifier.appealReason == ''
                              ? null
                              : () {
                                  notifier.appealPost(context, widget.data);
                                },
                      style: ButtonStyle(
                          backgroundColor: notifier.appealReason == ''
                              ? MaterialStateProperty.all(kHyppeDisabled)
                              : MaterialStateProperty.all(kHyppePrimary)),
                      child: notifier.loadingAppel
                          ? CustomLoading()
                          : CustomTextWidget(
                              textToDisplay: translate.submit ?? '',
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
        ),
      ),
    );
  }
}
