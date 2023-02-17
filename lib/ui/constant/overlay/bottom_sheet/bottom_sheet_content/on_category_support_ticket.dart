import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/support_ticket/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class OnCategorySupportTicket extends StatelessWidget {
  const OnCategorySupportTicket({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final textTheme = Theme.of(context).textTheme;
    return Consumer2<SupportTicketNotifier, TranslateNotifierV2>(
      builder: (context, notifier, notifier2, child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
              sixPx,
              CustomTextWidget(
                textToDisplay: notifier2.translate.categories ?? '',
                textStyle: textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onBackground),
                textAlign: TextAlign.start,
              ),
              tenPx,
              Expanded(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: notifier.categoryData.length,
                  itemBuilder: (context, index) {
                    return RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      groupValue: notifier.nameCategory,
                      value: notifier.categoryData[index].nameCategory ?? '',
                      onChanged: (val) {
                        notifier.nameCategory = val ?? '';
                        notifier.idCategory = notifier.categoryData[index].sId ?? '';
                        Routing().moveBack();
                      },
                      toggleable: true,
                      title: CustomTextWidget(
                        textAlign: TextAlign.left,
                        textToDisplay: notifier.categoryData[index].nameCategory ?? '',
                        textStyle: Theme.of(context).primaryTextTheme.bodyText2,
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      activeColor: Theme.of(context).colorScheme.primary,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
