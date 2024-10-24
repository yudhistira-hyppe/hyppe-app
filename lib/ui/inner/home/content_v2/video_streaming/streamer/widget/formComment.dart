import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/iconButton.dart';
import 'package:provider/provider.dart';

class FormCommentLive extends StatelessWidget {
  final FocusNode? commentFocusNode;
  const FormCommentLive({super.key, this.commentFocusNode});

  @override
  Widget build(BuildContext context) {
    final tn = context.read<TranslateNotifierV2>().translate;
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) => Row(
        children: [
          Expanded(
            // height: 48 * SizeConfig.scaleDiagonal,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: TextFormField(
                    focusNode: commentFocusNode,
                    controller: notifier.commentCtrl,
                    maxLength: 150,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    enabled: !notifier.isCommentDisable,
                    inputFormatters: [LengthLimitingTextInputFormatter(150)],
                    onChanged: (val) => notifier.sendComment(),
                    decoration: InputDecoration(
                        counterText: '',
                        hintText: notifier.isCommentDisable ? tn.commentsAreDisabled : tn.addComment,
                        isDense: true, // important line
                        contentPadding: EdgeInsets.fromLTRB(10, 10, commentFocusNode!.hasFocus ? 70 : 10, 10), // control your hints text size
                        hintStyle: const TextStyle(color: Colors.white),
                        fillColor: kHyppeTransparent,
                        filled: true,
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)), borderSide: BorderSide.none),
                        enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)), borderSide: BorderSide.none),
                        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)), borderSide: BorderSide.none)),
                  ),
                ),
                !commentFocusNode!.hasFocus
                    ? Container()
                    : !notifier.isSendComment
                        ? const SizedBox.shrink()
                        : Positioned.fill(
                            top: 0,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: CustomTextButton(
                                    onPressed: () {
                                      if (notifier.commentCtrl.text.isNotEmpty) {
                                        notifier.sendMessage(context, context.mounted).then((value) {
                                          commentFocusNode!.unfocus();
                                          notifier.isSendComment = false;
                                        });
                                      }
                                    },
                                    style: ButtonStyle(
                                        visualDensity: VisualDensity.comfortable,
                                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                                        backgroundColor: MaterialStateProperty.all(kHyppePrimary),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18.0),
                                          ),
                                        )),
                                    child: Text(
                                      tn.send ?? '',
                                      style: const TextStyle(color: kHyppeTextPrimary, fontSize: 10),
                                    ),
                                  )),
                            ),
                          ),
              ],
            ),
          ),
          commentFocusNode!.hasFocus
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButtonLive(
                    widget: const CustomIconWidget(iconData: "${AssetPath.vectorPath}share2.svg", color: Colors.white, defaultColor: false),
                    onPressed: () {
                      ShowBottomSheet().onShowShareLive(_);
                    },
                  ),
                ),
          commentFocusNode!.hasFocus
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButtonLive(
                      widget: const RotationTransition(
                        turns: AlwaysStoppedAnimation(90 / 360),
                        child: Align(alignment: Alignment.center, child: CustomIconWidget(width: 24, iconData: "${AssetPath.vectorPath}more.svg", color: Colors.white, defaultColor: false)),
                      ),
                      onPressed: () {
                        ShowBottomSheet.onStreamingOptions(context, notifier);
                      }),
                ),
          // Container(
          //   decoration: const BoxDecoration(
          //     shape: BoxShape.circle,
          //   ),
          //   child: Material(
          //     shape: const CircleBorder(),
          //     child: InkWell(
          //       splashColor: Colors.black,
          //       onTap: () {
          //         ShowBottomSheet().onShowGiftLive(_);
          //       },
          //       onTapUp: (val) {},
          //       customBorder: const CircleBorder(),
          //       child: Ink(
          //         decoration: const BoxDecoration(
          //           shape: BoxShape.circle,
          //           gradient: LinearGradient(
          //             colors: [Color(0xff7552C0), Color(0xffAB22AF)],
          //             stops: [0.25, 0.75],
          //             begin: Alignment.centerLeft,
          //             end: Alignment.centerRight,
          //           ),
          //         ),
          //         height: 40,
          //         width: 40,
          //         child: Image.asset("${AssetPath.pngPath}gift.png"),
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
