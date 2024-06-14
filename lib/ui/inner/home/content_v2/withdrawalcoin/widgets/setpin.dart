import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';

class SetPinDialog extends StatelessWidget {
  final LocalizationModelV2? lang;
  const SetPinDialog({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        maxChildSize: .9,
        initialChildSize: .3,
        builder: (_, controller) {
          return Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Column(
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.1,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 12.0,
                      ),
                      child: Container(
                        height: 5.0,
                        decoration: BoxDecoration(
                          color: kHyppeBurem.withOpacity(.5),
                          borderRadius: const BorderRadius.all(Radius.circular(2.5)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                    child: Text(
                      lang?.localeDatetime == 'id' ? 'Atur PIN untuk keamanan akunmu' : 'Set a PIN for your account security',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  fifteenPx,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: CustomTextWidget(
                      textToDisplay: lang?.localeDatetime == 'id' ? 'Tentukan PIN akunmu terlebih dahulu untuk dapat melakukan penarikan.' : 'Set your account PIN first to be able to withdraw.',
                      maxLines: 3,
                    ),
                  ),
                  fifteenPx,
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: ElevatedButton(
                      onPressed: () => Routing().move(Routes.pinScreen),
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: kHyppePrimary),
                      child: SizedBox(
                        width: double.infinity,
                        height: kToolbarHeight,
                        child: Center(
                          child: Text(lang?.localeDatetime == 'id' ? 'Buat PIN' : 'Create PIN', textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ),
                ],
              ));
        });
  }

  Widget listTile(String? label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label??'',
            style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal),
          ),
          Text(value??'',
            style: const TextStyle(
                color: kHyppeBurem,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
