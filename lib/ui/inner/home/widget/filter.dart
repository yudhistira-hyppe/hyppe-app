import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:provider/provider.dart';

class FilterLanding extends StatelessWidget {
  const FilterLanding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeNotifier>(
      builder: (context, notifier, child) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 50.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: false,
            children: [
              ...List.generate(
                notifier.visibiltyList.length,
                (index) => GestureDetector(
                  onTap: () => notifier.changeVisibility(context, index),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Chip(
                        // selected: notifier.pickedVisibility(notifier.visibiltyList[index]['code']),
                        backgroundColor: notifier.pickedVisibility(notifier.visibiltyList[index]['code']) ? Theme.of(context).colorScheme.onSecondary : Theme.of(context).backgroundColor,
                        shape: StadiumBorder(
                            side: BorderSide(
                                color: notifier.pickedVisibility(notifier.visibiltyList[index]['code'])
                                    ? Theme.of(context).colorScheme.onSecondaryContainer
                                    : Theme.of(context).colorScheme.secondaryContainer)),
                        label: CustomTextWidget(
                          textToDisplay: notifier.visibiltyList[index]['name'],
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: notifier.pickedVisibility(notifier.visibiltyList[index]['code']) ? kHyppePrimary : kHyppeSecondary, fontWeight: FontWeight.bold),
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
