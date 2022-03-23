import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIconNetworkWidget extends StatelessWidget {
  final Color? color;
  final String iconData;
  final double? width;
  final double? height;
  final bool defaultColor;
  const CustomIconNetworkWidget({Key? key, required this.iconData, this.color, this.width, this.height, this.defaultColor = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _themes = Theme.of(context);
    return UnconstrainedBox(
      child: SvgPicture.network(
        iconData,
        width: width,
        height: height,
        color: defaultColor ? _themes.iconTheme.color : color,
        allowDrawingOutsideViewBox: true,
        placeholderBuilder: (context) => const CustomLoading(size: 5),
      ),
    );
  }
}
