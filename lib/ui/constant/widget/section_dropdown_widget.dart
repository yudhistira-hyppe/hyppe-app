import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';

class SectionDropdownWidget extends StatelessWidget {
  final String title;
  final bool isActive;
  final Function() onTap;
  const SectionDropdownWidget({super.key, required this.title, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        decoration: BoxDecoration(
          border: Border.all(color: (isActive)? kHyppePrimary : kHyppeBurem, width: .5),
          borderRadius: BorderRadius.circular(32.0)
        ),
        child: Row(
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(
                    color: (isActive)? kHyppePrimary : kHyppeBurem
                  ),
              textAlign: TextAlign.start,
            ),
            fivePx,
            Icon(Icons.keyboard_arrow_down, color: (isActive) ? kHyppePrimary : kHyppeBurem,)
          ],
        ),
      ),
    );
  }
}
