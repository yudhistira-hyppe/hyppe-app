import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:provider/provider.dart';

class WithdrawalScreen extends StatelessWidget {
  const WithdrawalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier2, __) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: CustomTextWidget(
            textStyle: Theme.of(context).textTheme.subtitle1,
            textToDisplay: '${notifier2.translate.withdrawal}',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(11.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 2,
                      spreadRadius: 1,
                      color: Colors.black.withOpacity(0.06),
                    ),
                  ],
                  color: Theme.of(context).colorScheme.background,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomTextWidget(
                          textToDisplay: 'Hyppe Ballance',
                          textStyle: Theme.of(context).textTheme.subtitle2,
                        ),
                        fivePx,
                        const CustomIconWidget(
                          iconData: "${AssetPath.vectorPath}info-icon.svg",
                          height: 14,
                        )
                      ],
                    ),
                    CustomTextWidget(
                      textToDisplay: 'Rp 5.000.000',
                      textStyle: Theme.of(context).primaryTextTheme.headline5!.copyWith(fontWeight: FontWeight.w700),
                    ),
                    thirtyTwoPx,
                    CustomTextWidget(
                      textToDisplay: 'Amount',
                      textStyle: Theme.of(context).textTheme.subtitle2,
                    ),
                    twentyPx,
                    Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 35, right: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            border: Border.all(color: kHyppeLightInactive1),
                          ),
                          child: TextFormField(
                            maxLines: 1,
                            validator: (String? input) {
                              // if (input?.isEmpty ?? true) {
                              //   return notifier.language.pleaseSetPrice;
                              // } else {
                              //   return null;
                              // }
                            },
                            // enabled: notifier.isSavedPrice ? false : true,
                            // controller: notifier.priceController,
                            // onChanged: (val) {
                            //   if (val.isNotEmpty) {
                            //     notifier.priceIsFilled = true;
                            //   } else {
                            //     notifier.priceIsFilled = false;
                            //   }
                            // },
                            keyboardAppearance: Brightness.dark,
                            cursorColor: const Color(0xff8A3181),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, ThousandsFormatter()], // Only numbers can be entered
                            style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              fillColor: kHyppePrimary,
                              errorBorder: InputBorder.none,
                              hintStyle: Theme.of(context).textTheme.bodyText2,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.only(bottom: 2),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            color: kHyppeLightSurface,
                            padding: const EdgeInsets.only(top: 15, left: 10),
                            child: Text(
                              notifier2.translate.rp!,
                              style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
