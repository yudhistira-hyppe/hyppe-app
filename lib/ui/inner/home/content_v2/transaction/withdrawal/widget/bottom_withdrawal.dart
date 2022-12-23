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
          // padding: const EdgeInsets.all(11.0),
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
              const Padding(
                padding: EdgeInsets.all(11.0),
                child: CustomTextWidget(textToDisplay: 'Destination Bank Account'),
              ),
              notifier.isLoading
                  ? SizedBox(
                      height: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Center(child: CustomLoading()),
                        ],
                      ),
                    )
                  : (notifier.dataAcccount?.isEmpty ?? true)
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${translate.noBankAccount2}',
                                  style: const TextStyle(color: kHyppeRed),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: notifier.dataAcccount?.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.only(right: 11.0, left: 11.0),
                              decoration: BoxDecoration(
                                  border: const Border(
                                    bottom: BorderSide(color: kHyppeLightInactive2, width: 0.5),
                                  ),
                                  color: notifier.dataAcccount?[index].statusInquiry != null && !(notifier.dataAcccount?[index].statusInquiry ?? false)
                                      ? Colors.grey.withOpacity(0.08)
                                      : Theme.of(context).colorScheme.background),
                              child: Column(
                                children: [
                                  ListTile(
                                    onTap: notifier.dataAcccount?[index].statusInquiry == null || (notifier.dataAcccount?[index].statusInquiry ?? false) ? () => notifier.bankChecked(index) : null,
                                    contentPadding: EdgeInsets.zero,
                                    title: Row(
                                      children: [
                                        CustomTextWidget(
                                          textToDisplay: notifier.dataAcccount?[index].bankName ?? '',
                                          textAlign: TextAlign.start,
                                        ),
                                        sixPx,
                                        notifier.dataAcccount?[index].statusInquiry != null && (notifier.dataAcccount?[index].statusInquiry ?? false)
                                            ? Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(50),
                                                  color: const Color(0xAAF8EDF9),
                                                ),
                                                child: const CustomIconWidget(
                                                  iconData: "${AssetPath.vectorPath}user-verified.svg",
                                                  defaultColor: false,
                                                ),
                                              )
                                            : Container()
                                      ],
                                    ),
                                    subtitle: CustomTextWidget(
                                      textToDisplay: '${notifier.dataAcccount?[index].noRek} - ${(notifier.dataAcccount?[index].nama)?.toUpperCase()}',
                                      textAlign: TextAlign.start,
                                    ),
                                    trailing: Radio<String>(
                                      value: notifier.dataAcccount?[index].id ?? '',
                                      groupValue: notifier.bankSelected,
                                      onChanged:
                                          notifier.dataAcccount?[index].statusInquiry == null || (notifier.dataAcccount?[index].statusInquiry ?? false) ? (val) => notifier.bankChecked(index) : null,
                                      activeColor: kHyppePrimary,
                                    ),
                                  ),
                                  // notifier.isCheking && notifier.bankSelected == notifier.dataAcccount[index].noRek
                                  //     ? Padding(
                                  //         padding: const EdgeInsets.all(8.0),
                                  //         child: Row(
                                  //           children: const [
                                  //             SizedBox(
                                  //               width: 10,
                                  //               height: 10,
                                  //               child: CircularProgressIndicator(
                                  //                 strokeWidth: 1,
                                  //                 color: kHyppePrimary,
                                  //               ),
                                  //             ),
                                  //             sixPx,
                                  //             CustomTextWidget(textToDisplay: 'Checking the account'),
                                  //           ],
                                  //         ),
                                  //       )
                                  //     : Container(),
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
