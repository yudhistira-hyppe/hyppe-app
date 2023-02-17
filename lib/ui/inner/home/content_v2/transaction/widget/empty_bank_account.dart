import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

class EmptyBankAccount extends StatelessWidget {
  Widget? textWidget;
  EmptyBankAccount({Key? key, this.textWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: CustomIconWidget(
              defaultColor: false,
              iconData: '${AssetPath.vectorPath}no-Result-Found.svg',
            ),
          ),
          textWidget ?? Container(),
        ],
      ),
    );
  }
}
