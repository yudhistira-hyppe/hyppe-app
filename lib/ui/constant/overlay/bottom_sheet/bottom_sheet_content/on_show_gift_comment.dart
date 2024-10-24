import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';
import 'package:hyppe/core/models/collection/live_stream/gift_live_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/comment_v2/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/saldo_coin/saldo_coin.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/build_auto_complete_user_tag_comment.dart';
import 'package:provider/provider.dart';

class OnShowGiftCommantBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  final CommentsArgument? argument;
  final List<CommentsLogs>? comments;
  const OnShowGiftCommantBottomSheet(
      {Key? key, required this.scrollController, this.argument, this.comments})
      : super(key: key);

  @override
  State<OnShowGiftCommantBottomSheet> createState() =>
      _OnShowGiftCommantBottomSheetState();
}

class _OnShowGiftCommantBottomSheetState
    extends State<OnShowGiftCommantBottomSheet> {
  PageController? controller = PageController();
  bool firstTab = true;
  bool buttonactive = false;

  List<String> emoji = [
    '❤',
    '🙌',
    '🔥',
    '😢',
    '😍',
    '😯',
    '😂',
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentNotifierV2>().getGift(context, mounted, 'CLASSIC');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var trans = context.read<TranslateNotifierV2>().translate;
    return Consumer<CommentNotifierV2>(
      builder: (context, notifier, __) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // _tab(),
          // fifteenPx,
          Container(
            color: context.getColorScheme().surface,
            padding:
                const EdgeInsets.only(bottom: 12, left: 16, right: 16, top: 10),
            child: Column(
              children: [
                notifier.isShowAutoComplete
                    ? const AutoCompleteUserTagComment()
                    : Row(
                        children: List.generate(emoji.length, (index) {
                          return Expanded(
                            child: InkWell(
                              onTap: () {
                                context.handleActionIsGuest(() async {
                                  final currentText =
                                      notifier.commentController.text;
                                  notifier.commentController.text =
                                      "$currentText${emoji[index]}";
                                  notifier.commentController.selection =
                                      TextSelection.fromPosition(TextPosition(
                                          offset: notifier
                                              .commentController.text.length));
                                  notifier.onUpdate();
                                });
                              },
                              child: CustomTextWidget(
                                textToDisplay: emoji[index],
                                textStyle: const TextStyle(fontSize: 24),
                              ),
                            ),
                          );
                        }),
                      ),
                tenPx,
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: notifier.commentController,
                        // focusNode: notifier.inputNode,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(
                                  color: context.getColorScheme().surface)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(
                                  color: context.getColorScheme().surface)),
                          fillColor: Theme.of(context).colorScheme.background,
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(
                                  color: context.getColorScheme().surface)),
                          hintText: "${notifier.language.typeAMessage}...",
                          prefixIcon: Container(
                            margin: const EdgeInsets.only(right: 5, left: 5),
                            child: Builder(builder: (context) {
                              final urlImage = context
                                  .read<SelfProfileNotifier>()
                                  .user
                                  .profile
                                  ?.avatar
                                  ?.mediaEndpoint;
                              return CustomProfileImage(
                                width: 26,
                                height: 26,
                                imageUrl: System().showUserPicture(widget
                                        .comments
                                        ?.first
                                        .comment
                                        ?.senderInfo
                                        ?.avatar
                                        ?.mediaEndpoint ??
                                    (urlImage ?? '')),
                                badge: widget.comments?.first.comment
                                    ?.senderInfo?.urluserBadge,
                                following: true,
                              );
                            }),
                          ),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 0, minHeight: 0),
                          suffixIcon: notifier.commentController.text.isNotEmpty
                              ? notifier.loading
                                  ? const CustomLoading(size: 4)
                                  : CustomTextButton(
                                      child: CustomTextWidget(
                                        textToDisplay:
                                            notifier.language.send ?? '',
                                        textStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      onPressed: () async {
                                        await notifier.addComment(context,
                                            pageDetail:
                                                widget.argument?.pageDetail);
                                        if (context.mounted) {
                                          notifier.initState(
                                            context,
                                            widget.argument?.postID,
                                            widget.argument?.fromFront ?? false,
                                            widget.argument?.parentComment,
                                          );
                                        }
                                      },
                                    )
                              : const SizedBox.shrink(),
                        ),
                        // onChanged: (value) =>
                        //     notifier.onChangeHandler(value, context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(child: _classic(true)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: SaldoCoinWidget(
              transactionCoin: notifier.giftSelect?.price ?? 0,
              isChecking: (bool val, int saldoCoin) {
                buttonactive = val;
                setState(() {});
              },
            ),
          ),
          Consumer<CommentNotifierV2>(
            builder: (_, sn, __) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: ButtonChallangeWidget(
                  function: () {
                    if (buttonactive) {
                      print('disini ${(sn.giftSelect?.toJson())}');
                      if ((sn.giftSelect?.lastStock ?? 0) < 1) {
                        FToast().init(context);
                        if (true) FToast().removeCustomToast();
                        FToast().showToast(
                          child: Container(
                            width: SizeConfig.screenWidth,
                            decoration: BoxDecoration(
                                color: kHyppeBorderDanger,
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                ),
                                twelvePx,
                                Expanded(
                                    child: Text(
                                  (trans.localeDatetime ?? '') == 'id'
                                      ? 'Maaf stok paket gift telah habis, silakan lihat gift lainnya.'
                                      : 'Sorry, the gift package you want is out of stock. See other packages.',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                )),
                              ],
                            ),
                          ),
                          gravity: ToastGravity.BOTTOM,
                          toastDuration: const Duration(seconds: 3),
                        );
                      } else {
                        sn.sendGift(context, sn.giftSelect ?? GiftLiveModel(),
                            pageDetail: widget.argument?.pageDetail ?? false);
                      }
                    }
                  },
                  bgColor: !buttonactive ? kHyppeDisabled : kHyppePrimary,
                  text: trans.send,
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _classic(bool isClassic) {
    var trans = context.read<TranslateNotifierV2>().translate;
    return Consumer<CommentNotifierV2>(
      builder: (_, sn, __) {
        var firstData = isClassic ? sn.dataGift : sn.dataGiftDeluxe;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: sn.isloadingGift
              ? Padding(
                  padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16),
                  child: const SizedBox(
                    height: 100,
                    width: 100,
                    child: Align(
                      alignment: Alignment.center,
                      child: CustomLoading(
                        size: 6,
                      ),
                    ),
                  ),
                )
              : firstData.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          trans.emptyGift ??
                              'Gift stock will be available shortly, stay tuned! ✨',
                          style: const TextStyle(color: kHyppeBurem),
                        ),
                      ),
                    )
                  : GridView.builder(
                      itemCount: isClassic
                          ? sn.dataGift.length
                          : sn.dataGiftDeluxe.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      controller: widget.scrollController,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1 / 1,
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (context2, index) {
                        var data = isClassic
                            ? sn.dataGift[index]
                            : sn.dataGiftDeluxe[index];
                        final mimeType = System()
                                .extensionFiles(data.thumbnail ?? '')
                                ?.split('/')[0] ??
                            '';
                        String type = '';
                        if (mimeType != '') {
                          var a = mimeType.split('/');
                          type = a[0];
                        }

                        return GestureDetector(
                          onTap: () {
                            sn.giftSelect = data;
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xfffbfbfb),
                              border: Border.all(
                                  color: (sn.giftSelect?.sId ?? '') == data.sId
                                      ? kHyppePrimary
                                      : kHyppeBorderTab,
                                  width: (sn.giftSelect?.sId ?? '') == data.sId
                                      ? 2
                                      : 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Text("asd $type"),
                                // CustomIconWidget(iconData: iconData)
                                type == '.svg'
                                    ? SvgPicture.network(
                                        data.thumbnail ?? '',
                                        // 'https://www.svgrepo.com/show/1615/nurse.svg',
                                        height: 44 * SizeConfig.scaleDiagonal,
                                        // width: 30 * SizeConfig.scaleDiagonal,
                                        fit: BoxFit.cover,
                                        // semanticsLabel: 'A shark?!',
                                        // color: false,
                                        placeholderBuilder:
                                            (BuildContext context) => Container(
                                                padding:
                                                    const EdgeInsets.all(30.0),
                                                child:
                                                    const CircularProgressIndicator()),
                                      )
                                    // ? SvgPicture.asset(
                                    //     '${AssetPath.vectorPath}test.svg',
                                    //     height: 30,
                                    //     width: 30,
                                    //     semanticsLabel: 'A shark?!',
                                    //     placeholderBuilder: (BuildContext context) => Container(padding: const EdgeInsets.all(30.0), child: const CircularProgressIndicator()),
                                    //   )
                                    : SizedBox(
                                        // width: MediaQuery.of(context2).size.width,
                                        width: 44 * SizeConfig.scaleDiagonal,
                                        height: 44 * SizeConfig.scaleDiagonal,
                                        child: CustomCacheImage(
                                          imageUrl: data.thumbnail ?? '',
                                          imageBuilder: (_, imageProvider) {
                                            return Container(
                                              alignment: Alignment.topRight,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.contain),
                                              ),
                                            );
                                          },
                                          errorWidget: (_, __, ___) {
                                            return Container(
                                              alignment: Alignment.topRight,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                                image: const DecorationImage(
                                                  fit: BoxFit.contain,
                                                  image: AssetImage(
                                                      '${AssetPath.pngPath}content-error.png'),
                                                ),
                                              ),
                                            );
                                          },
                                          emptyWidget: Container(
                                            alignment: Alignment.topRight,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                              image: const DecorationImage(
                                                fit: BoxFit.contain,
                                                image: AssetImage(
                                                    '${AssetPath.pngPath}content-error.png'),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                Text(
                                  "${data.name}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: kHyppeBurem, fontSize: 12),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CustomIconWidget(
                                      height: 15,
                                      iconData:
                                          "${AssetPath.vectorPath}ic-coin.svg",
                                      defaultColor: false,
                                    ),
                                    sixPx,
                                    Text(
                                      '${data.price}',
                                      style: const TextStyle(
                                          color: kHyppeTextLightPrimary,
                                          fontWeight: FontWeight.w700),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }

  // Widget _tab() {
  //   return Container(
  //     width: double.infinity,
  //     margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
  //     padding: const EdgeInsets.all(4),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: [
  //         Expanded(
  //           child: GestureDetector(
  //             onTap: () {
  //               if (!firstTab) {
  //                 controller!.animateToPage(
  //                   0,
  //                   duration: const Duration(milliseconds: 300),
  //                   curve: Curves.easeInOut,
  //                 );
  //                 setState(() {
  //                   firstTab = true;
  //                 });
  //               }
  //             },
  //             child: AnimatedContainer(
  //               duration: const Duration(milliseconds: 300),
  //               curve: Curves.easeInOut,
  //               padding: const EdgeInsets.symmetric(
  //                 horizontal: 12,
  //                 vertical: 12,
  //               ),
  //               decoration: BoxDecoration(
  //                 border: Border(
  //                   bottom: BorderSide(color: firstTab ? kHyppePrimary : kHyppeBurem, width: 2),
  //                 ),
  //               ),
  //               child: Center(
  //                 child: Text(
  //                   'Classic',
  //                   style: Theme.of(context).textTheme.titleLarge!.copyWith(
  //                         fontSize: 14,
  //                         color: firstTab ? kHyppePrimary : kHyppeBurem,
  //                         fontWeight: FontWeight.w700,
  //                       ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           child: GestureDetector(
  //             onTap: () {
  //               if (firstTab) {
  //                 controller!.animateToPage(
  //                   1,
  //                   duration: const Duration(milliseconds: 300),
  //                   curve: Curves.easeInOut,
  //                 );
  //                 setState(() {
  //                   firstTab = false;
  //                 });
  //               }
  //             },
  //             child: AnimatedContainer(
  //               duration: const Duration(milliseconds: 300),
  //               curve: Curves.easeInOut,
  //               padding: const EdgeInsets.symmetric(
  //                 horizontal: 12,
  //                 vertical: 12,
  //               ),
  //               decoration: BoxDecoration(
  //                 border: Border(
  //                   bottom: BorderSide(color: !firstTab ? kHyppePrimary : kHyppeBurem, width: 2),
  //                 ),
  //               ),
  //               child: Center(
  //                 child: Text(
  //                   'Deluxe',
  //                   style: Theme.of(context).textTheme.titleLarge!.copyWith(
  //                         fontSize: 14,
  //                         color: !firstTab ? kHyppePrimary : kHyppeBurem,
  //                         fontWeight: FontWeight.w700,
  //                       ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
