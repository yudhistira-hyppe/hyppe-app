import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/list_boost/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/list_boost/widget/card_boost.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ListBoostScreen extends StatefulWidget {
  const ListBoostScreen({Key? key}) : super(key: key);

  @override
  State<ListBoostScreen> createState() => _ListBoostScreenState();
}

class _ListBoostScreenState extends State<ListBoostScreen> {
  @override
  void initState() {
    Provider.of<ListBoostNotifier>(context, listen: false).getInitBoost(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ListBoostNotifier, TranslateNotifierV2>(
      builder: (context, notifier, translate, child) => Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Routing().moveBack(),
                      icon: const CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg"),
                    ),
                    CustomTextWidget(
                      textToDisplay: translate.translate.boostedPostList ?? '',
                      textAlign: TextAlign.start,
                      textStyle: Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: notifier.boostData?.length,
                itemBuilder: (context, index) {
                  return CardBoost(
                    data: notifier.boostData?[index],
                    language: translate.translate,
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
