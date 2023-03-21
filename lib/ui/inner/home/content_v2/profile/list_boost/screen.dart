import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/list_boost/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/list_boost/widget/card_boost.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/all_transaction/widget/shimmer_all_transaction_history.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ListBoostScreen extends StatefulWidget {
  const ListBoostScreen({Key? key}) : super(key: key);

  @override
  State<ListBoostScreen> createState() => _ListBoostScreenState();
}

class _ListBoostScreenState extends State<ListBoostScreen> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ListBoostScreen');
    final _notifier = Provider.of<ListBoostNotifier>(context, listen: false);
    _notifier.getInitBoost(context);
    _scrollController.addListener(() => _notifier.scrollList(context, _scrollController));
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
        body: RefreshIndicator(
          strokeWidth: 2.0,
          color: Colors.purple,
          onRefresh: () async {
            await notifier.getInitBoost(context, reload: true);
          },
          child: notifier.isLoading
              ? const ShimmerAllTransactionHistory()
              : notifier.boostData.isEmpty
                  ? SizedBox(height: SizeConfig.screenHeight, child: const NoResultFound())
                  : ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: false,
                      itemCount: notifier.boostData.length,
                      itemBuilder: (context, index) {
                        return CardBoost(
                          data: notifier.boostData[index],
                          language: translate.translate,
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
