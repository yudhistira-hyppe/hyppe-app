import 'package:hyppe/core/arguments/update_contents_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/build_auto_complete_user_tag.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/build_category.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/validate_type.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class PreUploadContentScreen extends StatefulWidget {
  final UpdateContentsArgument arguments;

  const PreUploadContentScreen({Key? key, required this.arguments}) : super(key: key);

  @override
  _PreUploadContentScreenState createState() => _PreUploadContentScreenState();
}

class _PreUploadContentScreenState extends State<PreUploadContentScreen> {
  Widget _buildDivider(context) => Divider(thickness: 1.0, color: Theme.of(context).dividerTheme.color!.withOpacity(0.1));
  bool autoComplete = false;
  String search = '';

  @override
  void dispose() {
    super.dispose();
  }

  // @override
  // void initState() {
  //   final _notifier = context.read<PreUploadContentNotifier>();
  //   // Provider.of<PreUploadContentNotifier>(context, listen: false);
  //   _notifier.setUpdateArguments = widget.arguments;
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    // Provider.of<PreUploadContentNotifier>(context);
    SizeConfig().init(context);
    final textTheme = Theme.of(context).textTheme;
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return Consumer<PreUploadContentNotifier>(
      builder: (context, notifier, child) => GestureDetector(
        onTap: () => notifier.checkKeyboardFocus(context),
        child: WillPopScope(
          onWillPop: () {
            notifier.onWillPop(context);
            return Future.value(true);
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              elevation: 0,
              centerTitle: false,
              leading: CustomIconButtonWidget(
                onPressed: () => notifier.onWillPop(context),
                defaultColor: false,
                iconData: "${AssetPath.vectorPath}back-arrow.svg",
                color: Theme.of(context).colorScheme.onSurface,
              ),
              title: CustomTextWidget(
                textToDisplay: widget.arguments.onEdit ? "${notifier.language.edit} ${notifier.language.post}" : notifier.language.newPost!,
                textStyle: textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.transparent,
            ),
            body: SingleChildScrollView(
              child: Container(
                // width: SizeConfig.screenWidth,
                // height: SizeConfig.screenHeight,

                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        loadingCompress(notifier.progressCompress),
                        // Text("${notifier.progressCompress}"),
                        // Text("${notifier.videoSize / 1000000} mb"),
                        captionWidget(textTheme, notifier),
                        sixteenPx,
                        _buildDivider(context),
                        twentyFourPx,
                        categoryWidget(textTheme, notifier),
                        _buildDivider(context),
                        twentyFourPx,
                        tagPeopleWidget(textTheme, notifier),
                        _buildDivider(context),
                        tagLocationWidget(textTheme, notifier),
                        _buildDivider(context),
                        eightPx,
                        privacyWidget(textTheme, notifier),
                        _buildDivider(context),
                        eightPx,
                        notifier.featureType != FeatureType.story ? ownershipSellingWidget(textTheme, notifier) : const SizedBox(),
                        notifier.certified ? detailTotalPrice(notifier) : Container(),
                        SizedBox(height: 20 * SizeConfig.scaleDiagonal),

                        twentyFourPx,
                        twentyFourPx,
                        twentyFourPx,
                      ],
                    ),
                    AutoCompleteUserTag(),
                  ],
                ),
              ),
            ),
            backgroundColor: Theme.of(context).backgroundColor,
            floatingActionButton: Visibility(
              visible: !keyboardIsOpen,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: CustomElevatedButton(
                  width: 375.0 * SizeConfig.scaleDiagonal,
                  height: 44.0 * SizeConfig.scaleDiagonal,
                  // function: () => notifier.onClickPost(
                  //   context,
                  //   onEdit: widget.arguments.onEdit,
                  //   data: widget.arguments.contentData,
                  //   content: widget.arguments.content,
                  // ),
                  function: () {
                    if (SharedPreference().readStorage(SpKeys.statusVerificationId) != VERIFIED || notifier.featureType == FeatureType.story || widget.arguments.onEdit) {
                      notifier.onClickPost(
                        context,
                        onEdit: widget.arguments.onEdit,
                        data: widget.arguments.contentData,
                        content: widget.arguments.content,
                      );
                    } else {
                      !notifier.certified
                          ? notifier.onShowStatement(context, onCancel: () {
                              notifier.onClickPost(
                                context,
                                onEdit: widget.arguments.onEdit,
                                data: widget.arguments.contentData,
                                content: widget.arguments.content,
                              );
                            })
                          : notifier.onClickPost(
                              context,
                              onEdit: widget.arguments.onEdit,
                              data: widget.arguments.contentData,
                              content: widget.arguments.content,
                            );
                    }
                  },
                  child: widget.arguments.onEdit && notifier.updateContent
                      ? const CustomLoading()
                      : CustomTextWidget(
                          textToDisplay: widget.arguments.onEdit ? notifier.language.save : notifier.language.confirm!,
                          textStyle: textTheme.button?.copyWith(color: kHyppeLightButtonText),
                        ),
                  buttonStyle: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                    shadowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                    overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          ),
        ),
      ),
    );
  }

  Widget captionWidget(TextTheme textTheme, PreUploadContentNotifier notifier) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomTextWidget(
              textToDisplay: notifier.language.caption!,
              textStyle: textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.red),
            )
          ],
        ),
        eightPx,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 8,
              child: TextFormField(
                minLines: 5,
                maxLines: 10,
                maxLength: 2500,
                validator: (String? input) {
                  if (input?.isEmpty ?? true) {
                    return "Please enter message";
                  } else {
                    return null;
                  }
                },
                keyboardAppearance: Brightness.dark,
                cursorColor: const Color(0xff8A3181),
                controller: notifier.captionController,
                textInputAction: TextInputAction.newline,
                style: textTheme.bodyText2?.copyWith(),
                decoration: InputDecoration(
                    errorBorder: InputBorder.none,
                    hintStyle: textTheme.caption,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    hintText: "${notifier.language.addPostDescription}",
                    contentPadding: const EdgeInsets.only(bottom: 5),
                    counterText: ""),
                onChanged: (value) {
                  notifier.showAutoComplete(value, context);
                },
              ),
            ),
            ValidateType(editContent: widget.arguments.onEdit)
          ],
        ),
        Row(
          children: [
            CustomElevatedButton(
                child: CustomTextWidget(
                  textToDisplay: '#Hastag',
                  textStyle: textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
                ),
                width: 90,
                height: 30,
                function: () {
                  final text = notifier.captionController.text;
                  final selection = notifier.captionController.selection;

                  final newText = text.replaceRange(selection.start, selection.end, ' #');
                  notifier.captionController.value = TextEditingValue(
                    text: newText,
                    selection: TextSelection.collapsed(offset: selection.baseOffset + 2),
                  );
                },
                buttonStyle: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                  shadowColor: MaterialStateProperty.all(Colors.white),
                  elevation: MaterialStateProperty.all(0),
                  side: MaterialStateProperty.all(
                    BorderSide(color: kHyppeLightInactive1, width: 1.0, style: BorderStyle.solid),
                  ),
                )),
            eightPx,
            CustomElevatedButton(
                child: CustomTextWidget(
                  textToDisplay: '@Friends',
                  textStyle: textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
                ),
                width: 90,
                height: 30,
                function: () {
                  final text = notifier.captionController.text;
                  final selection = notifier.captionController.selection;

                  final newText = text.replaceRange(selection.start, selection.end, ' @');
                  notifier.captionController.value = TextEditingValue(
                    text: newText,
                    selection: TextSelection.collapsed(offset: selection.baseOffset + 2),
                  );
                },
                buttonStyle: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                  shadowColor: MaterialStateProperty.all(Colors.white),
                  elevation: MaterialStateProperty.all(0),
                  side: MaterialStateProperty.all(
                    BorderSide(color: kHyppeLightInactive1, width: 1.0, style: BorderStyle.solid),
                  ),
                )),
          ],
        ),
      ],
    );
  }

  Widget categoryWidget(TextTheme textTheme, PreUploadContentNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomTextWidget(
              textToDisplay: notifier.language.categories!,
              textStyle: textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.red),
            )
          ],
        ),
        eightPx,
        Wrap(
          children: [
            ...List.generate(
              notifier.interest.length,
              (index) => Padding(
                padding: const EdgeInsets.all(2.0),
                child: CustomTextButton(
                  onPressed: () {
                    notifier.insertInterest(context, index);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: PickitemTitle(
                    title: notifier.interest[index].interestName,
                    select: notifier.pickedInterest(notifier.interest[index].interestName) ? true : false,
                    button: false,
                    textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: notifier.pickedInterest(notifier.interest[index].interestName) ? kHyppeLightSurface : Theme.of(context).colorScheme.onBackground,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget tagPeopleWidget(TextTheme textTheme, PreUploadContentNotifier notifier) {
    return notifier.userTagData.isEmpty
        ? ListTile(
            onTap: () {
              notifier.showPeopleSearch(context);
            },
            contentPadding: EdgeInsets.zero,
            title: CustomTextWidget(
              textToDisplay: notifier.language.tagPeople,
              textAlign: TextAlign.start,
              textStyle: textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
            ),
            minLeadingWidth: 0,
          )
        : Container(
            height: 44.0,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                ...List.generate(
                  notifier.userTagData.length,
                  (index) => Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: CustomTextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, splashFactory: NoSplash.splashFactory),
                      child: PickitemTitle(
                        function: () => notifier.removeTagPeople(index),
                        title: '@' + notifier.userTagData[index],
                        select: notifier.pickedInterest(notifier.userTagData[index]) ? true : false,
                        button: true,
                        textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () => notifier.showPeopleSearch(context),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(color: kHyppeLightInactive2, borderRadius: BorderRadius.circular(1000)),
                      child: Icon(
                        Icons.add,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget tagLocationWidget(TextTheme textTheme, PreUploadContentNotifier notifier) {
    return ListTile(
      onTap: () {
        notifier.showLocation(context);
      },
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.secondaryVariant),
      title: CustomTextWidget(
        textToDisplay: notifier.locationName,
        textAlign: TextAlign.start,
        textStyle: textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
      ),
      trailing: notifier.locationName == notifier.language.addLocation!
          ? const Icon(Icons.arrow_forward_ios_rounded)
          : GestureDetector(
              onTap: () {
                notifier.locationName = notifier.language.addLocation!;
              },
              child: const Icon(Icons.close)),
      minLeadingWidth: 0,
    );
  }

  Widget privacyWidget(TextTheme textTheme, PreUploadContentNotifier notifier) {
    return ListTile(
      onTap: () => notifier.onClickPrivacyPost(context),
      title: CustomTextWidget(
        textToDisplay: notifier.language.privacy!,
        textStyle: textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
        textAlign: TextAlign.start,
      ),
      contentPadding: EdgeInsets.zero,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextWidget(
            textToDisplay: notifier.privacyTitle,
            textStyle: textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
          ),
          twentyPx,
          const Icon(Icons.arrow_forward_ios_rounded),
        ],
      ),
    );
  }

  Widget ownershipSellingWidget(TextTheme textTheme, PreUploadContentNotifier notifier) {
    return ListTile(
      onTap: () => !notifier.certified
          ? System().actionReqiredIdCard(context, action: () {
              notifier.navigateToOwnership(context);
            })
          : notifier.navigateToOwnership(context),
      title: CustomTextWidget(
        textToDisplay: notifier.language.ownershipSelling!,
        textStyle: textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
        textAlign: TextAlign.start,
      ),
      contentPadding: EdgeInsets.zero,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextWidget(
            textToDisplay: notifier.certified ? notifier.language.yes! : notifier.language.no!,
            textStyle: textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
          ),
          twentyPx,
          const Icon(Icons.arrow_forward_ios_rounded),
        ],
      ),
    );
  }

  Widget detailTotalPrice(PreUploadContentNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: Column(
        children: [
          detailText('Certificate Ownership Fee', 'Rp 15.000'),
          sixteenPx,
          detailText('Discount', 'Rp 15.000'),
          sixteenPx,
          detailText('Total Price', 'Rp 0'),
          notifier.toSell
              ? const Divider(
                  height: 30,
                  color: kHyppeLightIcon,
                )
              : Container(),
          notifier.toSell
              ? Column(
                  children: [
                    detailText('Sell Content', notifier.toSell ? 'Yes' : 'No'),
                    sixteenPx,
                    detailText('Include Total Views', notifier.includeTotalViews ? 'Yes' : 'No'),
                    sixteenPx,
                    detailText('Include Total Likes', notifier.includeTotalLikes ? 'Yes' : 'No'),
                    sixteenPx,
                    detailText('Sell Price', 'Rp ' + notifier.priceController.text),
                  ],
                )
              : Container()
        ],
      ),
    );
  }

  Widget detailText(text1, text2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [CustomTextWidget(textToDisplay: text1), CustomTextWidget(textToDisplay: text2)],
    );
  }

  Widget loadingCompress(progressCompress) {
    return progressCompress > 0 && progressCompress < 100
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Loading .."),
              ClipRRect(
                borderRadius: BorderRadius.circular(40.0),
                child: LinearProgressIndicator(
                  value: progressCompress / 100,
                  minHeight: 5,
                  backgroundColor: Theme.of(context).textTheme.button!.color!.withOpacity(0.4),
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primaryVariant),
                ),
              ),
              sixPx,
            ],
          )
        : const SizedBox();
  }
}
