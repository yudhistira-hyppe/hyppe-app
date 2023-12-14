import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../core/services/shared_preference.dart';
import '../../../../../../ux/routing.dart';
import '../../../../widget/custom_gesture.dart';
import '../../../../widget/custom_icon_widget.dart';
import '../../../../widget/custom_profile_image.dart';
import '../../../../widget/custom_spacer.dart';
import '../../../general_dialog/show_general_dialog.dart';

class OnLiveStreamStatus extends StatefulWidget {
  const OnLiveStreamStatus({super.key});

  @override
  State<OnLiveStreamStatus> createState() => _OnLiveStreamStatusState();
}

class _OnLiveStreamStatusState extends State<OnLiveStreamStatus> {
  final wacthers = const [
    Watcher(
        image:
            'https://images.rawpixel.com/image_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvMjc5LXBhaTE1NzktbmFtLmpwZw.jpg',
        username: 'marcelardianto_',
        name: 'Marcel'),
    Watcher(
        image:
            'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?cs=srgb&dl=pexels-pixabay-415829.jpg&fm=jpg',
        username: 'angela_gunawan',
        name: 'Guns'),
    Watcher(
        image:
            'https://www.shutterstock.com/image-photo/portrait-young-beautiful-woman-perfect-600nw-2228044151.jpg',
        username: 'stephanie.wijaya',
        name: 'stephanis'),
    Watcher(
        image:
            'https://i.pinimg.com/736x/ec/35/7b/ec357b956cbb9da835c2feefe74e56fb.jpg',
        username: 'deni.riwanto',
        name: 'Deni'),
  ];

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    final isIndo = SharedPreference().readStorage(SpKeys.isoCode) == 'id';
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
      decoration: BoxDecoration(
        color: context.getColorScheme().background,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          topLeft: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}handler.svg"),
          sixteenPx,
          CustomTextWidget(
            textToDisplay: "${isIndo ? language.liveVideo : '' }natalia.jessica${!isIndo ? language.liveVideo : '' }",
            textStyle: context
                .getTextTheme()
                .bodyText1
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          sixteenPx,
          CustomTextWidget(
            textAlign: TextAlign.left,
            textToDisplay: language.liveHost ?? '',
            textStyle: context
                .getTextTheme()
                .bodyText2
                ?.copyWith(fontWeight: FontWeight.w700, color: kHyppeBurem),
          ),
          sixteenPx,
          const ItemAccount(
              urlImage:
                  'https://storage.googleapis.com/pai-images/52723c8072804e4493c246ca8aef68a1.jpeg',
              name: 'Natalia Jessica',
              username: 'natalia.jessica'),
          eightPx,
          CustomTextWidget(
            textAlign: TextAlign.left,
            textToDisplay: language.whosWatching ?? '',
            textStyle: context
                .getTextTheme()
                .bodyText2
                ?.copyWith(fontWeight: FontWeight.w700, color: kHyppeBurem),
          ),
          eightPx,
          Expanded(
            child: ListView.builder(
              itemCount: wacthers.length,
              itemBuilder: (context, index) {
                final watcher = wacthers[index];
                return ItemAccount(
                  urlImage: watcher.image ?? '',
                  name: watcher.name ?? '',
                  username: watcher.username ?? '',
                  isHost: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Watcher {
  final String? image;
  final String? username;
  final String? name;
  final bool isFollowing;
  const Watcher({this.image, this.username, this.name, this.isFollowing = true});
}

class ItemAccount extends StatelessWidget {
  final String urlImage;
  final String username;
  final String name;
  final bool isHost;
  const ItemAccount(
      {super.key,
      required this.urlImage,
      required this.name,
      required this.username,
      this.isHost = true});

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomProfileImage(
            width: 36,
            height: 36,
            following: true,
            imageUrl: urlImage,
          ),
          twelvePx,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                  textAlign: TextAlign.left,
                  textToDisplay: username,
                  textStyle: context.getTextTheme().bodyText2?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                fourPx,
                CustomTextWidget(
                  textAlign: TextAlign.left,
                  textToDisplay: "$name${isHost ? " • Host" : ''}",
                  textStyle: context.getTextTheme().caption?.copyWith(
                      fontWeight: FontWeight.w400, color: kHyppeBurem),
                ),
              ],
            ),
          ),
          if (!isHost) tenPx,
          if (!isHost)
            CustomGesture(
              margin: EdgeInsets.zero,
              onTap: () async {
                await ShowGeneralDialog.generalDialog(
                    context,
                    titleText: "${language.remove} $username?",
                    bodyText: "${language.messageRemoveUser1} $username ${language.messageRemoveUser2}",
                    maxLineTitle: 1,
                    maxLineBody: 4,
                    functionPrimary: () async {
                      Routing().moveBack();
                    },
                    functionSecondary: () {
                      Routing().moveBack();
                    },
                    titleButtonPrimary: "${language.remove}",
                    titleButtonSecondary: "${language.cancel}",
                    barrierDismissible: true,
                    isHorizontal: false
                );
              },
              child: Container(
                width: 86,
                height: 24,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.transparent,
                    border: Border.all(color: kHyppeBurem, width: 1)),
                alignment: Alignment.center,
                child: CustomTextWidget(
                  textToDisplay: language.removeUser ?? '',
                  textAlign: TextAlign.center,
                  textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
