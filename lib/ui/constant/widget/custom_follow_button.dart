import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

class CustomFollowButton extends StatelessWidget {
  final String caption;
  final Function() onPressed;
  final StatusFollowing isFollowing;

  const CustomFollowButton({
    Key? key,
    required this.caption,
    required this.onPressed,
    required this.isFollowing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    String title = '';
    bool _isNotFollowing = isFollowing == StatusFollowing.rejected || isFollowing == StatusFollowing.none;

    return Consumer<TranslateNotifierV2>(builder: (context, value, _) {
      switch (isFollowing) {
        case StatusFollowing.requested:
          title = value.translate.requested!;
          break;
        case StatusFollowing.following:
          title = value.translate.following!;
          break;
        default:
          title = value.translate.follow!;
      }
      isFollowing == StatusFollowing.requested;
      return InkWell(
        onTap: _isNotFollowing ? onPressed : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: CustomTextWidget(
            textToDisplay: title,
            textStyle: Theme.of(context).textTheme.button?.copyWith(
                  color: _isNotFollowing ? Theme.of(context).colorScheme.primaryVariant : null,
                ),
          ),
          // width: 50.0 * SizeConfig.scaleDiagonal,
        ),
      );
    });
  }
}
