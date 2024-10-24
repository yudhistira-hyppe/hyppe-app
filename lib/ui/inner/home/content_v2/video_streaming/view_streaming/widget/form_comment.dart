import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/live_stream/link_stream_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/setting/setting_notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/iconButton.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../constant/widget/custom_text_button.dart';
import '../notifier.dart';

class FormCommentViewer extends StatefulWidget {
  final FocusNode? commentFocusNode;
  final LinkStreamModel? data;
  // final FlutterAliplayer? fAliplayer;
  const FormCommentViewer({super.key, this.commentFocusNode, this.data});

  @override
  State<FormCommentViewer> createState() => _FormCommentViewerState();
}

class _FormCommentViewerState extends State<FormCommentViewer> {
  final _debouncer = Debouncer(milliseconds: 2000);
  String comment = '';

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
                  maxLength: 150,
                  onChanged: (value) {
                    setState(() {
                      comment = value;
                    });
                  },
                  onFieldSubmitted: (val) {
                    // print(val);
                    if (Platform.isIOS) {
                      if (notifier.streamerData != null) {
                        setState(() {
                          comment = '';
                        });
                        if (notifier.commentController.text.isNotOnlySpace()) {
                          notifier.sendComment(context, notifier.streamerData!, notifier.commentController.text);
                        }
                      }
                    }
                  },
                  inputFormatters: [LengthLimitingTextInputFormatter(150)],
                  decoration: InputDecoration(
                      counterText: '',
                      hintText: notifier.isCommentDisable ? tn.commentsAreDisabled : tn.addComment,
                      isDense: true, // important line
                      contentPadding: EdgeInsets.fromLTRB(10, 10, widget.commentFocusNode!.hasFocus ? 80 : 10, 10), // control your hints text size
                      hintStyle: const TextStyle(color: Colors.white),
                      fillColor: kHyppeTransparent,
                      filled: true,
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)), borderSide: BorderSide.none),
                      enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)), borderSide: BorderSide.none),
                      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)), borderSide: BorderSide.none)),
                ),
                !widget.commentFocusNode!.hasFocus
                    ? Container()
                    : comment == ''
                        ? Container()
                        : comment.trim().isEmpty
                            ? const SizedBox.shrink()
                            : Positioned.fill(
                                top: 0,
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      height: 24,
                                      width: 75,
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: CustomTextButton(
                                          onPressed: () {
                                            if (notifier.streamerData != null) {
                                              setState(() {
                                                comment = '';
                                              });
                                              if (notifier.commentController.text.isNotOnlySpace()) {
                                                notifier.sendComment(context, notifier.streamerData!, notifier.commentController.text);
                                              }
                                            }
                                          },
                                          style: ButtonStyle(
                                              visualDensity: VisualDensity.comfortable,
                                              backgroundColor: MaterialStateProperty.all(kHyppePrimary),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(18.0),
                                                ),
                                              )),
                                          child: Text(
                                            tn.send ?? '',
                                            style: const TextStyle(color: kHyppeTextPrimary),
                                          )),
                                    )),
                              )
              ],
            ),
          ),

          widget.commentFocusNode!.hasFocus
              ? Container()
              : GestureDetector(
                  onTap: () {
                    // notifier.reportfAliplayer = widget.fAliplayer;
                    notifier.reportdata = widget.data;
                    print('data ===== ${widget.data}');
                    notifier.buttonSheetReport = false;
                    ShowBottomSheet.onViewerOptions(context, notifier);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.black.withOpacity(.3),
                      child: const Center(
                          child: Icon(
                        Icons.more_horiz,
                        color: Colors.white,
                      )),
                    ),
                  ),
                ),

          widget.commentFocusNode!.hasFocus
              ? Container()
              : GestureDetector(
                  onTap: () {
                    notifier.buttonSheetShare = true;
                    ShowBottomSheet().onShowShareLive(context, isViewer: true, whencomplete: (() => notifier.buttonSheetShare = false));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.black.withOpacity(.3),
                      child: const Center(
                        child: CustomIconWidget(
                          iconData: "${AssetPath.vectorPath}share2.svg",
                          color: Colors.white,
                          defaultColor: false,
                        ),
                      ),
                    ),
                  ),
                ),

          if (!widget.commentFocusNode!.hasFocus && (notifier.dataStreaming.user?.giftActivation ?? false))
            Container(
              padding: const EdgeInsets.only(left: 8.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Material(
                shape: const CircleBorder(),
                child: InkWell(
                  splashColor: Colors.black,
                  onTap: () async {
                    final userKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);
                    if (userKyc == VERIFIED) {
                      notifier.buttonSheetGift = true;
                      notifier.giftSelect = null;
                      ShowBottomSheet().onShowGiftLive(
                        context,
                        idViewStream: notifier.dataStreaming.sId,
                        whencomplate: () {
                          notifier.buttonSheetGift = false;
                        },
                      );
                    } else {
                      notifier.buttonSheetValidateUser = true;
                      context.read<SettingNotifier>().validateUserGif(context, context.read<TranslateNotifierV2>()).whenComplete(() => notifier.buttonSheetValidateUser = false);
                    }
                  },
                  onTapUp: (val) {},
                  customBorder: const CircleBorder(),
                  child: Ink(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xff7552C0), Color(0xffAB22AF)],
                        stops: [0.25, 0.75],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    height: 38,
                    width: 38,
                    child: Image.asset("${AssetPath.pngPath}gift.png"),
                  ),
                ),
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
                          color: notifier.isClicked ? null : Colors.white,
                          defaultColor: false,
                          height: 22,
                        ),
                      ),
                      onClicked: (state) {
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
