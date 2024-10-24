import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:measured_size/measured_size.dart';
import 'package:provider/provider.dart';

import '../../../../../core/models/collection/search/search_content.dart';
import 'hastag_tab.dart';

class BottomDetail extends StatefulWidget {
  final Tags hashtag;
  final bool fromRoute;
  final double tab;
  final ScrollController scrollController;
  const BottomDetail({Key? key, required this.hashtag, required this.tab, this.fromRoute = false, required this.scrollController}) : super(key: key);

  @override
  State<BottomDetail> createState() => _BottomDetailState();
}

class _BottomDetailState extends State<BottomDetail> {
  @override
  void initState() {
    final notif = context.read<SearchNotifier>();
    notif.initAllHasNext();
    FirebaseCrashlytics.instance.setCustomKey('layout', 'BottomDetail');
    widget.scrollController.addListener(() {
      if (widget.scrollController.offset >= widget.scrollController.position.maxScrollExtent && !widget.scrollController.position.outOfRange) {
        final notifier = context.read<SearchNotifier>();
        final key = widget.hashtag.tag ?? ' ';
        final type = notifier.hashtagTab;
        notifier.getDetailHashtag(context, key.replaceAll(' ', ''), reload: false, hyppe: type);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // widget.scrollController.dispose();
    super.dispose();
  }

  double bottomTab = 0.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchNotifier>(builder: (context, notifier, _) {
      return Container(
        color: context.getColorScheme().surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MeasuredSize(
              onChange: (value) {
                if (mounted) {
                  setState(() {
                    bottomTab = value.height;
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 16),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: context.getColorScheme().background),
                child: Row(
                  children: [
                    Expanded(
                        child: HashtagTab(
                            onTap: (value) {
                              notifier.hashtagTab = value;
                            },
                            isActive: notifier.hashtagTab == HyppeType.HyppePic,
                            // data: data.pict ?? [],
                            type: HyppeType.HyppePic)),
                    // Expanded(
                    //     child: HashtagTab(
                    //         onTap: (value) {
                    //           notifier.hashtagTab = value;
                    //         },
                    //         isActive: notifier.hashtagTab == HyppeType.HyppeDiary,
                    //         // data: data.diary ?? [],
                    //         type: HyppeType.HyppeDiary)),
                    Expanded(
                        child: HashtagTab(
                      onTap: (value) {
                        notifier.hashtagTab = value;
                      },
                      isActive: notifier.hashtagTab == HyppeType.HyppeVid,
                      // data: data.vid ?? [],
                      type: HyppeType.HyppeVid,
                    )),
                  ],
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                strokeWidth: 2.0,
                color: context.getColorScheme().primary,
                onRefresh: () => notifier.getDetailHashtag(context, widget.hashtag.tag ?? 'tag', force: true),
                child: CustomScrollView(
                  controller: widget.scrollController,
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: notifier.getGridHashtag(widget.hashtag.tag ?? '-', widget.fromRoute, widget.scrollController, widget.tab + bottomTab),
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
