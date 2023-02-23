import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/utils/interest/interest_data.dart';
import 'package:hyppe/ui/inner/search_v2/interest/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/asset_path.dart';
import '../../../../core/constants/themes/hyppe_colors.dart';
import '../../../constant/widget/custom_icon_widget.dart';
import '../../../constant/widget/custom_text_widget.dart';

class InterestScreen extends StatefulWidget {
  List<InterestData> data;
  InterestScreen({Key? key, required this.data}) : super(key: key);

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
                    childAspectRatio: 3.0,
                    children: widget.data.map((e) => Stack(
                      children: [
                        Positioned.fill(child: Container(
                          width: double.infinity,
                          alignment: Alignment.topRight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: AssetImage(e.icon ?? '${AssetPath.pngPath}content-error.png'),
                            ),
                          ),
                        )),
                        Positioned.fill(child: Align(
                          alignment: Alignment.center,
                          child: CustomTextWidget(
                            textToDisplay: e.interestName ?? '',
                            textStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Colors.white),),
                        ))
                      ],
                    ),
                    ).toList(),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    });
  }
}
