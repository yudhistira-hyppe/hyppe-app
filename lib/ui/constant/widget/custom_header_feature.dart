import 'package:hyppe/initial/hyppe/translate_v2.dart';
// import 'package:hyppe/ui/inner/home/content/diary/preview/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

class CustomHeaderFeature extends StatefulWidget {
  final String title;
  final Function() onPressed;

  const CustomHeaderFeature({Key? key, required this.title, required this.onPressed}) : super(key: key);

  @override
  _CustomHeaderFeatureState createState() => _CustomHeaderFeatureState();
}

class _CustomHeaderFeatureState extends State<CustomHeaderFeature> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    // final notifier = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   // final _box = _key.currentContext.findRenderObject() as RenderBox;
    //   // notifier.heightTitleFeature = _box.size.height;
    // });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _themes = Theme.of(context);
    return Container(
        width: SizeConfig.screenWidth,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            flex: 9,
            child: CustomTextWidget(
              key: _key,
              maxLines: 1,
              textAlign: TextAlign.left,
              textToDisplay: "${widget.title}!",
              textStyle: _themes.textTheme.button!.apply(
                color: _themes.bottomNavigationBarTheme.unselectedItemColor,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Visibility(
              visible: true,
              child: GestureDetector(
                onTap: widget.onPressed,
                child: CustomTextWidget(
                  maxLines: 1,
                  textToDisplay: context.watch<TranslateNotifierV2>().translate.seeAll!,
                  textAlign: TextAlign.right,
                  textStyle: _themes.textTheme.subtitle2?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _themes.colorScheme.primaryVariant,
                  ),
                ),
              ),
            ),
          )
        ]));
  }
}
