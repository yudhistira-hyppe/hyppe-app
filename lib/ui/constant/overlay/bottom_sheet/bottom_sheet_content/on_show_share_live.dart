import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment_method/notifier.dart';
import 'package:provider/provider.dart';

class OnShowShareLiveBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  const OnShowShareLiveBottomSheet({Key? key, required this.scrollController}) : super(key: key);

  @override
  State<OnShowShareLiveBottomSheet> createState() => _OnShowShareLiveBottomSheetState();
}

class _OnShowShareLiveBottomSheetState extends State<OnShowShareLiveBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentMethodNotifier>(
      builder: (context, notifier, __) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * SizeConfig.scaleDiagonal),
            child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg", defaultColor: false),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16),
            child: Row(
              children: [
                _search(),
                sixPx,
                _iconButton(
                  child: CustomIconWidget(height: 23, iconData: "${AssetPath.vectorPath}link.svg", color: kHyppeTextLightPrimary, defaultColor: false),
                ),
                sixPx,
                _iconButton(
                  child: CustomIconWidget(iconData: "${AssetPath.vectorPath}share2.svg", color: kHyppeTextLightPrimary, defaultColor: false),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              // margin: EdgeInsets.only(bottom: 100),
              child: ListView.builder(
                controller: widget.scrollController,
                itemCount: 100,
                itemBuilder: (context, index) {
                  return _listUser();
                },
              ),
            ),
          ),
          Text("sad")
        ],
      ),
    );
  }

  Widget _iconButton({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kHyppeBorderTab),
      ),
      child: Material(
        color: kHyppeLightSurface,
        shape: const CircleBorder(),
        child: InkWell(
          splashColor: Colors.black,
          customBorder: const CircleBorder(),
          child: Ink(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            height: 50,
            width: 50,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _search() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: kHyppeLightSurface,
          border: Border.all(color: kHyppeBorderTab),
          borderRadius: const BorderRadius.all(
            Radius.circular(32),
          ),
        ),
        child: TextField(
          style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w400, fontSize: 16),
          decoration: InputDecoration(
              prefixIcon: CustomIconButtonWidget(
                height: 24,
                defaultColor: false,
                onPressed: () {},
                iconData: "${AssetPath.vectorPath}search.svg",
                color: kHyppeTextLightPrimary,
              ),
              hintStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: kHyppeBurem),
              hintText: 'Cari',
              contentPadding: EdgeInsets.only(top: 12),
              border: InputBorder.none,
              // focusedBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: kHyppePrimary),
              ),
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              counterText: ''),
          textInputAction: TextInputAction.search,
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _listUser() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {},
              child: CustomProfileImage(
                cacheKey: '',
                following: true,
                forStory: false,
                width: 36 * SizeConfig.scaleDiagonal,
                height: 36 * SizeConfig.scaleDiagonal,
                imageUrl: System().showUserPicture(''),
                // badge: notifier.user.profile?.urluserBadge,
                allwaysUseBadgePadding: false,
              ),
            ),
            twelvePx,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stella Hartono', style: const TextStyle(fontSize: 16, color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700)),
                  Text(
                    'stellahartono_',
                    style: const TextStyle(color: Color(0xff9b9b9b)),
                  ),
                ],
              ),
            ),
            Text('asd'),
          ],
        ),
      ),
    );
  }
}
