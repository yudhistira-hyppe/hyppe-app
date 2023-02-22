import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:provider/provider.dart';

class SearchContentsTab extends StatefulWidget {
  const SearchContentsTab({Key? key}) : super(key: key);

  @override
  State<SearchContentsTab> createState() => _SearchContentsTabState();
}

class _SearchContentsTabState extends State<SearchContentsTab> {
  @override
  Widget build(BuildContext context) {
    final listTab = [
      HyppeType.HyppeVid,
      HyppeType.HyppeDiary,
      HyppeType.HyppePic
    ];
    return Consumer<SearchNotifier>(builder: (context, notifier, _) {
      final language = notifier.language;
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                child: CustomTextWidget(
                  textToDisplay: language.contents ?? 'Contents',
                  textStyle: context.getTextTheme().bodyText1,
                  textAlign: TextAlign.start,
                ),
              ),
              ListView.builder(
                  itemCount: listTab.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final isActive = listTab[index] == notifier.contentTab;
                    return Container(
                      margin: const EdgeInsets.only(right: 12, top: 10, bottom: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: Ink(
                          height: 36,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isActive
                                ? context.getColorScheme().primary
                                : context.getColorScheme().background,
                          ),
                          child: InkWell(
                            onTap: (){
                              notifier.contentTab = listTab[index];
                            },
                            splashColor: context.getColorScheme().primary,
                            child: Container(
                              alignment: Alignment.center,
                              height: 36,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(18)),
                                  border: !isActive
                                      ? Border.all(
                                          color: context.getColorScheme().secondary,
                                          width: 1)
                                      : null),
                              child: CustomTextWidget(
                                textToDisplay:
                                    System().getTitleHyppe(notifier.contentTab),
                                textStyle: context.getTextTheme().bodyText2?.copyWith(
                                    color: isActive
                                        ? context.getColorScheme().background
                                        : context.getColorScheme().secondary),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
              Container(
                width: context.getWidth(),
                height: 1000,
                alignment: Alignment.center,
                child: Text('search content'),
              )
            ],
          ),
        ),
      );
    });
  }
}
