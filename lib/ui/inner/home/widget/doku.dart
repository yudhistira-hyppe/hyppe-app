import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
// import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
// import 'package:hyppe/ui/inner/home/content/wallet/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Doku extends StatelessWidget {
  const Doku({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final waitConnect = context.select((WalletNotifier value) => value.isLoading);

    // if (waitConnect) return CustomLoading();

    return CustomTextButton(
      style: ButtonStyle(
        alignment: Alignment.centerRight,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: MaterialStateProperty.all(Size.zero),
        padding: MaterialStateProperty.all(
          const EdgeInsets.only(left: 0.0),
        ),
      ),
      onPressed: () => context.read<HomeNotifier>().navigateToWallet(context),
      child: Row(
        children: [
          const CustomIconWidget(
            defaultColor: false,
            iconData: "${AssetPath.vectorPath}Doku.svg",
          ),
          fourPointEighteenPx,
          CustomTextWidget(maxLines: 1, textToDisplay: "Rp.0", textAlign: TextAlign.left, textStyle: Theme.of(context).textTheme.caption)
        ],
      ),
    );
  }
}
