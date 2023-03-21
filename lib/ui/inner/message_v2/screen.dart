import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/services/error_service.dart';

import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';

import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';

import 'package:hyppe/ui/inner/message_v2/notifier.dart';
import 'package:hyppe/ui/inner/notification/widget/component_shimmer.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/process_upload_component.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> with RouteAware {
  final _notifier = MessageNotifier();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _globalKey = GlobalKey<RefreshIndicatorState>();

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'MessageScreen');
    // notifier.initialData(context);
    _notifier.getDiscussion(context, reload: true);
    _scrollController.addListener(() => _notifier.scrollListener(context, _scrollController));
    super.initState();
  }

  @override
  void didPopNext() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _notifier.getDiscussion(context, reload: true);
      }
    });

    super.didPopNext();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final error = context.select((ErrorService value) => value.getError(ErrorType.message));
    return ChangeNotifierProvider<MessageNotifier>(
      create: (context) => _notifier,
      child: Consumer2<MessageNotifier, TranslateNotifierV2>(
        builder: (_, notifier, notifier2, __) => Scaffold(
          appBar: AppBar(
            title: CustomTextWidget(
              textToDisplay: notifier2.translate.messages ?? '',
              textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          body: context.read<ErrorService>().isInitialError(error, notifier.discussData)
              ? Center(
                  child: SizedBox(
                    height: 198,
                    child: CustomErrorWidget(
                      errorType: ErrorType.message,
                      // function: () => notifier.initialData(context),
                      function: () => notifier.getDiscussion(context, reload: true),
                    ),
                  ),
                )
              : Container(
                  child: Column(
                    children: [
                      // const ProcessUploadComponent(),
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 15 * SizeConfig.scaleDiagonal),
                      //   child: CustomSearchBar(
                      //     onSubmitted: (v) => print(v),
                      //     hintText: notifier2.translate.searchName,
                      //     contentPadding: EdgeInsets.symmetric(vertical: 16 * SizeConfig.scaleDiagonal),
                      //   ),
                      // ),
                      Expanded(
                        flex: 13,
                        child: notifier.discussData != null
                            ? NotificationListener(
                                onNotification: (ScrollNotification scrollInfo) {
                                  if (scrollInfo is ScrollStartNotification) {
                                    Future.delayed(const Duration(milliseconds: 100), () {
                                      notifier.getDiscussion(context);
                                    });
                                  }

                                  return true;
                                },
                                child: RefreshIndicator(
                                  key: _globalKey,
                                  strokeWidth: 2.0,
                                  color: Colors.purple,
                                  onRefresh: () => notifier.getDiscussion(context, reload: true),
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    itemCount: notifier.itemCount,
                                    scrollDirection: Axis.vertical,
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      if (index == notifier.discussData?.length && notifier.hasNext) {
                                        return const CustomLoading();
                                      }

                                      final discussData = notifier.discussData?[index];

                                      return InkWell(
                                        onTap: () => notifier.onClickUser(context, discussData),
                                        onLongPress: () {
                                          // ShowBottomSheet.onLongPressTileUserMessage(context);
                                          ShowBottomSheet.onLongPressDeleteMessage(context, data: discussData, function: () {
                                            // print('masuk mas eko');
                                            // print(discussData.senderOrReceiverInfo.email);
                                            // print(discussData.disqusID);
                                            notifier.deletetConversation(context, discussData?.senderOrReceiverInfo?.email ?? '', discussData?.disqusID ?? '');
                                          });
                                        },
                                        child: ListTile(
                                          leading: StoryColorValidator(
                                            featureType: FeatureType.other,
                                            // haveStory: notifier.chatData[index].isHaveStory ?? false,
                                            haveStory: false,
                                            child: CustomProfileImage(
                                              following: true,
                                              onTap: () => System().navigateToProfile(context, discussData?.senderOrReceiverInfo?.email ?? ''),
                                              // imageUrl: notifier.userID == notifier.chatData[index].senderID
                                              //     ? '${notifier.chatData[index].picReceiverUrl + SMALL}'
                                              //     : '${notifier.chatData[index].picSenderUrl + SMALL}',
                                              imageUrl: System().showUserPicture(discussData?.senderOrReceiverInfo?.avatar?.mediaEndpoint),
                                              height: 60 * SizeConfig.scaleDiagonal,
                                              width: 60 * SizeConfig.scaleDiagonal,
                                            ),
                                          ),
                                          title: CustomTextWidget(
                                            // "Demo user",
                                            // textToDisplay: notifier.userID == notifier.chatData[index].senderID
                                            //     ? notifier.chatData[index].receiverUserName
                                            //     : notifier.chatData[index].senderName,
                                            textToDisplay: discussData?.senderOrReceiverInfo?.fullName ?? '',
                                            textAlign: TextAlign.start,
                                            textStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          subtitle: CustomTextWidget(
                                            textToDisplay: discussData?.lastestMessage ?? '',
                                            textAlign: TextAlign.start,
                                            textStyle: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary),
                                          ),
                                          trailing: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              CustomTextWidget(
                                                textToDisplay: System().readTimestamp(
                                                  DateTime.parse(discussData?.updatedAt ?? DateTime.now().toString()).millisecondsSinceEpoch,
                                                  context,
                                                  fullCaption: true,
                                                ),
                                                textStyle: Theme.of(context).textTheme.caption,
                                              ),
                                              const SizedBox(height: 8),
                                              CustomIconWidget(
                                                iconData: "${AssetPath.vectorPath}unread.svg",
                                                defaultColor: false,
                                                color: DateTime.now().millisecondsSinceEpoch >
                                                        DateTime.parse(discussData?.updatedAt ?? DateTime.now().toString()).add(const Duration(minutes: 10)).millisecondsSinceEpoch
                                                    ? kHyppeLightIcon
                                                    : null,
                                              ),
                                            ],
                                          ),
                                          // trailing: notifier.chatData[index].isRead == true
                                          //     ? CustomTextWidget(
                                          //         textToDisplay: System().readTimestamp(
                                          //           int.parse(notifier.chatData[index].timestamp),
                                          //           context,
                                          //           fullCaption: false,
                                          //         ),
                                          //         textStyle: Theme.of(context).textTheme.caption,
                                          //       )
                                          //     : Column(
                                          //         mainAxisAlignment: MainAxisAlignment.center,
                                          //         children: [
                                          //           CustomTextWidget(
                                          //             textToDisplay: System().readTimestamp(
                                          //               int.parse(notifier.chatData[index].timestamp),
                                          //               context,
                                          //               fullCaption: false,
                                          //             ),
                                          //             textStyle: Theme.of(context).textTheme.caption,
                                          //           ),
                                          //           SizedBox(height: 8),
                                          //           CustomIconWidget(
                                          //             iconData: "${AssetPath.vectorPath}unread.svg",
                                          //             defaultColor: false,
                                          //           ),
                                          //         ],
                                          //       ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: 10,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (context, index) => ComponentShimmer(),
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
