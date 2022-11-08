import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/referral_list_user.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/referral/model_referral.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ListReferralUser extends StatelessWidget {
  ReferralListUserArgument arguments;
  ListReferralUser({Key? key, required this.arguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReferralNotifier>(
      builder: (_, notifier, __) => Scaffold(
          appBar: AppBar(
            leadingWidth: 50 * (SizeConfig.screenWidth ?? context.getWidth()) / SizeWidget.baseWidthXD,
            leading: CustomIconButtonWidget(
              defaultColor: true,
              iconData: "${AssetPath.vectorPath}back-arrow.svg",
              onPressed: () => Routing().moveBack(),
            ),
            titleSpacing: 0,
            title: CustomTextWidget(
              textToDisplay: '${notifier.language.linkYourReferral}',
              textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
            ),
            centerTitle: false,
          ),
          body: Container(
            padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Telah Digunakan Oleh ',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    Text('(${arguments.modelReferral?.data} kali)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: arguments.modelReferral?.list?.length,
                    itemBuilder: (c, index) {
                      final listUser = arguments.modelReferral?.list?[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 10),
                            height: 40,
                            child: Text(
                              '${listUser?.children}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                            ),
                          ),
                          Divider(
                            color: Color(0xffF5F5F5),
                            thickness: 1,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
