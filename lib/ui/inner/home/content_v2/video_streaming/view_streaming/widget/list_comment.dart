import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/live_stream/link_stream_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/screen.dart';
import 'package:provider/provider.dart';
import '../../../../../../../core/constants/size_config.dart';
import '../../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../../core/services/system.dart';
import '../../../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../../../../constant/widget/custom_profile_image.dart';
import '../../../../../../constant/widget/custom_spacer.dart';
import '../../../profile/self_profile/notifier.dart';
import '../notifier.dart';

class ListCommentViewer extends StatelessWidget {
  final FocusNode? commentFocusNode;
  final LinkStreamModel? data;
  const ListCommentViewer({super.key, this.commentFocusNode, this.data});

  @override
  Widget build(BuildContext context) {
    var translate = context.read<TranslateNotifierV2>().translate;
    final debouncer = Debouncer(milliseconds: 2000);
    return Consumer<ViewStreamingNotifier>(
      builder: (context, notifier, __) => SizedBox(
        height: context.getHeight() * (commentFocusNode!.hasFocus ? 0.15 : 0.3),
        width: SizeConfig.screenWidth! * 0.9,
        child: notifier.isCommentDisable
            ? Container()
            : GestureDetector(
                onTap: () {
                  commentFocusNode!.unfocus();
                },
                onDoubleTapDown: (details) {
                  var position = details.globalPosition;
                  notifier.positionDxDy = position;
                },
                onDoubleTap: () {
                  notifier.likeAddTapScreen();
                  debouncer.run(() {
                    notifier.sendLikeTapScreen(context, notifier.streamerData!);
                  });
                },
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: AnimatedList(
                    key: notifier.listKey,
                    padding: EdgeInsets.zero,
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
                            // ShowBottomSheet.onWatcherStatus(context, notifier.comment[index].email ?? '');
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      final email = (context.read<SelfProfileNotifier>().user.profile?.email);
                                      if (email != notifier.comment[index].email) {
                                        context.read<ViewStreamingNotifier>().buttonSheetProfil = false;
                                        ShowBottomSheet.onWatcherStatus(context, notifier.comment[index].email ?? '', data.sId ?? '', isViewer: true);
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
                                  // Text("${notifier.comment[index].commentType}"),
                                  Expanded(
                                    child: notifier.comment[index].commentType == 'MESSAGGES'
                                        ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text.rich(TextSpan(
                                                text: notifier.comment[index].username ?? '',
                                                style: const TextStyle(color: Color(0xffcecece), fontWeight: FontWeight.w700),
                                              )),
                                              // Text(
                                              //   notifier.comment[index].username ?? '',
                                              //   style: const TextStyle(color: Color(0xffcecece), fontWeight: FontWeight.w700),
                                              // ),
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
                                                  TextSpan(
                                                    text: ' ${translate.localeDatetime == 'id' ? 'bergabung' : 'joined'}',
                                                    style: const TextStyle(color: kHyppeTextPrimary, fontWeight: FontWeight.w700),
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
                                                                    margin: const EdgeInsets.only(left: 8),
                                                                    width: 30 * SizeConfig.scaleDiagonal,
                                                                    height: 30 * SizeConfig.scaleDiagonal,
                                                                    decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(data.urlGiftThum ?? ''))),
                                                                  ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                  ),
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
