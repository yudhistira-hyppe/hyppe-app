import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class PageNoInternetConnection extends StatelessWidget {
  const PageNoInternetConnection({Key? key}) : super(key: key);

  static final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Consumer<TranslateNotifierV2>(
        builder: (_, notifier, __) => Container(
          padding: EdgeInsets.all(55 * SizeConfig.scaleDiagonal),
          color: Theme.of(context).colorScheme.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset(
                "${AssetPath.pngPath}no_internet_connection.png",
                width: 250 * SizeConfig.scaleDiagonal,
                height: 160 * SizeConfig.scaleDiagonal,
              ),
              SizedBox(height: 35 * SizeConfig.scaleDiagonal),
              CustomTextWidget(
                textToDisplay: notifier.translate.noInternetConnection ??
                    'No Internet Connection',
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                    fontSize: 18 * SizeConfig.scaleDiagonal,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 14 * SizeConfig.scaleDiagonal),
              CustomTextWidget(
                textToDisplay:
                    notifier.translate.pleaseCheckYourInternetConnectionAgain ??
                        '',
                textAlign: TextAlign.center,
                textStyle: Theme.of(context).textTheme.bodyMedium,
                textOverflow: TextOverflow.clip,
              ),
              SizedBox(height: 37 * SizeConfig.scaleDiagonal),
              ValueListenableBuilder<bool>(
                valueListenable: _isLoading,
                builder: (_, value, __) {
                  if (value) const CustomLoading();

                  return CustomElevatedButton(
                    child: CustomTextWidget(
                      textToDisplay: notifier.translate.tryAgain ?? 'Try Again',
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    width: 164 * SizeConfig.scaleDiagonal,
                    height: 42 * SizeConfig.scaleDiagonal,
                    function: () {},
                    buttonStyle: ButtonStyle(
                        elevation: MaterialStateProperty.all<double>(0.0),
                        visualDensity: VisualDensity.adaptivePlatformDensity,
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).colorScheme.primary),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)))),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
