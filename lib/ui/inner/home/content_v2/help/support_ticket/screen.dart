import 'package:flutter/material.dart';
// import 'package:path/path.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/support_ticket/notifier.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class SupportTicketScreen extends StatefulWidget {
  const SupportTicketScreen({Key? key}) : super(key: key);

  @override
  State<SupportTicketScreen> createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends State<SupportTicketScreen> {
  @override
  void initState() {
    final notifier = Provider.of<SupportTicketNotifier>(context, listen: false);
    notifier.getInitSupportTicket(context);
    notifier.descriptionController.clear();
    notifier.idCategory = '';
    notifier.idLevelTicket = '';
    notifier.pickedSupportingDocs = [];
    notifier.nameCategory = '';
    notifier.nameLevel = '';
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
                      textToDisplay: notifier.translate.categories ?? 'category',
                      textAlign: TextAlign.start,
                      textStyle: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
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
                    textToDisplay: supportNotifier.nameCategory != '' ? supportNotifier.nameCategory : notifier.translate.chooseCategoryIssue ?? '',
                    textAlign: TextAlign.start,
                    textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  minLeadingWidth: 0,
                ),
                Divider(thickness: 1.0, color: Theme.of(context).dividerTheme.color?.withOpacity(0.1)),
                tenPx,
                Row(
                  children: [
                    CustomTextWidget(
                      textToDisplay: 'Level',
                      textAlign: TextAlign.start,
                      textStyle: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
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
                        value: supportNotifier.levelData[index].descLevel ?? '',
                        onChanged: (val) {
                          supportNotifier.nameLevel = val ?? '';
                          supportNotifier.idLevelTicket = supportNotifier.levelData[index].sId ?? '';
                        },
                        toggleable: true,
                        title: CustomTextWidget(
                          textAlign: TextAlign.left,
                          textToDisplay: supportNotifier.levelData[index].descLevel ?? '',
                          textStyle: Theme.of(context).primaryTextTheme.bodyText2,
                        ),
                        subtitle: Text('The condition will appear if the users problem need technical that can’t be solved by Guideline and will most likely be an improvement or new feature.'),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Theme.of(context).colorScheme.primaryVariant,
                        isThreeLine: true,
                      )),
                ),
                fortyTwoPx,
                CustomTextWidget(
                  textToDisplay: notifier.translate.description ?? '',
                  textAlign: TextAlign.start,
                  textStyle: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
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
                  controller: supportNotifier.descriptionController,
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
                  children: [
                    GestureDetector(onTap: () => supportNotifier.onPickSupportedDocument(context, mounted), child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}storage.svg")),
                    twentyFourPx,
                    // GestureDetector(onTap: () => supportNotifier.onPickSupportedDocument(context, mounted, pdf: true), child: CustomIconWidget(iconData: "${AssetPath.vectorPath}sisipkan.svg")),
                  ],
                ),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: supportNotifier.pickedSupportingDocs?.length ?? 0,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(path.basename(supportNotifier.pickedSupportingDocs?[index].path ?? '')),
                    // subtitle: Text(supportNotifier.pickedSupportingDocs[index].lengthSync().toString()),
                    // leading: Image.file(supportNotifier.pickedSupportingDocs[index]),
                    trailing: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (supportNotifier.pickedSupportingDocs != null) {
                            supportNotifier.pickedSupportingDocs?.removeAt(index);
                          }
                        });
                      },
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(border: Border.all(color: kHyppePrimary), borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            notifier.translate.delete ?? 'delete',
                            style: const TextStyle(color: kHyppePrimary),
                          )),
                    ),
                  ),
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      color: Colors.black12,
                    );
                  },
                ),
                (supportNotifier.pickedSupportingDocs?.length ?? 0) > 1
                    ? const Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text('Max 4 Files'),
                      )
                    : Container(),
                twentyPx,
                SizedBox(
                  width: SizeConfig.screenWidth,
                  height: 50,
                  child: CustomTextButton(
                    onPressed: supportNotifier.enableButton()
                        ? supportNotifier.isLoadingCreate
                            ? null
                            : () {
                                supportNotifier.createTicket(context);
                              }
                        : null,
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(supportNotifier.enableButton() ? kHyppePrimary : kHyppeDisabled)),
                    child: supportNotifier.isLoadingCreate
                        ? const CustomLoading(
                            size: 4,
                          )
                        : CustomTextWidget(
                            textToDisplay: notifier.translate.submit ?? 'submit',
                            textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText),
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
