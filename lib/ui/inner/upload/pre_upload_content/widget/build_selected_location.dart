import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildSelectedLocation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreUploadContentNotifier>(context);
    return ListTile(
      title: Text(notifier.selectedLocation,
          maxLines: 1,
          style:
              TextStyle(fontFamily: "Roboto", fontWeight: FontWeight.w400, color: const Color(0xff822E6E), fontSize: 14 * SizeConfig.scaleDiagonal)),
      leading: const CustomIconWidget(iconData: "${AssetPath.vectorPath}pin.svg"),
      trailing: GestureDetector(
        onTap: () => notifier.handleDeleteOnLocation(),
        child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}close.svg"),
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}
