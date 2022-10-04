import 'dart:io';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/bloc/ads_video/bloc.dart';
import '../../../../../core/constants/asset_path.dart';
import '../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../core/models/collection/advertising/view_ads_request.dart';
import '../../../../../core/services/shared_preference.dart';
import '../../../widget/custom_background_layer.dart';
import '../../../widget/custom_base_cache_image.dart';
import '../../../widget/custom_cache_image.dart';

class AdsPopUpDialog extends StatefulWidget {
  final AdsData data;
  final String urlAds;

  const AdsPopUpDialog({Key? key, required this.data, required this.urlAds}) : super(key: key);

  @override
  State<AdsPopUpDialog> createState() => _AdsPopUpDialogState();
}

class _AdsPopUpDialogState extends State<AdsPopUpDialog> {
  List<StoryItem> _storyItems = [];
  final StoryController _storyController = StoryController();

  final _sharedPrefs = SharedPreference();
  var secondsSkip = 0;
  var secondsVideo = 0;
  // List<ContentData>? _vidData;

  @override
  void initState() {
    _storyItems.add(StoryItem.pageVideo(widget.urlAds, controller: _storyController, requestHeaders: {
      'x-auth-user': _sharedPrefs.readStorage(SpKeys.email),
      'x-auth-token': _sharedPrefs.readStorage(SpKeys.userToken),
    },
    duration: Duration(
      milliseconds: ((widget.data.duration ?? 15) * 1000).toInt()
    )));

    secondsSkip = widget.data.adsSkip ?? 0;
    super.initState();
  }

  Future adsView(AdsData data, int time) async{
    try{
      final notifier = AdsDataBloc();
      final request = ViewAdsRequest(watchingTime: time, adsId: data.adsId, useradsId: data.useradsId);
      await notifier.viewAdsBloc(context, request);

      // final fetch = notifier.adsVideoFetch;

    }catch(e){
      'Failed hit view ads ${e}'.logger();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(8.0)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.data == 'image' ?
          Stack(
            children: [
              // Background
              CustomBackgroundLayer(
                sigmaX: 30,
                sigmaY: 30,
                // thumbnail: picData!.content[arguments].contentUrl,
                thumbnail: widget.urlAds,
              ),
              // Content
              InteractiveViewer(
                child: InkWell(
                  child: CustomCacheImage(
                    imageUrl: widget.urlAds,
                    imageBuilder: (ctx, imageProvider) {
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.contain),
                        ),
                      );
                    },
                    errorWidget: (_, __, ___) {
                      return Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            image: AssetImage(
                                '${AssetPath
                                    .pngPath}content-error.png'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ) : StoryView(
            inline: false,
            repeat: false,
            progressColor: kHyppeLightButtonText,
            durationColor: kHyppeLightButtonText,
            storyItems: _storyItems,
            controller: _storyController,
            progressPosition: ProgressPosition.top,
            onStoryShow: (storyItem) {
              // int pos = _storyItems.indexOf(storyItem);
              //
              // context.read<DiariesPlaylistNotifier>().setCurrentDiary(pos);
              // // _addPostView();
              // _storyController.playbackNotifier.listen((value) {
              //   if (value == PlaybackState.previous) {
              //     if (widget.controller!.page == 0) {
              //       // context.read<DiariesPlaylistNotifier>().onWillPop(true);
              //     } else {
              //       widget.controller!.previousPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut);
              //     }
              //   }
              // });
            },
            onEverySecond: (dur){

              print('second of video ${dur.inSeconds}');
              setState(() {
                secondsSkip -= 1;
                secondsVideo += 1;
              });
            },
            nextDebouncer: false,
            onComplete: () {
              _storyController.pause();

              // Navigator.pop(context);
              // widget.controller!.nextPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut);

              // _storyController.next();
              // widget.controller!.

              // final isLastPage = widget.total! - 1 == widget.controller!.page;
              // widget.function();
              // if (isLastPage) {
              //   context.read<DiariesPlaylistNotifier>().onWillPop(mounted);
              // }
            },
          ),
          Positioned(
            left: 0,
              top: 50,
              right: 0,
              child: topAdsLayout(widget.data)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: bottomAdsLayout(widget.data),
          )
        ],
      )
      // Image.network(
      //   'https://www.pocarisweat.com.sg//assets/uploads/2020/11/3aaf07f26dc43575fb5406f4901dac63.jpg',
      //   fit: BoxFit.contain,
      // ),
    );
  }

  Widget topAdsLayout(AdsData data){
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.transparent,
        margin: EdgeInsets.only(left: 18, right: 18),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomBaseCacheImage(
                  imageUrl: data.avatar?.fullLinkURL,
                  memCacheWidth: 200,
                  memCacheHeight: 200,
                  imageBuilder: (_, imageProvider) {
                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(18)),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: imageProvider,
                        ),
                      ),
                    );
                  },
                  errorWidget: (_, __, ___) {
                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(18)),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: const AssetImage('${AssetPath.pngPath}content-error.png'),
                        ),
                      ),
                    );
                  },
                ),
                twelvePx,
                Column(
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(defaultColor: false,
                          iconData: "${AssetPath.vectorPath}ad_yellow_icon.svg",),
                        fourPx,
                        Text(data.adsDescription ?? 'Nike', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),)
                      ],
                    ),
                    sixPx,
                    Text('Sponsored', style: TextStyle(color: Colors.white, fontSize: 12,),)
                  ],
                )
              ],
            ),
            secondsSkip > 0 ? Container(
              height: 30,
              width: 30,
              child: Text('$secondsSkip', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: Colors.grey
              ),
            ):InkWell(
              onTap: (){
                adsView(widget.data, secondsVideo);
                Navigator.pop(context);
              },
              child: CustomIconWidget(defaultColor: false,
                iconData: "${AssetPath.vectorPath}close_ads.svg",),
            )
          ],
        ),
      ),
    );
  }

  Widget bottomAdsLayout(AdsData data){
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 15),
        child: InkWell(
          onTap: ()async{
            final uri = Uri.parse(data.adsUrlLink ?? '');
            if (await canLaunchUrl(uri))
              await launchUrl(uri, mode: LaunchMode.externalApplication,);
            else
              // can't launch url, there is some error
              throw "Could not launch $uri";
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Text('Learn more', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700,),),
            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: KHyppeButtonAds),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required ThemeData theme, required String caption, required Function function, required Color color, Color? textColor}) {
    return CustomElevatedButton(
      child: CustomTextWidget(textToDisplay: caption, textStyle: theme.textTheme.button!.copyWith(color: textColor)),
      width: 220,
      height: 42,
      function: () async {
        if (Platform.isAndroid || Platform.isIOS) {
          final appId = Platform.isAndroid ? 'com.hyppe.hyppeapp' : 'id1545595684';
          final url = Uri.parse(
            Platform.isAndroid ? "market://details?id=$appId" : "https://apps.apple.com/app/id$appId",
          );
          launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        }
      },
      buttonStyle: theme.elevatedButtonTheme.style!.copyWith(
        backgroundColor: MaterialStateProperty.all(color),
      ),
    );
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }
}
