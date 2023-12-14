import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/iconButton.dart';
import 'package:provider/provider.dart';

class FormCommentLive extends StatelessWidget {
  final FocusNode? commentFocusNode;
  const FormCommentLive({super.key, this.commentFocusNode});

  @override
  Widget build(BuildContext context) {
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) => Row(
        children: [
          Expanded(
            // height: 48 * SizeConfig.scaleDiagonal,
            child: Padding(
              padding: const EdgeInsets.only(left: 0),
              child: TextFormField(
                focusNode: commentFocusNode,
                // controller: searchProvider.searchController,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                    hintText: 'hintText',
                    isDense: true, // important line
                    contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10), // control your hints text size
                    hintStyle: const TextStyle(color: Colors.white),
                    fillColor: kHyppeTransparent,
                    filled: true,
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)), borderSide: BorderSide.none),
                    enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)), borderSide: BorderSide.none),
                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)), borderSide: BorderSide.none)),
              ),
            ),
          ),
          eightPx,
          IconButtonLive(widget: const CustomIconWidget(iconData: "${AssetPath.vectorPath}share2.svg", color: Colors.white, defaultColor: false), onPressed: () {}),
          eightPx,
          IconButtonLive(
              widget: const RotationTransition(
                turns: AlwaysStoppedAnimation(90 / 360),
                child: CustomIconWidget(iconData: "${AssetPath.vectorPath}more.svg", color: Colors.white, defaultColor: false),
              ),
              onPressed: () {
                ShowBottomSheet.onStreamingOptions(context, notifier);
              }),
        ],
      ),
    );
  }
}
