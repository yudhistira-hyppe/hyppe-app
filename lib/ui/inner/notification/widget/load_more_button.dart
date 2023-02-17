// import 'package:hyppe/core/constants/enum.dart';
// import 'package:hyppe/ui/constant/widget/custom_loading.dart';
// import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
// import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
// import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
// import 'package:hyppe/ui/inner/notification/notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class LoadMoreButton extends StatelessWidget {
//   final NotificationCategory notificationCategory;

//   const LoadMoreButton({Key? key, required this.notificationCategory}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme.secondary;
//     final notifier = context.select((NotificationNotifier value) => value.loadingForObject(NotificationNotifier.loadMoreKey));

//     return Padding(
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 50,
//             height: 1.5,
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: BorderRadius.circular(5),
//             ),
//           ),
//           fivePx,
//           if (!notifier)
//             CustomTextButton(
//               onPressed: () => context.read<NotificationNotifier>().getNotification(context, notificationCategory),
//               child: CustomTextWidget(
//                 textToDisplay: 'Load more',
//                 textStyle: Theme.of(context).textTheme.button.copyWith(color: color),
//               ),
//             )
//           else
//             const SizedBox(height: 48, width: 48, child: const CustomLoading())
//         ],
//       ),
//       padding: const EdgeInsets.only(bottom: 10, left: 16),
//     );
//   }
// }
