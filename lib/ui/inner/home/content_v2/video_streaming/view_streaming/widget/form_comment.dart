import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/iconButton.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../constant/widget/custom_text_button.dart';
import '../notifier.dart';

class FormCommentViewer extends StatefulWidget {
  final FocusNode? commentFocusNode;
  const FormCommentViewer({super.key, this.commentFocusNode});

  @override
  State<FormCommentViewer> createState() => _FormCommentViewerState();
}

class _FormCommentViewerState extends State<FormCommentViewer> {
  final _debouncer = Debouncer(milliseconds: 2000);

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewStreamingNotifier>(builder: (context, notifier, _) {
      final tn = notifier.language;
      return Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            // height: 48 * SizeConfig.scaleDiagonal,
            child: Stack(
              children: [
                TextFormField(
                  focusNode: widget.commentFocusNode,
                  controller: notifier.commentController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  enabled: !notifier.isCommentDisable,
                  decoration: InputDecoration(
                      hintText: notifier.isCommentDisable ? tn.commentsAreDisabled : tn.addComment,
                      isDense: true, // important line
                      contentPadding: EdgeInsets.fromLTRB(10, 10, widget.commentFocusNode!.hasFocus ? 70 : 10, 10), // control your hints text size
                      hintStyle: const TextStyle(color: Colors.white),
                      fillColor: kHyppeTransparent,
                      filled: true,
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)), borderSide: BorderSide.none),
                      enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)), borderSide: BorderSide.none),
                      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)), borderSide: BorderSide.none)),
                ),
                !widget.commentFocusNode!.hasFocus
                    ? Container()
                    : Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CustomTextButton(
                              onPressed: () {
                                if (notifier.streamerData != null) {
                                  notifier.sendComment(context, notifier.streamerData!, notifier.commentController.text);
                                }
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(kHyppePrimary),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                  )),
                              child: Text(
                                tn.send ?? '',
                                style: TextStyle(color: kHyppeTextPrimary),
                              )),
                        )),
              ],
            ),
          ),

          widget.commentFocusNode!.hasFocus
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButtonLive(
                      widget: Align(
                        alignment: Alignment.center,
                        child: CustomIconWidget(
                          iconData: "${AssetPath.vectorPath}${notifier.isClicked ? 'ic_like_red.svg' : 'ic_like_stroke.svg'}",
                          // color: Colors.white,
                          defaultColor: false,
                          height: 24,
                        ),
                      ),
                      onClicked: (state){
                        notifier.isClicked = state;
                      },
                      onPressed: () {
                        notifier.likeAdd();
                        _debouncer.run(() {
                          notifier.sendLike(context, notifier.streamerData!);
                        });
                        // _debouncer.run(() {});
                      }),
                ),

          // commentFocusNode!.hasFocus
          //     ? Container()
          //     : Padding(
          //         padding: const EdgeInsets.only(left: 8.0),
          //         child: IconButtonLive(widget: const CustomIconWidget(iconData: "${AssetPath.vectorPath}share2.svg", color: Colors.white, defaultColor: false), onPressed: () {}),
          //       ),
        ],
      );
    });
  }
}