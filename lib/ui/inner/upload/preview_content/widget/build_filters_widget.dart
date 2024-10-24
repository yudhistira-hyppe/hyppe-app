import 'package:hyppe/core/constants/asset_path.dart';
// import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildFiltersWidget extends StatelessWidget {
  final GlobalKey? globalKey;
  final GlobalKey<ScaffoldState> scaffoldState;
  const BuildFiltersWidget(
      {Key? key, required this.scaffoldState, this.globalKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PreviewContentNotifier>(
      builder: (_, notifier, __) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IgnorePointer(
              ignoring: notifier.addTextItemMode,
              child: _buildButton(context,
                  caption: notifier.language.filter ?? '',
                  iconData: "${AssetPath.vectorPath}filters.svg",
                  onPressed: () => context
                          .read<PreviewContentNotifier>()
                          .isSheetOpen
                      ? context.read<PreviewContentNotifier>().closeFilters()
                      : context
                          .read<PreviewContentNotifier>()
                          .showFilters(context, scaffoldState, globalKey)),
            ),
            sixteenPx,
            IgnorePointer(
              ignoring: notifier.isSheetOpen,
              child: _buildButton(context,
                  caption: notifier.language.text ?? '',
                  iconData: "${AssetPath.vectorPath}texts.svg",
                  onPressed: () => context
                      .read<PreviewContentNotifier>()
                      .addTextItem(context)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton(BuildContext context,
      {required String iconData,
      required String caption,
      required VoidCallback onPressed}) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(iconData: iconData),
          sixPx,
          CustomTextWidget(
              textToDisplay: caption,
              textStyle: Theme.of(context).textTheme.bodySmall)
        ],
      ),
    );
  }
}
