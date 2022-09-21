import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:provider/provider.dart';

class BuildEffect extends StatelessWidget {
  final bool? mounted;
  const BuildEffect({Key? key, this.mounted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraNotifier>(
      builder: (_, notifier, __) => SizedBox(
        width: 41 * SizeConfig.scaleDiagonal,
        height: 41 * SizeConfig.scaleDiagonal,
        child: Center(
          child: GestureDetector(
            onTap: () {
              notifier.showEffect();
            },
            child: Container(
                height: 100,
                width: 100,
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(5),
                //   border: Border.all(color: Colors.white, width: 2),
                // ),
                child: CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}setting.svg",
                  color: Colors.white,
                  defaultColor: false,
                )),
          ),
        ),
      ),
    );
  }
}
