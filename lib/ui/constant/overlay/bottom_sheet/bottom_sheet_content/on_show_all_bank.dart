import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/bank_data.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment_method/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:provider/provider.dart';

class onShowAllBankBottomSheet extends StatelessWidget {
  const onShowAllBankBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentMethodNotifier>(
      builder: (context, notifier, __) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * SizeConfig.scaleDiagonal),
            child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg", defaultColor: false),
          ),
          notifier.data == null
              ? const CustomLoading()
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifier.data?.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 0.3, color: kHyppeLightInactive2)), color: Colors.transparent),
                      child: ListTile(
                        onTap: () {
                          context.read<TransactionNotifier>().bankInsert(notifier.data?[index] ?? BankData());
                        },
                        title: CustomTextWidget(
                          textToDisplay: notifier.data?[index].bankname ?? '',
                          textAlign: TextAlign.start,
                          textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.onBackground),
                        ),
                        leading: CustomCacheImage(
                          // imageUrl: picData.content[arguments].contentUrl,
                          imageUrl: notifier.data?[index].bankIcon,
                          imageBuilder: (_, imageProvider) {
                            return Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
                              ),
                            );
                          },
                          errorWidget: (_, __, ___) {
                            return Container(
                              width: 35,
                              height: 35,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
        ],
      ),
    );
  }
}
