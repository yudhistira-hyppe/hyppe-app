import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../constant/widget/custom_text_button.dart';
import '../notifier.dart';

class FormCommentViewer extends StatelessWidget {
  final FocusNode? commentFocusNode;
  const FormCommentViewer({super.key, this.commentFocusNode});

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewStreamingNotifier>(
      builder: (context, notifier, _){
        final tn = notifier.language;
        return Row(
          children: [
            Expanded(
              // height: 48 * SizeConfig.scaleDiagonal,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: TextFormField(
                      focusNode: commentFocusNode,
                      controller: notifier.commentController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      enabled: !notifier.isCommentDisable,
                      decoration: InputDecoration(
                          hintText: notifier.isCommentDisable ? tn.commentsAreDisabled : tn.addComment,
                          isDense: true, // important line
                          contentPadding: EdgeInsets.fromLTRB(10, 15, commentFocusNode!.hasFocus ? 80 : 10, 15), // control your hints text size
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
                      : Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CustomTextButton(
                            onPressed: () {
                              if(notifier.streamerData != null){
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
            // commentFocusNode!.hasFocus
            //     ? Container()
            //     : Padding(
            //         padding: const EdgeInsets.only(left: 8.0),
            //         child: IconButtonLive(widget: const CustomIconWidget(iconData: "${AssetPath.vectorPath}share2.svg", color: Colors.white, defaultColor: false), onPressed: () {}),
            //       ),
          ],
        );
      }
    );
  }
}
