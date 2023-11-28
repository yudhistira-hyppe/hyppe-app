import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:provider/provider.dart';

class BuildEffect extends StatelessWidget {
  final bool? mounted;
  final bool isRecord;
  const BuildEffect({Key? key, this.mounted, this.isRecord = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraNotifier>(
      builder: (_, notifier, __) => SizedBox(
        width: 41 * SizeConfig.scaleDiagonal,
        height: 41 * SizeConfig.scaleDiagonal,
        child: Center(
          child: GestureDetector(
            onTap: () {
              // notifier.showEffect();
              ShowBottomSheet.onShowEffect(context: context, whenComplete: () {});
            },
            child: const SizedBox(
                height: 100,
                width: 100,
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
