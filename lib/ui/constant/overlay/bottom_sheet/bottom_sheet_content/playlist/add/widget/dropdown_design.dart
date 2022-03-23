import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/entities/playlist/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DropdownDesign extends StatelessWidget {
  final String? value;
  const DropdownDesign({Key? key, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistNotifier>(
      builder: (_, notifier, __) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomIconWidget(iconData: value == notifier.listPrivacy[0] ? "" : ""),
          CustomRichTextWidget(
            textSpan: TextSpan(text: value, style: Theme.of(context).textTheme.bodyText2, children: [
              const TextSpan(text: "\n"),
              TextSpan(
                  text: value == notifier.listPrivacy[0]
                      ? notifier.language.anyoneCanView
                      : value == notifier.listPrivacy[1]
                          ? notifier.language.onlyFriendsCanView
                          : notifier.language.onlyYouCanView,
                  style: const TextStyle(color: kHyppeBottomNavBarIcon))
            ]),
            textAlign: TextAlign.start,
          )
        ],
      ),
    );
  }
}
