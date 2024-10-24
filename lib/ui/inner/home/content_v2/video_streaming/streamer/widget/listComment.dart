import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:provider/provider.dart';

class ListCommentLive extends StatelessWidget {
  final FocusNode? commentFocusNode;
  const ListCommentLive({super.key, this.commentFocusNode});

  @override
  Widget build(BuildContext context) {
    var translate = context.read<TranslateNotifierV2>().translate;
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) => SizedBox(
        height: SizeConfig.screenHeight! * (commentFocusNode!.hasFocus ? 0.15 : 0.3),
        width: SizeConfig.screenWidth! * 0.9,
        child: notifier.isCommentDisable
            ? Container()
            : GestureDetector(
                onDoubleTap: () {
                  notifier.flipCamera();
                },
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: AnimatedList(
                    key: notifier.listKey,
                    reverse: true,
                    shrinkWrap: true,
                    initialItemCount: notifier.comment.length,
                    itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                      var data = notifier.comment[index];
                      String type = '';
                      if (data.commentType == 'GIFT') {
                        final mimeType = System().extensionFiles(data.urlGiftThum ?? '')?.split('/')[0] ?? '';
                        if (mimeType != '') {
                          var a = mimeType.split('/');
                          type = a[0];
                        }
                      }

                      return FadeTransition(
                        opacity: animation,
                        child: GestureDetector(
                          onLongPress: () {
                            if (notifier.comment[index].commentType == 'MESSAGGES') {
                              ShowBottomSheet().onShowCommentOptionLive(context, notifier.comment[index]);
                            }
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (notifier.userName != notifier.comment[index].username) {
                                        ShowBottomSheet.onWatcherStatus(
                                          context,
                                          notifier.comment[index].email ?? '',
                                          notifier.dataStream.sId ?? '',
                                        );
                                      }
                                    },
                                    child: CustomProfileImage(
                                      cacheKey: '',
                                      following: true,
                                      forStory: false,
                                      width: 26 * SizeConfig.scaleDiagonal,
                                      height: 26 * SizeConfig.scaleDiagonal,
                                      imageUrl: System().showUserPicture(
                                        notifier.comment[index].avatar?.mediaEndpoint,
                                      ),
                                      // badge: notifier.user.profile?.urluserBadge,
                                      allwaysUseBadgePadding: false,
                                    ),
                                  ),
                                  twelvePx,
                                  Expanded(
                                    child: notifier.comment[index].commentType == 'MESSAGGES'
                                        ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text.rich(TextSpan(
                                                text: notifier.comment[index].username ?? '',
                                                style: const TextStyle(color: Color(0xffcecece), fontWeight: FontWeight.w700),
                                              )),

                                              // Text(
                                              //   notifier.comment[index].username ?? '',
                                              //   style: const TextStyle(color: Color(0xffcecece), fontWeight: FontWeight.w700),
                                              // ),
                                              if (notifier.comment[index].messages != 'joined')
                                                Text(
                                                  notifier.comment[index].messages ?? '',
                                                  style: const TextStyle(color: kHyppeTextPrimary),
                                                ),
                                            ],
                                          )
                                        : notifier.comment[index].commentType == 'JOIN'
                                            ? Text.rich(
                                                TextSpan(text: notifier.comment[index].username ?? '', style: const TextStyle(color: Color(0xffcecece), fontWeight: FontWeight.w700), children: [
                                                if (notifier.comment[index].messages == 'joined')
                                                  const TextSpan(
                                                    text: ' joined',
                                                    style: TextStyle(color: kHyppeTextPrimary, fontWeight: FontWeight.w700),
                                                  ),
                                              ]))
                                            : Row(
                                                children: [
                                                  Expanded(
                                                    child: RichText(
                                                      text: TextSpan(
                                                        text: notifier.comment[index].username ?? '',
                                                        style: const TextStyle(color: Color(0xffcecece), fontWeight: FontWeight.w700),
                                                        children: [
                                                          TextSpan(
                                                            text: " ${translate.sent} ${notifier.comment[index].messages}",
                                                            style: const TextStyle(color: Colors.white),
                                                          ),
                                                          WidgetSpan(
                                                            alignment: PlaceholderAlignment.middle,
                                                            child: type == '.svg'
                                                                ? SvgPicture.network(
                                                                    data.urlGiftThum ?? '',
                                                                    height: 30 * SizeConfig.scaleDiagonal,
                                                                    width: 30 * SizeConfig.scaleDiagonal,
                                                                    semanticsLabel: 'A shark?!',
                                                                    placeholderBuilder: (BuildContext context) =>
                                                                        Container(padding: const EdgeInsets.all(30.0), child: const CircularProgressIndicator()),
                                                                  )
                                                                : Container(
                                                                    alignment: Alignment.centerLeft,
                                                                    margin: const EdgeInsets.only(left: 8),
                                                                    width: 25 * SizeConfig.scaleDiagonal,
                                                                    height: 25 * SizeConfig.scaleDiagonal,
                                                                    decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(data.urlGiftThum ?? ''))),
                                                                  ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
