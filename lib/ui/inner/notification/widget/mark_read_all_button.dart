// import 'package:hyppe/core/models/collection/notifications/notifications.dart';
// import 'package:hyppe/initial/hyppe/translate.dart';
// import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
// import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
// import 'package:hyppe/ui/inner/notification/notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class MarkReadAllButton extends StatelessWidget {
//   final Notifications? data;

//   const MarkReadAllButton({Key? key, required this.data}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (data?.data == null) return SizedBox.shrink();

//     return CustomTextButton(
//         onPressed: () => context.read<NotificationNotifier>().markAllAsRead(context),
//         style: Theme.of(context).textButtonTheme.style.copyWith(
//             backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.surface),
//             shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
//         child: CustomTextWidget(
//             textToDisplay: context.read<TranslateNotifier>().translate.markAllAsRead!, textStyle: Theme.of(context).textTheme.button));
//   }
// }
