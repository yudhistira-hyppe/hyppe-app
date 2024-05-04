import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class BeforeLive extends StatelessWidget {
  final bool? mounted;
  const BeforeLive({super.key, this.mounted});

  @override
  Widget build(BuildContext context) {
    var profileImage = context.read<HomeNotifier>().profileImage;
    var profileImageKey = context.read<HomeNotifier>().profileImageKey;
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) => SizedBox(
        height: SizeConfig.screenHeight,
        width: SizeConfig.screenWidth,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    notifier.destoryPusher();
                    Routing().moveBack();
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
                twentyFourPx,
                GestureDetector(
                  onTap: () => notifier.titleFocusNode.requestFocus(),
                  child: Container(
                    width: SizeConfig.screenWidth! * 0.7,
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      top: 8,
                      bottom: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black.withOpacity(0.4),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        (System().showUserPicture(profileImage)?.isNotEmpty ?? false ) ?CustomProfileImage(
                          cacheKey: profileImageKey,
                          following: true,
                          forStory: true,
                          width: 50 * SizeConfig.scaleDiagonal,
                          height: 50 * SizeConfig.scaleDiagonal,
                          imageUrl: System().showUserPicture(profileImage),
                          // badge: notifier.user.profile?.urluserBadge,
                          allwaysUseBadgePadding: false,
                        ) : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            '${AssetPath.pngPath}profile-error.jpg',
                            fit: BoxFit.fitWidth,
                            height: 50 * SizeConfig.scaleDiagonal,
                            width: 50 * SizeConfig.scaleDiagonal,
                          ),
                        ),
                        sixPx,
                        Expanded(
                          // height: 48 * SizeConfig.scaleDiagonal,
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller: notifier.titleLiveCtrl,
                            focusNode: notifier.titleFocusNode,
                            textAlignVertical: TextAlignVertical.top,
                            textAlign: TextAlign.left,
                            style: const TextStyle(fontSize: 13, color: kHyppeTextPrimary),
                            cursorColor: kHyppeBurem,
                            decoration:  InputDecoration(
                              isDense: false,
                              alignLabelWithHint: false,
                              isCollapsed: true,
                              hintText: notifier.tn?.addATitle ,
                              counterText: '',
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.only(top: 0),
                              hintStyle: const TextStyle(fontSize: 13, color: kHyppeBurem),
                            ),
                            maxLength: 30,
                            maxLines: 2,
                            onChanged: (value) {
                              if (notifier.titleLiveCtrl.text.length > 30) {
                                notifier.titleLiveCtrl.text = notifier.titleLiveCtrl.text.substring(0, 30);
                              } else {
                                notifier.titleLive = value;
                              }
                            },
                          ),
                        ),
                        Text(
                          "${notifier.titleLiveCtrl.text.length}/30",
                          style: const TextStyle(fontSize: 13, color: Color(0xffcecece)),
                        )
                      ],
                    ),
                  ),
                ),
                twelvePx,
                (notifier.urlLink == '' || notifier.textUrl == '')
                ? GestureDetector(
                  onTap: () => Navigator.pushNamed(context, Routes.addlink, arguments: {
                    'routes': Routes.streamer,
                    'urlLink': notifier.urlLink.isEmpty
                        ? null
                        : notifier.urlLink,
                    'judulLink': notifier.textUrl.isEmpty
                        ? null
                        : notifier.textUrl
                  }),
                  child: Container(
                    width: SizeConfig.screenWidth! * 0.7,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black.withOpacity(0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(notifier.tn?.enterLinkLiveStream??'Masukkan URL yang ingin dibagikan', 
                            style: TextStyle(color: kHyppeBurem),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 18,)
                      ],
                    ),
                  ),
                )
                : GestureDetector(
                  onTap: () => Navigator.pushNamed(context, Routes.addlink, arguments: {
                    'routes': Routes.streamer,
                    'urlLink': notifier.urlLink.isEmpty
                        ? null
                        : notifier.urlLink,
                    'judulLink': notifier.textUrl.isEmpty
                        ? null
                        : notifier.textUrl
                  }),
                  child: Container(
                    width: SizeConfig.screenWidth! * 0.7,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black.withOpacity(0.4),
                    ),
                    child: Row(
                      children: [
                        const CustomIconWidget(
                          iconData: "${AssetPath.vectorPath}hyperlink.svg",
                          defaultColor: false,
                          color: kHyppeBurem,
                        ),
                        const SizedBox(width: 12.0,),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notifier.urlLink, 
                              style: TextStyle(color: kHyppeBurem),
                            ),
                            if (notifier.textUrl != '')
                            Text(notifier.textUrl, 
                              style: TextStyle(color: kHyppeBurem, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                        const Icon(Icons.arrow_forward_ios, size: 18,)
                      ],
                    )
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}flip.svg",
                        defaultColor: false,
                        color: Colors.transparent,
                      ),
                      GestureDetector(
                        onTap: () => notifier.clickPushAction(context, mounted),
                        child: const Padding(
                          padding: EdgeInsets.only(right: 40.0, left: 25),
                          child: CustomIconWidget(
                            iconData: "${AssetPath.vectorPath}streambutton.svg",
                            defaultColor: false,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          notifier.flipCamera();
                        },
                        child: const CustomIconWidget(
                          iconData: "${AssetPath.vectorPath}flip.svg",
                          defaultColor: false,
                        ),
                      ),
                    ],
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