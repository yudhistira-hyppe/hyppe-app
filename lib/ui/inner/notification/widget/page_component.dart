import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';

import 'package:hyppe/ui/inner/notification/notifier.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

// import 'package:hyppe/core/extension/custom_extension.dart';

import 'package:hyppe/core/models/collection/notification_v2/notification.dart';

import '../../../../core/services/fcm_service.dart';

class PageComponent extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder builder;
  final List<NotificationModel>? data;

  const PageComponent({
    Key? key,
    this.data,
    required this.builder,
    required this.itemCount,
  }) : super(key: key);

  @override
  _PageComponentState createState() => _PageComponentState();
}

class _PageComponentState extends State<PageComponent> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _key = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'PageComponent');
    final _notifier = Provider.of<NotificationNotifier>(context, listen: false);
    _scrollController.addListener(() => _notifier.scrollListener(context, _scrollController));
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return RefreshIndicator(
      key: _key,
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () async {
        imageCache.clear();
        imageCache.clearLiveImages();
        FcmService().setHaveNotification(false);
        await context.read<NotificationNotifier>().getNotifications(context, reload: true);
      },
      child: _buildWidget(),
    );
  }

  Widget _buildWidget() {
    final mediaQuery = MediaQuery.of(context);

    if (context.read<NotificationNotifier>().data != null && (widget.data?.isEmpty ?? true)) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Container(
          color: Colors.transparent,
          height: mediaQuery.size.height / 1.3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CustomIconWidget(
                defaultColor: false,
                iconData: "${AssetPath.vectorPath}empty-notification.svg",
              ),
              eightPx,
              CustomTextWidget(
                textStyle: Theme.of(context).textTheme.subtitle1,
                textToDisplay: "${context.read<NotificationNotifier>().language.emptyNotification}",
              ),
              eightPx,
              CustomTextWidget(
                textToDisplay: "${context.read<NotificationNotifier>().language.whenThereIsNewNotificationItWillGoesHere}",
                textStyle: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondary),
              )
            ],
          ),
        ),
      );
    } else {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: widget.itemCount,
        itemBuilder: widget.builder,
        controller: _scrollController,
      );
    }
  }
}
