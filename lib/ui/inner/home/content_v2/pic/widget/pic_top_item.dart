import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_balloon_widget.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/size_config.dart';
import '../../../../../../core/models/collection/posts/content_v2/content_data.dart';
import '../../../../../constant/widget/custom_icon_widget.dart';

class PicTopItem extends StatelessWidget {
  final ContentData? data;
  const PicTopItem({Key? key, this.data}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if ((data?.saleAmount ?? 0) > 0)
          const CustomIconWidget(
            iconData: '${AssetPath.vectorPath}sale.svg',
            defaultColor: false,
          ),
        if ((data?.certified ?? false) && (data?.saleAmount ?? 0) == 0)
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.black.withOpacity(0.3),
              ),
              child: const CustomIconWidget(
                iconData: '${AssetPath.vectorPath}ownership.svg',
                defaultColor: false,
              ))
      ],
    );
  }
}
