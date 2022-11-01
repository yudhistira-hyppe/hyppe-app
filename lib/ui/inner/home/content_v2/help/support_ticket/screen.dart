import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/support_ticket/notifier.dart';
import 'package:provider/provider.dart';

class SupportTicketScreen extends StatefulWidget {
  const SupportTicketScreen({Key? key}) : super(key: key);

  @override
  State<SupportTicketScreen> createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends State<SupportTicketScreen> {
  @override
  void initState() {
    context.read<SupportTicketNotifier>().getInitSupportTicket(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SupportTicketNotifier, TranslateNotifierV2>(
      builder: (_, supportNotifier, notifier, __) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: CustomTextWidget(
            textStyle: Theme.of(context).textTheme.subtitle1,
            textToDisplay: '${notifier.translate.newTicketIssue}',
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomTextWidget(
                      textToDisplay: notifier.translate.categories!,
                      textAlign: TextAlign.start,
                      textStyle: Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
                    ),
                    sixPx,
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.red),
                    )
                  ],
                ),
                ListTile(
                  onTap: () {
                    supportNotifier.showCategoryTicket(context);
                  },
                  contentPadding: EdgeInsets.zero,
                  title: CustomTextWidget(
                    textToDisplay: supportNotifier.nameCategory != '' ? supportNotifier.nameCategory : notifier.translate.chooseCategoryIssue!,
                    textAlign: TextAlign.start,
                    textStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  minLeadingWidth: 0,
                ),
                Divider(thickness: 1.0, color: Theme.of(context).dividerTheme.color!.withOpacity(0.1)),
                tenPx,
                Row(
                  children: [
                    CustomTextWidget(
                      textToDisplay: 'Level',
                      textAlign: TextAlign.start,
                      textStyle: Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
                    ),
                    sixPx,
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.red),
                    )
                  ],
                ),
                ...List.generate(
                  supportNotifier.levelData.length,
                  (index) => Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        groupValue: supportNotifier.nameLevel,
                        value: supportNotifier.levelData[index].descLevel!,
                        onChanged: (val) {
                          supportNotifier.nameLevel = val!;
                        },
                        toggleable: true,
                        title: CustomTextWidget(
                          textAlign: TextAlign.left,
                          textToDisplay: supportNotifier.levelData[index].descLevel!,
                          textStyle: Theme.of(context).primaryTextTheme.bodyText2,
                        ),
                        subtitle: Text('The condition will appear if the users problem need technical   that can’t be solved by Guideline and will most likely be an improvement or new feature.'),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Theme.of(context).colorScheme.primaryVariant,
                        isThreeLine: true,
                      )),
                ),
                fortyTwoPx,
                CustomTextWidget(
                  textToDisplay: notifier.translate.description!,
                  textAlign: TextAlign.start,
                  textStyle: Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
                ),
                TextFormField(
                  minLines: 1,
                  maxLines: 2,
                  maxLength: 80,
                  validator: (String? input) {
                    if (input?.isEmpty ?? true) {
                      return "Please enter message";
                    } else {
                      return null;
                    }
                  },
                  keyboardAppearance: Brightness.dark,
                  cursorColor: const Color(0xff8A3181),
                  // controller: notifier.captionController,
                  textInputAction: TextInputAction.newline,
                  style: Theme.of(context).primaryTextTheme.caption,
                  decoration: InputDecoration(
                    errorBorder: InputBorder.none,
                    hintStyle: Theme.of(context).textTheme.caption,
                    focusedErrorBorder: InputBorder.none,
                    hintText: "${notifier.translate.insertAnyAdditionalInfo}",
                    contentPadding: const EdgeInsets.only(bottom: 5),
                  ),
                  onChanged: (value) {
                    // notifier.showAutoComplete(value, context);
                  },
                ),
                Row(
                  children: const [
                    CustomIconWidget(iconData: "${AssetPath.vectorPath}storage.svg"),
                    twentyFourPx,
                    CustomIconWidget(iconData: "${AssetPath.vectorPath}sisipkan.svg"),
                  ],
                ),
                twentyPx,
                SizedBox(
                  width: SizeConfig.screenWidth,
                  child: CustomTextButton(
                    onPressed: () {
                      // notifier.navigateToWithDrawal();
                      // notifier.initBankAccount(context);
                    },
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppePrimary)),
                    child: CustomTextWidget(
                      textToDisplay: notifier.translate.submit!,
                      textStyle: Theme.of(context).textTheme.button!.copyWith(color: kHyppeLightButtonText),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
