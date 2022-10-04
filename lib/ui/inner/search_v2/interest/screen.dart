import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/search_v2/interest/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/themes/hyppe_colors.dart';

class InterestScreen extends StatefulWidget {
  const InterestScreen({Key? key}) : super(key: key);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              child: Text(
                notifier.language.findYourInterests!,
                style: const TextStyle(
                    color: kHyppeLightSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              itemBuilder: (context, index) {
                return Container();
              },
            ),
          ],
        ),
      );
    });
  }
}
