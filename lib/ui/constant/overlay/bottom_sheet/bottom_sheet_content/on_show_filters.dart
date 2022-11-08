import 'dart:io';
import 'package:hyppe/core/constants/filter_matrix.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class OnShowFilters extends StatelessWidget {
  final String file;
  final GlobalKey? globalKey;
  const OnShowFilters({Key? key, required this.file, this.globalKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      height: 167,
      width: SizeConfig.screenWidth,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: FILTERS.length,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => context.read<PreviewContentNotifier>().setFilterMatrix(FILTERS.values.toList()[index]),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTextWidget(
                            textToDisplay: FILTERS.keys.toList()[index],
                            textStyle: Theme.of(context).textTheme.caption?.copyWith(fontWeight: FontWeight.w600)),
                        eightPx,
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.matrix(FILTERS.values.toList()[index]),
                            child: Image.file(
                              File(file),
                              width: 62,
                              height: 80,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                if (wasSynchronouslyLoaded) {
                                  return child;
                                }
                                return AnimatedOpacity(
                                  child: child,
                                  opacity: frame == null ? 0 : 1,
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeOut,
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          CustomElevatedButton(
            width: 81,
            height: 30,
            function: () => context.read<PreviewContentNotifier>().applyFilters(globalKey: globalKey),
            buttonStyle: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)))),
            child: Consumer<PreviewContentNotifier>(
              builder: (_, notifier, __) => CustomTextWidget(
                textToDisplay: notifier.language.done ?? 'done',
                textStyle: Theme.of(context).textTheme.button,
              ),
            ),
          )
        ],
      ),
    );
  }
}
