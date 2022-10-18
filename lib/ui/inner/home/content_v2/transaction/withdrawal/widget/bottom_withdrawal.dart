import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:provider/provider.dart';

class BottomWithdrawalWidget extends StatelessWidget {
  LocalizationModelV2 translate;
  BottomWithdrawalWidget({Key? key, required this.translate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionNotifier>(
      builder: (_, notifier, __) => Container(
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const CustomTextWidget(textToDisplay: 'Destination Bank Account'),
              ListView.builder(
                shrinkWrap: true,
                itemCount: notifier.dataAcccount!.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kHyppeLightInactive2, width: 0.5))),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () => notifier.bankChecked(notifier.dataAcccount![index].noRek!),
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            children: [
                              CustomTextWidget(
                                textToDisplay: notifier.dataAcccount![index].bankName!,
                                textAlign: TextAlign.start,
                              ),
                              sixPx,
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Color(0xAAF8EDF9),
                                ),
                                child: const CustomIconWidget(
                                  iconData: "${AssetPath.vectorPath}user-verified.svg",
                                  defaultColor: false,
                                ),
                              )
                            ],
                          ),
                          subtitle: CustomTextWidget(
                            textToDisplay: '${notifier.dataAcccount![index].noRek} - ${notifier.dataAcccount![index].nama}',
                            textAlign: TextAlign.start,
                          ),
                          trailing: Radio<String>(
                            value: notifier.dataAcccount![index].noRek!,
                            groupValue: notifier.bankSelected,
                            onChanged: (val) => notifier.bankSelected = val!,
                            activeColor: kHyppePrimary,
                          ),
                        ),
                        notifier.isCheking && notifier.bankSelected == notifier.dataAcccount![index].noRek!
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: const [
                                    SizedBox(
                                      width: 10,
                                      height: 10,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1,
                                        color: kHyppePrimary,
                                      ),
                                    ),
                                    sixPx,
                                    CustomTextWidget(textToDisplay: 'Checking the account'),
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  );
                },
              )
            ],
          )),
    );
  }
}
