import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

class CustomFollowButton extends StatelessWidget {
  final Function() onPressed;
  final StatusFollowing isFollowing;
  final bool checkIsLoading;

  const CustomFollowButton({
    Key? key,
    required this.onPressed,
    required this.isFollowing,
    required this.checkIsLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    String title = '';
    bool _isAbleToClick = isFollowing != StatusFollowing.requested;
    // bool _isNotFollowing = (isFollowing == StatusFollowing.rejected || isFollowing == StatusFollowing.none);

    return Consumer<TranslateNotifierV2>(builder: (context, value, _) {
      switch (isFollowing) {
        case StatusFollowing.requested:
          title = value.translate.requested ?? 'Requested';
          break;
        case StatusFollowing.following:
          title = value.translate.following ?? 'Following';
          break;
        default:
          title = value.translate.follow ?? 'Follow';
      }
      // isFollowing == StatusFollowing.requested;
      return InkWell(
        // onTap: _isAbleToClick ? onPressed : null,
        onTap: () async {
          await context.handleActionIsGuest(() async  {
            if (_isAbleToClick) {
              onPressed();
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: checkIsLoading
              ? const CustomLoading()
              : CustomTextWidget(
                  textToDisplay: title,
                  textStyle: Theme.of(context).textTheme.button?.copyWith(color: Theme.of(context).colorScheme.primary, fontSize: 12),
                ),
          // width: 50.0 * SizeConfig.scaleDiagonal,
        ),
      );
    });
  }
}
