import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/live_streaming/on_live_stream_status.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../initial/hyppe/translate_v2.dart';
import '../../../../../../ux/routing.dart';
import '../../../../widget/custom_gesture.dart';
import '../../../../widget/custom_profile_image.dart';
import '../../../../widget/custom_spacer.dart';
import '../../../../widget/icon_button_widget.dart';

class OnListWatchers extends StatefulWidget {
  const OnListWatchers({super.key});

  @override
  State<OnListWatchers> createState() => _OnListWatchersState();
}

class _OnListWatchersState extends State<OnListWatchers> {
  final wacthers = const [
    Watcher(
        image:
            'https://images.rawpixel.com/image_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvMjc5LXBhaTE1NzktbmFtLmpwZw.jpg',
        username: 'marcelardianto_',
        name: 'Marcel',
        isFollowing: false),
    Watcher(
        image:
            'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?cs=srgb&dl=pexels-pixabay-415829.jpg&fm=jpg',
        username: 'angela_gunawan',
        name: 'Guns',
        isFollowing: true),
    Watcher(
        image:
            'https://www.shutterstock.com/image-photo/portrait-young-beautiful-woman-perfect-600nw-2228044151.jpg',
        username: 'stephanie.wijaya',
        name: 'stephanis',
        isFollowing: false),
    Watcher(
        image:
            'https://i.pinimg.com/736x/ec/35/7b/ec357b956cbb9da835c2feefe74e56fb.jpg',
        username: 'deni.riwanto',
        name: 'Deni',
        isFollowing: true),
    Watcher(
        image:
            'https://images.rawpixel.com/image_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvMjc5LXBhaTE1NzktbmFtLmpwZw.jpg',
        username: 'marcelardianto_',
        name: 'Marcel',
        isFollowing: false),
    Watcher(
        image:
            'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?cs=srgb&dl=pexels-pixabay-415829.jpg&fm=jpg',
        username: 'angela_gunawan',
        name: 'Guns',
        isFollowing: true),
    Watcher(
        image:
            'https://www.shutterstock.com/image-photo/portrait-young-beautiful-woman-perfect-600nw-2228044151.jpg',
        username: 'stephanie.wijaya',
        name: 'stephanis',
        isFollowing: false),
    Watcher(
        image:
            'https://i.pinimg.com/736x/ec/35/7b/ec357b956cbb9da835c2feefe74e56fb.jpg',
        username: 'deni.riwanto',
        name: 'Deni',
        isFollowing: true),
    Watcher(
        image:
            'https://images.rawpixel.com/image_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvMjc5LXBhaTE1NzktbmFtLmpwZw.jpg',
        username: 'marcelardianto_',
        name: 'Marcel',
        isFollowing: false),
    Watcher(
        image:
            'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?cs=srgb&dl=pexels-pixabay-415829.jpg&fm=jpg',
        username: 'angela_gunawan',
        name: 'Guns',
        isFollowing: true),
    Watcher(
        image:
            'https://www.shutterstock.com/image-photo/portrait-young-beautiful-woman-perfect-600nw-2228044151.jpg',
        username: 'stephanie.wijaya',
        name: 'stephanis',
        isFollowing: false),
    Watcher(
        image:
            'https://i.pinimg.com/736x/ec/35/7b/ec357b956cbb9da835c2feefe74e56fb.jpg',
        username: 'deni.riwanto',
        name: 'Deni',
        isFollowing: true),
  ];

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 64,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(left: 16),
                    child: CustomIconButtonWidget(
                      height: 30,
                      width: 30,
                      onPressed: () {
                        Routing().moveBack();
                      },
                      color: Colors.black,
                      defaultColor: false,
                      iconData: "${AssetPath.vectorPath}back-arrow.svg",
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: CustomTextWidget(
                      textToDisplay: 'List Penonton',
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: wacthers.length,
                itemBuilder: (context, index) {
                  final watcher = wacthers[index];
                  return watcherItem(watcher, index, language);
                }),
          ),
        ],
      ),
    );
  }

  Widget watcherItem(Watcher watcher, int index, LocalizationModelV2 language) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomTextWidget(
            textToDisplay: '${index + 1}',
            textStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          sixteenPx,
          CustomProfileImage(
            width: 36,
            height: 36,
            following: true,
            imageUrl: watcher.image,
          ),
          twelvePx,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                  textAlign: TextAlign.left,
                  textToDisplay: watcher.username ?? '',
                  textStyle: context.getTextTheme().bodyText2?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                fourPx,
                CustomTextWidget(
                  textAlign: TextAlign.left,
                  textToDisplay: watcher.name ?? '',
                  textStyle: context.getTextTheme().caption?.copyWith(
                      fontWeight: FontWeight.w400, color: kHyppeBurem),
                ),
              ],
            ),
          ),
          tenPx,
          CustomGesture(
            margin: EdgeInsets.zero,
            onTap: () {},
            child: Container(
              width: 86,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: watcher.isFollowing
                    ? context.getColorScheme().primary.withOpacity(0.85)
                    : kHyppeBurem.withOpacity(0.25),
              ),
              alignment: Alignment.center,
              child: CustomTextWidget(
                textToDisplay: !watcher.isFollowing ? (language.following ?? '') : (language.follow ?? ''),
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: watcher.isFollowing ? Colors.white : Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }
}
