import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';

class SignUpLoadMoreList extends StatelessWidget {
  final String caption;
  const SignUpLoadMoreList({Key? key, required this.caption}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.screenWidth,
      height: 45,
      color: kHyppePrimary,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CustomLoading(),
          CustomTextWidget(
            textToDisplay: caption,
            textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppeLightButtonText),
          ),
        ],
      ),
    );
  }
}
