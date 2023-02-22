import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/utils/interest/interest_data.dart';
import 'package:hyppe/ui/inner/search_v2/interest/notifier.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import '../../../../core/constants/asset_path.dart';
import '../../../../core/constants/themes/hyppe_colors.dart';
import '../../../constant/widget/custom_shimmer.dart';
import '../../../constant/widget/custom_spacer.dart';
import '../../../constant/widget/custom_text_widget.dart';

class InterestScreen extends StatefulWidget {
  List<InterestData> data;
  Function(InterestData)? onClick;
  InterestScreen({Key? key, required this.data, this.onClick}) : super(key: key);

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<InterestNotifier>(builder: (context, notifier, child) {
      return WillPopScope(
        onWillPop: () {
          return Future.value(true);
        },
        child: Builder(
          builder: (context) {
            final image = Image.asset(widget.data[0].icon ?? '');
            final completer = Completer<ui.Image>();
            image.image
                .resolve(const ImageConfiguration()).addListener(ImageStreamListener((image, synchronousCall) {
              completer.complete(image.image);
            }));
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
                      CustomScrollView(
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
                              children: widget.data
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
                                                image: AssetImage(e.icon ??
                                                    '${AssetPath.pngPath}content-error.png'),
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
                                                    textToDisplay: e.interestName ?? '',
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
                                  .toList(),
                            ),
                          ),
                        ],
                      )
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
}
