import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/notification/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/process_upload_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    final notifier = Provider.of<NotificationNotifier>(context, listen: false);
    notifier.onInitial();
    notifier.getNotifications(context, reload: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final error = context.select((ErrorService value) => value.getError(ErrorType.notification));

    return Consumer<NotificationNotifier>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          actions: [
            Container(
              padding: EdgeInsets.only(left: 15 * SizeConfig.scaleDiagonal),
              width: SizeConfig.screenWidth,
              child: CustomTextWidget(
                textToDisplay: notifier.language.notification!,
                textStyle: Theme.of(context).textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
              ),
              alignment: Alignment.centerLeft,
            ),
          ],
          automaticallyImplyLeading: false,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const ProcessUploadComponent(),
            SizedBox(
              height: 50.05,
              child: ListView.builder(
                itemCount: notifier.listScreen.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    notifier.screen = notifier.listScreen.keys.elementAt(index);
                    notifier.pageIndex = notifier.listScreen.keys.toList().indexOf(notifier.screen!);
                    notifier.getNotifications(context, reload: true, eventType: notifier.eventType(index));
                  },
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 14 * SizeConfig.scaleDiagonal,
                        left: (index == 0 ? 23 : 15) * SizeConfig.scaleDiagonal,
                        right: (index == 0 ? 23 : 15) * SizeConfig.scaleDiagonal,
                      ),
                      child: CustomTextWidget(
                        textToDisplay: notifier.listScreen.values.elementAt(index),
                        textStyle: Theme.of(context).textTheme.subtitle2!.apply(
                              color: index == notifier.pageIndex ? null : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
                            ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          width: 2,
                          color: notifier.listScreen.keys.elementAt(index) == notifier.screen
                              ? Theme.of(context).colorScheme.primaryVariant
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (notifier.loadingForObject(NotificationNotifier.refreshKey))
              LinearProgressIndicator(color: Theme.of(context).colorScheme.primaryVariant, backgroundColor: Colors.grey),
            context.read<ErrorService>().isInitialError(error, notifier.data)
                ? CustomErrorWidget(
                    errorType: ErrorType.notification,
                    function: () => notifier.getNotifications(context, reload: true),
                  )
                : Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        animation = CurvedAnimation(parent: animation, curve: Curves.easeOut, reverseCurve: Curves.easeIn);

                        return SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0)).animate(animation), child: child);
                      },
                      child: notifier.screen!,
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
