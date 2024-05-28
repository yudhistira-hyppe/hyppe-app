import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/view_streaming_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/live_stream/link_stream_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';
import 'package:hyppe/ui/inner/message_v2/message_detail/widget/content_message_layout.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ReceiverLayout extends StatelessWidget {
  final DisqusLogs? chatData;
  final String? created;

  const ReceiverLayout({Key? key, this.chatData, this.created}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ReceiverLayout');
    SizeConfig().init(context);
    var translate = context.read<TranslateNotifierV2>().translate;

    Widget shareLive = Container();
    if (chatData?.medias.isNotEmpty ?? [].isNotEmpty) {
      if (chatData?.medias.first.sId != null) {
        var orginial = chatData?.medias.first.user?.avatar?.mediaEndpoint!.split('/');
        var endpoint = "/profilepict/orignal/${orginial?.last}";
        shareLive = Container(
          padding: EdgeInsets.only(bottom: 10 * SizeConfig.scaleDiagonal),
          constraints: BoxConstraints(
            maxWidth: SizeConfig.screenWidth! * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${translate.localeDatetime == 'id' ? 'Mengirimkan siaran LIVE' : 'Sent a LIVE by'} @${chatData?.medias.first.user?.username}',
                style: const TextStyle(color: kHyppeBurem),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Routing().move(
                      Routes.viewStreaming,
                      argument: ViewStreamingArgument(
                        data: LinkStreamModel(
                          sId: chatData?.medias.first.sId,
                        ),
                      ),
                    );
                  },
                  child: IntrinsicHeight(
                    child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Container(width: 2, color: kHyppeRank4),
                      twelvePx,
                      Expanded(
                        child: IntrinsicHeight(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(topRight: Radius.circular(8)),
                              child: Stack(
                                children: [
                                  CustomCacheImage(
                                    imageBuilder: (context, imageProvider) {
                                      return ClipRRect(
                                        borderRadius: const BorderRadius.only(topRight: Radius.circular(8)),
                                        child: Image(
                                          image: imageProvider,
                                          fit: BoxFit.fitHeight,
                                          width: SizeConfig.screenWidth,
                                          // height: picData?.imageHeightTemp == 0 || (picData?.imageHeightTemp ?? 0) <= 100 ? null : picData?.imageHeightTemp,
                                        ),
                                      );
                                    },
                                    imageUrl: System().showUserPicture(endpoint),
                                    emptyWidget: Container(
                                      height: 50,
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          fit: BoxFit.contain,
                                          image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                      child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0 * SizeConfig.scaleDiagonal),
                                      child: Row(
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CustomProfileImage(
                                            cacheKey: '',
                                            following: true,
                                            forStory: false,
                                            width: 26 * SizeConfig.scaleDiagonal,
                                            height: 26 * SizeConfig.scaleDiagonal,
                                            imageUrl: System().showUserPicture(chatData?.medias.first.user?.avatar?.mediaEndpoint),
                                            allwaysUseBadgePadding: true,
                                          ),
                                          sixPx,
                                          Expanded(
                                            child: Text(
                                              chatData?.medias.first.user?.username ?? '',
                                              style: const TextStyle(color: kHyppeTextPrimary),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: kHyppeLightDanger,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'LIVE',
                                              style: TextStyle(color: kHyppeTextPrimary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: const BoxDecoration(
                                color: kHyppePrimary,
                                borderRadius: BorderRadius.only(bottomRight: Radius.circular(8)),
                              ),
                              child: Center(
                                  child: Text(
                                (chatData?.medias.first.status ?? false)
                                    ? translate.localeDatetime == 'id'
                                        ? "Tonton Siaran LIVE"
                                        : "Watch LIVE"
                                    : translate.localeDatetime == 'id'
                                        ? "Siaran LIVE berakhir"
                                        : "LIVE has ended",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              )),
                            ),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              if (chatData?.txtMessages == 'text_kosong')
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: CustomTextWidget(
                    textAlign: TextAlign.end,
                    textStyle: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 10),
                    textToDisplay: chatData?.createdAt == null ? "" : System().dateFormatter(chatData?.createdAt ?? '', 1),
                    // textToDisplay: chatData?.createdAt == null ? "" : System().dateFormatter(created ?? '', 1),
                  ),
                ),
            ],
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        shareLive,
        // if (chatData?.txtMessages == 'text_kosong' && chatData?.medias.first.sId == null)
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.zero,
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5),
              topRight: Radius.circular(5),
            ),
          ),
          constraints: BoxConstraints(
            maxWidth: SizeConfig.screenWidth! * 0.7,
          ),
          child: Padding(
            padding: EdgeInsets.all(10 * SizeConfig.scaleDiagonal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if ((chatData?.medias.isNotEmpty ?? false) && chatData?.medias.first.sId == null)
                  ContentMessageLayout(
                    message: chatData,
                  ),
                CustomTextWidget(
                  // textToDisplay: chatData.message,
                  textAlign: TextAlign.start,
                  textOverflow: TextOverflow.clip,
                  textStyle: Theme.of(context).textTheme.bodyText2,
                  textToDisplay: chatData?.txtMessages ?? chatData?.reactionIcon ?? '',
                ),
                CustomTextWidget(
                  textAlign: TextAlign.end,
                  textStyle: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 10),
                  textToDisplay: chatData?.createdAt == null ? "" : System().dateFormatter(chatData?.createdAt ?? '', 1),
                  // textToDisplay: chatData?.createdAt == null ? "" : System().dateFormatter(created ?? '', 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
