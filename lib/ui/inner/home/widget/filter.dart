import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:provider/provider.dart';

class FilterLanding extends StatefulWidget {
  const FilterLanding({Key? key}) : super(key: key);

  @override
  State<FilterLanding> createState() => _FilterLandingState();
}

class _FilterLandingState extends State<FilterLanding> {
  @override
  void initState() {
    super.initState();
    // final homeNotifier = Provider.of<HomeNotifier>(context, listen: false);
  }

  // bool pickedFilter(String? tile) => filterList.contains(tile) ? true : false;

  @override
  Widget build(BuildContext context) {
    return Consumer3<LikeNotifier, TranslateNotifierV2, HomeNotifier>(builder: (context, notifier, transNotifier, homeNotifier, child) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 0, 12),
        child: SizedBox(
          height: 50.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: false,
            children: [
              ...List.generate(
                homeNotifier.filterList.length,
                (index) => GestureDetector(
                  onTap: () {
                    homeNotifier.isLoadingVid = true;
                    homeNotifier.isLoadingDiary = true;
                    homeNotifier.isLoadingPict = true;
                    // selected(homeNotifier.filterList[index]['code']);
                    homeNotifier.select = homeNotifier.filterList[index]['code'];
                    notifier.changeVisibility(context, homeNotifier.filterList[index]['code']);
                  },
                  child: Chip(
                    // selected: notifier.pickedVisibility(homeNotifier.filterList[index]['code']),
                    backgroundColor: homeNotifier.select == homeNotifier.filterList[index]['code'] ? Theme.of(context).colorScheme.onSecondary : Theme.of(context).backgroundColor,
                    shape: StadiumBorder(
                        side: BorderSide(
                            color:
                                homeNotifier.select == homeNotifier.filterList[index]['code'] ? Theme.of(context).colorScheme.onSecondaryContainer : Theme.of(context).colorScheme.secondaryContainer)),
                    label: CustomTextWidget(
                      textToDisplay: homeNotifier.filterList[index]['name'],
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: homeNotifier.select == homeNotifier.filterList[index]['code'] ? kHyppePrimary : kHyppeSecondary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              // ...List.generate(
              //   notifier.visibiltyList.length,
              //   (index) => GestureDetector(
              //     onTap: () {
              //       selected(notifier.visibiltyList[index]['code']);
              //       notifier.changeVisibility(context, index);
              //     },
              //     child: Chip(
              //         // selected: notifier.pickedVisibility(notifier.visibiltyList[index]['code']),
              //         backgroundColor: notifier.visibilitySelect == notifier.visibiltyList[index]['code'] ? Theme.of(context).colorScheme.onSecondary : Theme.of(context).backgroundColor,
              //         shape: StadiumBorder(
              //             side: BorderSide(
              //                 color: notifier.visibilitySelect == notifier.visibiltyList[index]['code']
              //                     ? Theme.of(context).colorScheme.onSecondaryContainer
              //                     : Theme.of(context).colorScheme.secondaryContainer)),
              //         label: CustomTextWidget(
              //           textToDisplay: notifier.visibiltyList[index]['name'],
              //           textStyle: Theme.of(context)
              //               .textTheme
              //               .bodyMedium!
              //               .copyWith(color: notifier.visibilitySelect == notifier.visibiltyList[index]['code'] ? kHyppePrimary : kHyppeSecondary, fontWeight: FontWeight.bold),
              //         )),
              //   ),
              // ),
            ],
          ),
        ),
      );
    });
  }
}
