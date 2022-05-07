import 'package:hyppe/core/arguments/update_contents_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_model.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_switch_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/validate_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreUploadContentScreen extends StatefulWidget {
  final UpdateContentsArgument arguments;

  const PreUploadContentScreen({Key? key, required this.arguments})
      : super(key: key);

  @override
  _PreUploadContentScreenState createState() => _PreUploadContentScreenState();
}

class _PreUploadContentScreenState extends State<PreUploadContentScreen> {
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
            appBar: AppBar(
              elevation: 0,
              centerTitle: false,
              leading: CustomIconButtonWidget(
                onPressed: () => notifier.onWillPop(context),
                defaultColor: true,
                iconData: "${AssetPath.vectorPath}back-arrow.svg",
              ),
              title: CustomTextWidget(
                textToDisplay: widget.arguments.onEdit
                    ? "${notifier.language.edit} ${notifier.language.post}"
                    : notifier.language.newPost!,
                textStyle:
                    textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                width: SizeConfig.screenWidth,
                height: SizeConfig.screenHeight,
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Selector<SelfProfileNotifier, UserProfileModel?>(
                        //   selector: (_, select) => select.user.profile,
                        //   builder: (_, notifier, __) {
                        //     return CustomCacheImage(
                        //       imageUrl:
                        //           '${System().showUserPicture(notifier?.avatar?.mediaEndpoint)}',
                        //       imageBuilder: (context, imageProvider) =>
                        //           Container(
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
                        //             image: AssetImage(
                        //                 '${AssetPath.pngPath}profile-error.png'),
                        //             fit: BoxFit.cover,
                        //           ),
                        //           shape: BoxShape.circle,
                        //         ),
                        //       ),
                        //     );
                        //   },
                        // ),
                        // SizedBox(width: 16 * SizeConfig.scaleDiagonal),
                        Expanded(
                          flex: 8,
                          child: TextFormField(
                            minLines: 1,
                            maxLines: 10,
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
                            style: textTheme.bodyText2
                                ?.copyWith(fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              errorBorder: InputBorder.none,
                              hintStyle: textTheme.bodyText2,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              hintText: "${notifier.language.writeCaption}...",
                              contentPadding: const EdgeInsets.only(bottom: 5),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: ValidateType(
                              editContent: widget.arguments.onEdit),
                        )
                      ],
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
                    TextFormField(
                      maxLines: 1,
                      controller: notifier.tagsController,
                      keyboardAppearance: Brightness.dark,
                      cursorColor: const Color(0xff8A3181),
                      style: textTheme.bodyText2
                          ?.copyWith(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: "Hashtag",
                        hintStyle: textTheme.bodyText2,
                        errorBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.all(5),
                      ),
                    ),
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
                              textStyle: textTheme.bodyText2
                                  ?.copyWith(color: kHyppeSecondary),
                            ),
                            SizedBox(height: 10 * SizeConfig.scaleDiagonal),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notifier.language.turnOffCommenting!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          ?.copyWith(
                                              color: const Color.fromRGBO(
                                            63,
                                            63,
                                            63,
                                            1,
                                          )),
                                    ),
                                    SizedBox(
                                        height: 10 * SizeConfig.scaleDiagonal),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("• "),
                                        SizedBox(
                                          width: 276 * SizeConfig.scaleDiagonal,
                                          child: CustomRichTextWidget(
                                            textAlign: TextAlign.start,
                                            textOverflow: TextOverflow.clip,
                                            textSpan: TextSpan(
                                              text: notifier.language
                                                  .turnOffCommentingExplain1!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption!
                                                  .copyWith(height: 1.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height: 10 * SizeConfig.scaleDiagonal),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("• "),
                                        SizedBox(
                                          width: 276 * SizeConfig.scaleDiagonal,
                                          child: CustomRichTextWidget(
                                            textAlign: TextAlign.start,
                                            textOverflow: TextOverflow.clip,
                                            textSpan: TextSpan(
                                              text: notifier.language
                                                  .turnOffCommentingExplain2!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption!
                                                  .copyWith(height: 1.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                CustomSwitchButton(
                                  value: !notifier.allowComment,
                                  onChanged: (value) =>
                                      notifier.allowComment = !value,
                                ),
                              ],
                            ),
                            SizedBox(height: 20 * SizeConfig.scaleDiagonal),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notifier
                                          .language.registerContentOwnership!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          ?.copyWith(
                                              color: const Color.fromRGBO(
                                            63,
                                            63,
                                            63,
                                            1,
                                          )),
                                    ),
                                    SizedBox(
                                        height: 10 * SizeConfig.scaleDiagonal),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("• "),
                                        SizedBox(
                                          width: 276 * SizeConfig.scaleDiagonal,
                                          child: CustomRichTextWidget(
                                            textAlign: TextAlign.start,
                                            textOverflow: TextOverflow.clip,
                                            textSpan: TextSpan(
                                              text: notifier.language
                                                  .registerContentOwnershipExplain1!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption!
                                                  .copyWith(height: 1.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height: 10 * SizeConfig.scaleDiagonal),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("• "),
                                        SizedBox(
                                          width: 276 * SizeConfig.scaleDiagonal,
                                          child: CustomRichTextWidget(
                                            textAlign: TextAlign.start,
                                            textOverflow: TextOverflow.clip,
                                            textSpan: TextSpan(
                                              text: notifier.language
                                                  .registerContentOwnershipExplain2!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption!
                                                  .copyWith(height: 1.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                CustomSwitchButton(
                                  value: notifier.certified,
                                  onChanged: (value) =>
                                      notifier.certified = value,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]
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
                        textToDisplay: widget.arguments.onEdit
                            ? notifier.language.save!
                            : notifier.language.confirm!,
                        textStyle: textTheme.button
                            ?.copyWith(color: kHyppeLightButtonText),
                      ),
                buttonStyle: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primaryVariant),
                  shadowColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primaryVariant),
                  overlayColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primaryVariant),
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primaryVariant),
                ),
              ),
            ),
            backgroundColor: Theme.of(context).backgroundColor,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          ),
        ),
      ),
    );
  }
}
