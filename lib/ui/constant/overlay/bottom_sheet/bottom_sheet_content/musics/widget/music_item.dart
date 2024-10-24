import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/musics/widget/music_progress.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/constants/asset_path.dart';
import '../../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../../core/models/collection/music/music.dart';
import '../../../../../../inner/upload/preview_content/notifier.dart';
import '../../../../../widget/custom_base_cache_image.dart';

class MusicItemScreen extends StatefulWidget {
  final Music music;
  final int index;
  final bool isExplored;
  const MusicItemScreen(
      {Key? key,
      required this.music,
      required this.index,
      this.isExplored = false})
      : super(key: key);

  @override
  State<MusicItemScreen> createState() => _MusicItemScreenState();
}

class _MusicItemScreenState extends State<MusicItemScreen>
    with WidgetsBindingObserver {
  // @override
  // void dispose() {
  //   var not = context.read<PreviewContentNotifier>();
  //   not.audioPlayer.dispose();

  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreviewContentNotifier>(context);
    return InkWell(
      onTap: () {
        if (!widget.isExplored) {
          notifier.selectMusic(widget.music, widget.index);
        } else {
          notifier.selectExpMusic(widget.music, widget.index);
        }
      },
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
        width: double.infinity,
        color: widget.music.isSelected ? kSkeletonHighlightColor : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomBaseCacheImage(
                    imageUrl: widget.music.apsaraThumnailUrl,
                    imageBuilder: (_, imageProvider) {
                      return Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(24)),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: imageProvider,
                          ),
                        ),
                      );
                    },
                    errorWidget: (_, __, ___) {
                      return Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            image: AssetImage(
                                '${AssetPath.vectorPath}ic_music.svg'),
                          ),
                        ),
                      );
                    },
                    emptyWidget: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image:
                              AssetImage('${AssetPath.vectorPath}ic_music.svg'),
                        ),
                      ),
                    ),
                  ),
                  twelvePx,
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextWidget(
                          textToDisplay: widget.music.musicTitle ?? '',
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        fourPx,
                        CustomTextWidget(
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          textToDisplay:
                              '${widget.music.artistName} • ${widget.music.apsaraMusicUrl?.duration?.toInt().getMinutes() ?? '00'}',
                          textStyle: const TextStyle(
                              color: kHyppeLightSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            !widget.music.isLoad
                ? widget.music.isPlay
                    ? MusicProgress(
                        totalSeconds:
                            widget.music.apsaraMusicUrl?.duration?.toInt() ?? 0,
                        onClick: () {
                          if (!widget.isExplored) {
                            notifier.playMusic(
                                context, widget.music, widget.index);
                          } else {
                            notifier.playExpMusic(
                                context, widget.music, widget.index);
                          }
                        },
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        child: IconButton(
                          focusColor: Colors.grey,
                          icon: const CustomIconWidget(
                              iconData:
                                  "${AssetPath.vectorPath}play_circle.svg"),
                          splashRadius: 1,
                          onPressed: () {
                            if (!widget.isExplored) {
                              notifier.playMusic(
                                  context, widget.music, widget.index);
                            } else {
                              notifier.playExpMusic(
                                  context, widget.music, widget.index);
                            }
                          },
                        ),
                      )
                : UnconstrainedBox(
                    child: Container(
                      alignment: Alignment.center,
                      child: const CustomLoading(),
                      width: 48,
                      height: 48,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    print('deactive music item');
    super.deactivate();
  }
}
