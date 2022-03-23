import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

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

    bool _isNotFollowing = isFollowing == StatusFollowing.rejected || isFollowing == StatusFollowing.none;

    return InkWell(
      onTap: _isNotFollowing ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: CustomTextWidget(
          textToDisplay: caption,
          textStyle: Theme.of(context).textTheme.button?.copyWith(
                color: _isNotFollowing ? Theme.of(context).colorScheme.primaryVariant : null,
              ),
        ),
        width: 50.0 * SizeConfig.scaleDiagonal,
      ),
    );
  }
}
