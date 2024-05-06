import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class DialogInfoWidget extends StatelessWidget {
  final LocalizationModelV2? lang;
  const DialogInfoWidget({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: .9,
      initialChildSize: .4,
      builder: (_, controller) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Column(
            children: [
              FractionallySizedBox(
                widthFactor: 0.15,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 12.0,
                  ),
                  child: Container(
                    height: 5.0,
                    decoration: const BoxDecoration(
                      color: kHyppeBurem,
                      borderRadius: BorderRadius.all(Radius.circular(2.5)),
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  lang?.detailcoupondisc??'Detail Kupon Diskon',
                  style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              tenPx,
              const Divider(color: kHyppeBurem, thickness: .5,),
              tenPx,
              listText(context, number: 1, label: 'eget nulla facilisi etiam dignissim diam quis enim lobortis scelerisque'),
              listText(context, number: 2, label: 'fermentum dui faucibus in ornare quam viverra orci sagittis eu volutpat odio facilisis mauris sit amet massa'),
              listText(context, number: 3, label: 'vitae tortor condimentum'),
              listText(context, number: 4, label: 'lacinia quis vel eros donec ac odio tempor orci dapibus ultrices in iaculis nunc sed augue lacus, viverra'),
              listText(context, number: 5, label: 'vitae congue eu, consequat ac felis donec et odio pellentesque diam volutpat commodo'),
              listText(context, number: 6, label: 'sed egestas egestas fringilla phasellus faucibus'),
            ],
          ),
        );
      },
    );
  }

  Widget listText(BuildContext context,{int number = 1, String label = ''}) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextWidget(textToDisplay: '$number. '),
            SizedBox(
              width: MediaQuery.of(context).size.width * .9,
              child: Text(' $label')),
          ],
        ),
      ),
    );
  }
}