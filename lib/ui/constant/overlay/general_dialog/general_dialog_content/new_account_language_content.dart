import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/sign_up/widget/sign_up_load_more_list.dart';
import 'package:provider/provider.dart';

class NewAccountLanguageContent extends StatefulWidget {
  @override
  State<NewAccountLanguageContent> createState() =>
      _NewAccountLanguageContentState();
}

class _NewAccountLanguageContentState extends State<NewAccountLanguageContent> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    final notifier = context.read<TranslateNotifierV2>();
    notifier.getListOfLanguage(context);
    _scroll.addListener(() {
      if (_scroll.offset >= _scroll.position.maxScrollExtent &&
          !_scroll.position.outOfRange) {
        notifier.loadMore = !notifier.loadMore;
        notifier.getListOfLanguage(context);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TranslateNotifierV2>();
    final error = context
        .select((ErrorService value) => value.getError(ErrorType.getLanguage));

    if (context.read<ErrorService>().isInitialError(
        error, notifier.listLanguage.isEmpty ? null : notifier.listLanguage)) {
      return Center(
        child: SizedBox(
          height: SizeConfig.screenHeight! * 0.8,
          child: CustomErrorWidget(
            function: () => notifier.getListOfLanguage(context),
            errorType: ErrorType.getStates,
          ),
        ),
      );
    }

    return SizedBox(
      height: SizeConfig.screenHeight! * 0.8,
      width: SizeConfig.screenWidth,
      child: Center(
        child: notifier.listLanguage.isNotEmpty
            ? Column(
                children: [
                  const RotatedBox(
                    quarterTurns: 1,
                    child: CustomIconWidget(
                        iconData: '${AssetPath.vectorPath}back-arrow.svg'),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scroll,
                      itemCount: notifier.listLanguage.length,
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(0),
                      itemBuilder: (context, index) => Container(
                        padding: const EdgeInsets.all(11),
                        child: CustomElevatedButton(
                          height: 42,
                          width: SizeConfig.screenWidth,
                          function: () {
                            notifier.initTranslate(context, index: index);
                          },
                          buttonStyle: const ButtonStyle(),
                          child: CustomTextWidget(
                            textToDisplay:
                                notifier.listLanguage[index].lang ?? '',
                            textStyle: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                  ),
                  notifier.loadMore
                      ? SignUpLoadMoreList(
                          caption:
                              "${notifier.translate.loadMore} ${notifier.translate.language}")
                      : const SizedBox.shrink(),
                  const RotatedBox(
                    quarterTurns: 3,
                    child: CustomIconWidget(
                        iconData: '${AssetPath.vectorPath}back-arrow.svg'),
                  ),
                ],
              )
            : const CustomLoading(),
      ),
    );
  }
}
