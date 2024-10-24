import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_network_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_interest/user_interest_notifier.dart';
import 'package:provider/provider.dart';

class InterestUserOverviewTile extends StatefulWidget {
  @override
  _InterestUserOverviewTileState createState() =>
      _InterestUserOverviewTileState();
}

class _InterestUserOverviewTileState extends State<InterestUserOverviewTile> {
  @override
  void initState() {
    Provider.of<UserInterestNotifier>(context, listen: false)
        .onGetInterest(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance
        .setCustomKey('layout', 'InterestUserOverviewTile');
    return Consumer<UserInterestNotifier>(
      builder: (_, notifier, __) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: notifier.interest.isNotEmpty ? notifier.interest.length : 16,
        padding: const EdgeInsets.all(11),
        itemBuilder: (context, index) => CustomTextButton(
          onPressed: notifier.insertInterest(index),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                width: 1,
                color: notifier.interest.isNotEmpty
                    ? notifier.pickedInterest(notifier.interest[index].id)
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent
                    : Colors.transparent,
              ),
            ),
            child: notifier.interest.isNotEmpty
                ? Stack(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Visibility(
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: CustomIconWidget(
                              defaultColor: false,
                              width: 15,
                              height: 15,
                              iconData:
                                  "${AssetPath.vectorPath}user-verified.svg",
                            ),
                          ),
                          visible: notifier
                                  .pickedInterest(notifier.interest[index].id)
                              ? true
                              : false,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomIconNetworkWidget(
                                defaultColor: false,
                                width: 55 * SizeConfig.scaleDiagonal,
                                iconData: notifier.interest[index].icon ?? '',
                                color: notifier.pickedInterest(
                                        notifier.interest[index].id)
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).iconTheme.color,
                              ),
                              CustomTextWidget(
                                textAlign: TextAlign.left,
                                textOverflow: TextOverflow.clip,
                                textToDisplay:
                                    notifier.interest[index].interestName ?? '',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: notifier.pickedInterest(
                                              notifier.interest[index].id)
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : null,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : const CustomShimmer(
                    radius: 8,
                    width: double.infinity,
                    height: double.infinity,
                  ),
          ),
        ),
      ),
    );
  }
}
