import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import '../../../../core/constants/shared_preference_keys.dart';
import '../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../core/models/collection/search/search_content.dart';
import '../../../../core/services/shared_preference.dart';
import '../../../constant/widget/custom_shimmer.dart';
import '../../../constant/widget/custom_spacer.dart';
import '../../../constant/widget/custom_text_widget.dart';
import '../widget/search_no_result.dart';

class InterestScreen extends StatefulWidget {
  Function(Interest)? onClick;
  InterestScreen({Key? key, this.onClick}) : super(key: key);

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'InterestScreen');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchNotifier>(builder: (context, notifier, child) {
      return WillPopScope(
        onWillPop: () {
          return Future.value(true);
        },
        child: notifier.loadLandingPage ? _shimmerInterests(context) : Builder(
          builder: (context) {
            final image = Image.asset(System().getPathByInterest(notifier.listInterest?[0].id ?? ''));
            final completer = Completer<ui.Image>();
            image.image
                .resolve(const ImageConfiguration()).addListener(ImageStreamListener((image, synchronousCall) {
              completer.complete(image.image);
            }));
            final locale = SharedPreference().readStorage(SpKeys.isoCode);
            final isIndo = locale == 'id';
            return FutureBuilder(
              future: completer.future,
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: Text(
                          notifier.language.findYourInterests ?? ' ',
                          style: const TextStyle(
                              color: kHyppeLightSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      (notifier.listInterest ?? []).isNotEmpty ? CustomScrollView(
                        primary: false,
                        shrinkWrap: true,
                        slivers: <Widget>[
                          SliverPadding(
                            padding: const EdgeInsets.all(10),
                            sliver: SliverGrid.count(
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              crossAxisCount: 2,
                              childAspectRatio: (snapshot.data?.width ?? 3)/(snapshot.data?.height ?? 1),
                              children: (notifier.listInterest ?? [])
                                  .map(
                                    (e){
                                  return Stack(
                                    children: [
                                      Positioned.fill(
                                          child: Container(
                                            width: double.infinity,
                                            alignment: Alignment.topRight,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(2),
                                              image: DecorationImage(
                                                fit: BoxFit.contain,
                                                image: AssetImage(System().getPathByInterest(e.id ?? '')),
                                              ),
                                            ),
                                          )),
                                      Positioned.fill(
                                          child: Material(
                                            color: Colors.transparent,
                                            child: Ink(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                onTap: () {
                                                  if(widget.onClick != null){
                                                    widget.onClick!(e);
                                                  }
                                                },
                                                splashColor:
                                                context.getColorScheme().primary,
                                                child: Container(
                                                  width: double.infinity,
                                                  alignment: Alignment.centerLeft,
                                                  margin: const EdgeInsets.only(left: 12),
                                                  child: CustomTextWidget(
                                                    textToDisplay: isIndo ? (e.interestNameId ?? '') : (e.interestName ?? ''),
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .subtitle2
                                                        ?.copyWith(color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ))
                                    ],
                                  );
                                },
                              )
                                  .toList().sublist(0, 6),
                            ),
                          ),
                        ],
                      ): SearchNoResult(locale: notifier.language, keyword: notifier.searchController.text, margin: const EdgeInsets.only(left: 16))
                    ],
                  );
                }else{
                  return Container(
                    margin: const EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: const [
                            Expanded(
                              child: CustomShimmer(
                                height: 50,
                                width: double.infinity,
                                radius: 8,
                              ),
                            ),
                            eightPx,
                            Expanded(
                              child: CustomShimmer(
                                height: 50,
                                width: double.infinity,
                                radius: 8,
                              ),
                            ),
                          ],
                        ),
                        eightPx,
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: const [
                            Expanded(
                              child: CustomShimmer(
                                height: 50,
                                width: double.infinity,
                                radius: 8,
                              ),
                            ),
                            eightPx,
                            Expanded(
                              child: CustomShimmer(
                                height: 50,
                                width: double.infinity,
                                radius: 8,
                              ),
                            ),
                          ],
                        ),
                        eightPx,
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: const [
                            Expanded(
                              child: CustomShimmer(
                                height: 50,
                                width: double.infinity,
                                radius: 8,
                              ),
                            ),
                            eightPx,
                            Expanded(
                              child: CustomShimmer(
                                height: 50,
                                width: double.infinity,
                                radius: 8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

              }
            );
          }
        ),
      );
    });
  }

  Widget _shimmerInterests(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: CustomShimmer(height: 50, width: double.infinity, radius: 8, margin: const EdgeInsets.only(right: 6),)),
              Expanded(child: CustomShimmer(height: 50, width: double.infinity, radius: 8, margin: const EdgeInsets.only(left: 6),))
            ],
          ),
          twelvePx,
          Row(
            children: [
              Expanded(child: CustomShimmer(height: 50, width: double.infinity, radius: 8, margin: const EdgeInsets.only(right: 6),)),
              Expanded(child: CustomShimmer(height: 50, width: double.infinity, radius: 8, margin: const EdgeInsets.only(left: 6),))
            ],
          ),
          twelvePx,
          Row(
            children: [
              Expanded(child: CustomShimmer(height: 50, width: double.infinity, radius: 8, margin: const EdgeInsets.only(right: 6),)),
              Expanded(child: CustomShimmer(height: 50, width: double.infinity, radius: 8, margin: const EdgeInsets.only(left: 6),))
            ],
          ),
        ],
      ),
    );
  }
}
