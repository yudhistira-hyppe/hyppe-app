import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/asset_path.dart';
import '../../../widget/custom_icon_widget.dart';

class OnChooseMusicBottomSheet extends StatelessWidget {
  const OnChooseMusicBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PreviewContentNotifier>(builder: (context, notifier, _){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          twelvePx,
          const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}handler.svg"),
          Expanded(child: const Center(
          child: Text('test show dialog')))
        ],
      );
    });
  }
}

class Music{

}
