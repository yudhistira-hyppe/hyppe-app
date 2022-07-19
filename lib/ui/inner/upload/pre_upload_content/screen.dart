import 'package:hyppe/core/arguments/update_contents_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_switch_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/build_auto_complete_user_tag.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/build_category.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/validate_type.dart';
import 'package:flutter/material.dart';
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
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<PreUploadContentNotifier>(context, listen: false).onGetInterest(context);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final textTheme = Theme.of(context).textTheme;
    return Consumer<PreUploadContentNotifier>(
      builder: (_, notifier, __) => GestureDetector(
        onTap: () => notifier.checkKeyboardFocus(context),
        child: WillPopScope(
          onWillPop: () {
            notifier.onWillPop(context);
            return Future.value(true);
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
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
                        Row(
                          children: [
                            CustomTextWidget(
                              textToDisplay: "Caption ",
                              textStyle: textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Selector<SelfProfileNotifier, UserProfileModel?>(
                            //   selector: (_, select) => select.user.profile,
                            //   builder: (_, notifier, __) {
                            //     return CustomCacheImage(
                            //       imageUrl: '${System().showUserPicture(notifier?.avatar?.mediaEndpoint)}',
                            //       imageBuilder: (context, imageProvider) => Container(
                            //         height: 42 * SizeConfig.scaleDiagonal,
                            //         width: 42 * SizeConfig.scaleDiagonal,
                            //         decoration: BoxDecoration(
                            //           shape: BoxShape.circle,
                            //           image: DecorationImage(
                            //             image: imageProvider,
                            //             fit: BoxFit.cover,
                            //           ),
                            //         ),
                            //       ),
                            //       errorWidget: (context, url, error) => Container(
                            //         height: 42 * SizeConfig.scaleDiagonal,
                            //         width: 42 * SizeConfig.scaleDiagonal,
                            //         decoration: const BoxDecoration(
                            //           image: DecorationImage(
                            //             image: AssetImage('${AssetPath.pngPath}profile-error.png'),
                            //             fit: BoxFit.cover,
                            //           ),
                            //           shape: BoxShape.circle,
                            //         ),
                            //       ),
                            //     );
                            //   },
                            // ),

                            Expanded(
                              flex: 8,
                              child: TextFormField(
                                minLines: 3,
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
                                    hintStyle: textTheme.bodyText2,
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
                        // Stack(
                        //   children: [
                        //     Container(
                        //       height: 200,
                        //       color: Colors.red,
                        //     )
                        //   ],
                        // ),

                        Row(
                          children: [
                            CustomElevatedButton(
                                child: CustomTextWidget(
                                  textToDisplay: '#Hastag',
                                  textStyle: textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
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
                                  textStyle: textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
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
                        sixteenPx,
                        _buildDivider(context),
                        twentyFourPx,
                        Row(
                          children: [
                            CustomTextWidget(
                              textToDisplay: "Category ",
                              textStyle: textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
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
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero, splashFactory: NoSplash.splashFactory),
                                  child: PickitemTitle(
                                    title: notifier.interest[index].interestName!,
                                    select: notifier.pickedInterest(notifier.interest[index].interestName) ? true : false,
                                    button: false,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        _buildDivider(context),
                        twentyFourPx,

                        notifier.userTagData.isEmpty
                            ? ListTile(
                                onTap: () {
                                  notifier.showPeopleSearch(context);
                                },
                                contentPadding: EdgeInsets.zero,
                                title: CustomTextWidget(
                                  textToDisplay: ' Tag People',
                                  textAlign: TextAlign.start,
                                  textStyle: textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
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
                              ),

                        _buildDivider(context),
                        ListTile(
                          onTap: () {
                            notifier.showLocation(context);
                          },
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.secondaryVariant),
                          title: CustomTextWidget(
                            textToDisplay: notifier.locationName,
                            textAlign: TextAlign.start,
                            textStyle: textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
                          ),
                          trailing: notifier.locationName == 'Add Location'
                              ? const Icon(Icons.arrow_forward_ios_rounded)
                              : GestureDetector(
                                  onTap: () {
                                    notifier.locationName = 'Add Location';
                                  },
                                  child: const Icon(Icons.close)),
                          minLeadingWidth: 0,
                        ),

                        // Container(
                        //   child: Row(
                        //     children: [
                        //       Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.secondaryVariant),
                        //       tenPx,
                        //       InkWell(
                        //         onTap: () {},
                        //         child: CustomTextWidget(
                        //           textToDisplay: ' Add Location',
                        //           textStyle: textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),

                        _buildDivider(context),
                        eightPx,
                        ListTile(
                          onTap: () => notifier.onClickPrivacyPost(context),
                          title: CustomTextWidget(
                            textToDisplay: 'Privacy',
                            textStyle: textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
                            textAlign: TextAlign.start,
                          ),
                          contentPadding: EdgeInsets.zero,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomTextWidget(
                                textToDisplay: notifier.privacyTitle,
                                textStyle: textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
                              ),
                              twentyPx,
                              Icon(Icons.arrow_forward_ios_rounded),
                            ],
                          ),
                        ),

                        SizedBox(height: 20 * SizeConfig.scaleDiagonal),
                        // Container(
                        //   width: SizeConfig.screenWidth,
                        //   alignment: Alignment.centerLeft,
                        //   height: 80 * SizeConfig.scaleDiagonal,
                        //   decoration: BoxDecoration(border: Border(bottom: BorderSide(color: const Color(0xff252627), width: 0.5))),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Text(
                        //         "Add Location",
                        //         style: TextStyle(
                        //             color: Colors.white, fontFamily: "Roboto", fontWeight: FontWeight.w400, fontSize: 14 * SizeConfig.scaleDiagonal),
                        //       ),
                        //       Expanded(
                        //         child: AnimatedSwitcher(
                        //           transitionBuilder: (child, animation) => ScaleTransition(child: child, scale: animation, alignment: Alignment.center),
                        //           child: notifier.selectedLocation.isNotEmpty
                        //               ? BuildSelectedLocation()
                        //               : FutureBuilder<List<PlacesSearchResult>>(
                        //                   initialData: [],
                        //                   future: _placesFuture,
                        //                   builder: (context, snapshot) {
                        //                     if (snapshot.connectionState != ConnectionState.done && !snapshot.hasError) {
                        //                       return Stack(
                        //                         children: [
                        //                           Center(child: const CustomLoading()),
                        //                           Align(
                        //                             alignment: Alignment.centerRight,
                        //                             child: IconButton(
                        //                                 icon: Icon(Icons.refresh),
                        //                                 onPressed: () {
                        //                                   _placesFuture = notifier.getNearestLocation();
                        //                                   setState(() {});
                        //                                 }),
                        //                           )
                        //                         ],
                        //                       );
                        //                     }
                        //                     if (snapshot.hasData) {
                        //                       return BuildSuggestedLocation(data: snapshot.data);
                        //                     }
                        //                     return Stack(
                        //                       children: [
                        //                         Center(
                        //                           child: CustomFlatButton(
                        //                             color: const Color(0xff383B3E),
                        //                             onPressed: () {
                        //                               _placesFuture = notifier.getNearestLocation();
                        //                               setState(() {});
                        //                             },
                        //                             child: Text(
                        //                               'Sorry, an error occurred',
                        //                               maxLines: 1,
                        //                               style: TextStyle(
                        //                                   color: const Color(0xff949596),
                        //                                   fontFamily: "Roboto",
                        //                                   fontWeight: FontWeight.w400,
                        //                                   fontSize: 12 * SizeConfig.scaleDiagonal),
                        //                             ),
                        //                           ),
                        //                         ),
                        //                         Align(
                        //                           alignment: Alignment.centerRight,
                        //                           child: IconButton(
                        //                               icon: Icon(Icons.refresh),
                        //                               onPressed: () {
                        //                                 _placesFuture = notifier.getNearestLocation();
                        //                                 setState(() {});
                        //                               }),
                        //                         )
                        //                       ],
                        //                     );
                        //                   }),
                        //           duration: const Duration(milliseconds: 200),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // TextFormField(
                        //   maxLines: 1,
                        //   controller: notifier.tagsController,
                        //   keyboardAppearance: Brightness.dark,
                        //   cursorColor: const Color(0xff8A3181),
                        //   style: textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold),
                        //   decoration: InputDecoration(
                        //     hintText: "Hashtag",
                        //     hintStyle: textTheme.bodyText2,
                        //     errorBorder: InputBorder.none,
                        //     enabledBorder: InputBorder.none,
                        //     focusedBorder: InputBorder.none,
                        //     disabledBorder: InputBorder.none,
                        //     focusedErrorBorder: InputBorder.none,
                        //     contentPadding: const EdgeInsets.all(5),
                        //   ),
                        // ),

                        SizedBox(height: 20 * SizeConfig.scaleDiagonal),
                        if (notifier.featureType != FeatureType.story) ...[
                          Container(
                            width: SizeConfig.screenWidth,
                            alignment: Alignment.centerLeft,
                            decoration: const BoxDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                CustomTextWidget(
                                  textToDisplay: notifier.language.advanceSettings!,
                                  textStyle: textTheme.bodyText2?.copyWith(color: kHyppeSecondary),
                                ),
                                SizedBox(height: 10 * SizeConfig.scaleDiagonal),
                                SizedBox(height: 20 * SizeConfig.scaleDiagonal),
                                // SizedBox(height: 20 * SizeConfig.scaleDiagonal),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notifier.language.registerContentOwnership!,
                                          style: Theme.of(context).textTheme.bodyText1?.copyWith(
                                                  color: const Color.fromRGBO(
                                                63,
                                                63,
                                                63,
                                                1,
                                              )),
                                        ),
                                        SizedBox(height: 10 * SizeConfig.scaleDiagonal),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("• "),
                                            SizedBox(
                                              width: 276 * SizeConfig.scaleDiagonal,
                                              child: CustomRichTextWidget(
                                                textAlign: TextAlign.start,
                                                textOverflow: TextOverflow.clip,
                                                textSpan: TextSpan(
                                                  text: notifier.language.registerContentOwnershipExplain1!,
                                                  style: Theme.of(context).textTheme.caption!.copyWith(height: 1.5),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10 * SizeConfig.scaleDiagonal),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("• "),
                                            SizedBox(
                                              width: 276 * SizeConfig.scaleDiagonal,
                                              child: CustomRichTextWidget(
                                                textAlign: TextAlign.start,
                                                textOverflow: TextOverflow.clip,
                                                textSpan: TextSpan(
                                                  text: notifier.language.registerContentOwnershipExplain2!,
                                                  style: Theme.of(context).textTheme.caption!.copyWith(height: 1.5),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    CustomSwitchButton(
                                      value: notifier.certified,
                                      onChanged: (value) => notifier.certified = value,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        twentyFourPx,
                        twentyFourPx,
                        twentyFourPx,
                        twentyFourPx,
                      ],
                    ),
                    AutoCompleteUserTag(),
                    // Visibility(
                    //   visible: autoComplete,
                    //   child: Padding(
                    //     padding: EdgeInsets.only(top: 100),
                    //     child: Container(
                    //       height: 200,
                    //       color: Colors.red,
                    //       child: ListView.builder(
                    //         itemCount: notifier.searchPeopleACData.length,
                    //         itemBuilder: (context, index) {
                    //           return ListTile(
                    //             onTap: () {
                    //               final text = notifier.captionController.text;
                    //               final selection = notifier.captionController.selection;

                    //               print('search');
                    //               print(search);
                    //               // print(text.replaceAll(from, replace));
                    //               int searchLength = search.length;
                    //               print(selection.start - searchLength);

                    //               final newText = text.replaceRange(selection.start - searchLength, selection.end, '${notifier.searchPeopleACData[index]['username']} ');
                    //               int length = notifier.searchPeopleACData[index]['username'].length;
                    //               print(newText);
                    //               print(selection.baseOffset);
                    //               print(selection.baseOffset + length - searchLength);
                    //               notifier.captionController.value = TextEditingValue(
                    //                 text: "${newText}",
                    //                 selection: TextSelection.collapsed(offset: selection.baseOffset + length - searchLength + 1),
                    //               );
                    //             },
                    //             title: Text(notifier.searchPeopleACData[index]['username']!),
                    //           );
                    //         },
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            floatingActionButton: Padding(
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
                function: () => notifier.certified
                    ? System().actionReqiredIdCard(context,
                        action: () => notifier.onClickPost(
                              context,
                              onEdit: widget.arguments.onEdit,
                              data: widget.arguments.contentData,
                              content: widget.arguments.content,
                            ))
                    : notifier.onClickPost(
                        context,
                        onEdit: widget.arguments.onEdit,
                        data: widget.arguments.contentData,
                        content: widget.arguments.content,
                      ),
                child: widget.arguments.onEdit && notifier.updateContent
                    ? const CustomLoading()
                    : CustomTextWidget(
                        textToDisplay: widget.arguments.onEdit ? notifier.language.save! : notifier.language.confirm!,
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
            backgroundColor: Theme.of(context).backgroundColor,
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          ),
        ),
      ),
    );
  }
}
