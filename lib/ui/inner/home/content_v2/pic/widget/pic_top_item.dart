import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/size_config.dart';
import '../../../../../../core/models/collection/posts/content_v2/content_data.dart';
import '../../../../../constant/widget/custom_icon_widget.dart';

class PicTopItem extends StatelessWidget {
  final ContentData? data;
  const PicTopItem({Key? key, this.data}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'PicTopItem');
    SizeConfig().init(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if ((data?.saleAmount ?? 0) > 0)
          const CustomIconWidget(
            iconData: '${AssetPath.vectorPath}sale.svg',
            defaultColor: false,
            height: 22,
          ),
        if ((data?.certified ?? false) && (data?.saleAmount ?? 0) == 0)
          Container(
              padding: const EdgeInsets.all(3),
              child: const CustomIconWidget(
                iconData: '${AssetPath.vectorPath}ownership.svg',
                defaultColor: false,
              ))
      ],
    );
  }
}
