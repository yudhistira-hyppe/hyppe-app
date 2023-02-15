import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_switch_button.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class OnPrivacyPostBottomSheet extends StatefulWidget {
  final String value;
  final Function() onSave;
  final Function() onCancel;

  final Function(String value, String code) onChange;

  const OnPrivacyPostBottomSheet({
    Key? key,
    required this.value,
    required this.onSave,
    required this.onChange,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<OnPrivacyPostBottomSheet> createState() => _OnPrivacyPostBottomSheetState();
}

class _OnPrivacyPostBottomSheetState extends State<OnPrivacyPostBottomSheet> {
  var privacy = [];
  final _language = TranslateNotifierV2();
  String _currentPrivacy = "";
  static final _routing = Routing();
  BuildContext? scaffoldContext;
  @override
  void initState() {
    super.initState();
    _currentPrivacy = widget.value;
    // privacy = ["${_language.translate.public}", "${_language.translate.friends}", "${_language.translate.onlyMe}"];
    privacy = [
      {"title": "${_language.translate.public}", "subtitle": '${_language.translate.anyoneCanView}', "icon": 'globe.svg', 'code': 'PUBLIC'},
      // {"title": "${_language.translate.friends}", "subtitle": '${_language.translate.onlyFriendsCanView}', "icon": 'friend.svg', 'code': 'FRIEND'},
      {"title": "${_language.translate.onlyMe}", "subtitle": '${_language.translate.onlyYouCanView}', "icon": 'person.svg', 'code': 'PRIVATE'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    scaffoldContext = context;
    final textTheme = Theme.of(context).textTheme;
    return Consumer<PreUploadContentNotifier>(
      builder: (context, notifier, child) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          leading: GestureDetector(
              onTap: widget.onCancel,
              child: Icon(
                Icons.clear_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              )),
          title: CustomTextWidget(
            textToDisplay: 'Privacy',
            textStyle: textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(
                textToDisplay: 'Content Privacy',
                textStyle: textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.onBackground),
                textAlign: TextAlign.start,
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: privacy.length,
                itemBuilder: (context, index) {
                  return RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    groupValue: privacy[index]['code'],
                    value: _currentPrivacy,
                    onChanged: (_) {
                      if (mounted) {
                        setState(() {
                          _currentPrivacy = privacy[index]['code'];
                          widget.onChange(privacy[index]['title'], privacy[index]['code']);
                        });
                      }
                    },
                    toggleable: true,
                    title: CustomTextWidget(
                      textAlign: TextAlign.left,
                      textToDisplay: privacy[index]['title'],
                      textStyle: Theme.of(context).primaryTextTheme.titleMedium,
                    ),
                    subtitle: CustomTextWidget(
                      textAlign: TextAlign.left,
                      textToDisplay: privacy[index]['subtitle'],
                      textStyle: Theme.of(context).primaryTextTheme.subtitle2,
                    ),
                    secondary: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomIconWidget(
                        defaultColor: true,
                        iconData: '${AssetPath.vectorPath}${privacy[index]['icon']}',
                        width: 30,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    activeColor: Theme.of(context).colorScheme.primary,
                  );
                },
              ),

              //-===== Allow Comment =========--
              const Divider(color: kHyppeBgNotSolve, height: 20),

              CustomTextWidget(textToDisplay: notifier.language.comment ?? '', textStyle: const TextStyle(color: kHyppeTextLightPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
              sixteenPx,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        notifier.allowComment = !notifier.allowComment;
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _language.translate.allowComment ?? '',
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(
                                  color: const Color.fromRGBO(63, 63, 63, 1),
                                ),
                          ),
                          fourPx,
                          Text(
                            _language.translate.descAllowComment ?? '',
                            style: Theme.of(context).textTheme.caption?.copyWith(
                                  color: kHyppeSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  CustomSwitchButton(
                    value: notifier.allowComment,
                    onChanged: (value) => notifier.allowComment = value,
                  ),
                ],
              ),
              //-===== Allow Sharing =========--
              const Divider(color: kHyppeBgNotSolve, height: 20),
              CustomTextWidget(textToDisplay: notifier.language.sharePost ?? '', textStyle: const TextStyle(color: kHyppeTextLightPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
              sixteenPx,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        notifier.isShared = !notifier.isShared;
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _language.translate.allowSharing ?? '',
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(
                                  color: const Color.fromRGBO(63, 63, 63, 1),
                                ),
                          ),
                          fourPx,
                          Text(
                            _language.translate.descAllowSharing ?? '',
                            style: Theme.of(context).textTheme.caption?.copyWith(
                                  color: kHyppeSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  CustomSwitchButton(
                    value: notifier.isShared,
                    onChanged: (value) => notifier.isShared = value,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
