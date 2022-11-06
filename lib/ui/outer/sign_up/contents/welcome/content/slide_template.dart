import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:dynamic_widget/dynamic_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/sign_up/contents/welcome/notifier.dart';
import 'package:provider/provider.dart';

class SlideTemplate extends StatelessWidget {
  final int notesData;
  const SlideTemplate({Key? key, required this.notesData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<SignUpWelcomeNotifier>();
    final error = context.select((ErrorService value) => value.getError(ErrorType.getWelcomeNotes));

    if (context.read<ErrorService>().isInitialError(error, notifier.result)) {
      return Scaffold(
        body: Center(
          child: SizedBox(
            height: 198,
            child: CustomErrorWidget(
              errorType: ErrorType.getWelcomeNotes,
              function: () => notifier.initWelcome(context),
            ),
          ),
        ),
      );
    }

    if (notifier.result != null) {
      return Scaffold(
        body: Container(
          height: SizeConfig.screenHeight! - ((SizeConfig.screenHeight ?? context.getHeight()) * 0.25),
          width: SizeConfig.screenWidth,
          padding: EdgeInsets.only(top: SizeConfig.paddingTop),
          child: DynamicWidgetBuilder.build(notifier.result?.notesData[notesData].note ?? '', context, DefaultClickListener())!,
        ),
      );
    }

    return const Center(
      child: CustomLoading(),
    );
  }
}
