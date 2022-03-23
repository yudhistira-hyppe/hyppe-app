// import 'package:hyppe/core/services/route_observer_service.dart';
// import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// abstract class CustomPage<T extends ChangeNotifier> extends StatelessWidget {
//   const CustomPage({Key? key}) : super(key: key);

//   /// Determine this widget is reactive or not - Required
//   bool get isReactive;

//   /// A function that builds the UI to be shown from the notifier - Required
//   Widget builder(
//     BuildContext context,
//     T notifier,
//     Widget? child,
//   );

//   /// Called when this widget has a single widget already rendered.
//   void onPageReady(BuildContext context, T notifier) {}

//   /// Called when this widget has been pop out.
//   void onDispose(BuildContext context, T notifier) {}

//   /// Called when the top route has been popped off, and the current route
//   /// shows up.
//   void onDidPopNext(BuildContext context, T notifier) {}

//   /// Called when the current route has been pushed.
//   void onDidPush(BuildContext context, T notifier) {}

//   /// Called when the current route has been popped off.
//   void onDidPop(BuildContext context, T notifier) {}

//   /// Called when a new route has been pushed, and the current route is no
//   /// longer visible.
//   void onDidPushNext(BuildContext context, T notifier) {}

//   @override
//   Widget build(BuildContext context) {
//     if (isReactive) {
//       return Consumer<T>(
//         builder: (context, notifier, child) => CustomRouteAwarePage(
//           notifier: notifier,
//           onPageReady: onPageReady,
//           onDispose: onDispose,
//           onDidPopNext: onDidPopNext,
//           onDidPush: onDidPush,
//           onDidPop: onDidPop,
//           onDidPushNext: onDidPushNext,
//           child: builder(context, notifier, child),
//         ),
//       );
//     } else {
//       final notifier = Provider.of<T>(context, listen: false);

//       return CustomRouteAwarePage(
//         notifier: notifier,
//         onPageReady: onPageReady,
//         onDispose: onDispose,
//         onDidPopNext: onDidPopNext,
//         onDidPush: onDidPush,
//         onDidPop: onDidPop,
//         onDidPushNext: onDidPushNext,
//         child: builder(context, notifier, null),
//       );
//     }
//   }
// }

// class CustomRouteAwarePage<T extends ChangeNotifier> extends StatefulWidget {
//   final Function(BuildContext context, T notifier) onPageReady;
//   final Function(BuildContext context, T notifier) onDispose;
//   final Function(BuildContext context, T notifier) onDidPopNext;
//   final Function(BuildContext context, T notifier) onDidPush;
//   final Function(BuildContext context, T notifier) onDidPop;
//   final Function(BuildContext context, T notifier) onDidPushNext;
//   final Widget child;
//   final T notifier;
//   const CustomRouteAwarePage({
//     Key? key,
//     required this.child,
//     required this.notifier,
//     required this.onPageReady,
//     required this.onDispose,
//     required this.onDidPopNext,
//     required this.onDidPush,
//     required this.onDidPop,
//     required this.onDidPushNext,
//   }) : super(key: key);

//   @override
//   _CustomRouteAwarePageState<T> createState() => _CustomRouteAwarePageState<T>();
// }

// class _CustomRouteAwarePageState<T extends ChangeNotifier> extends State<CustomRouteAwarePage<T>> with RouteAware, AfterFirstLayoutMixin {
//   @override
//   void afterFirstLayout(BuildContext context) {
//     widget.onPageReady(context, widget.notifier);
//   }

//   @override
//   void dispose() {
//     widget.onDispose(context, widget.notifier);
//     CustomRouteObserver.routeObserver.unsubscribe(this);
//     super.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
//     super.didChangeDependencies();
//   }

//   @override
//   void didPopNext() {
//     widget.onDidPopNext(context, widget.notifier);
//     super.didPopNext();
//   }

//   @override
//   void didPush() {
//     widget.onDidPush(context, widget.notifier);
//     super.didPush();
//   }

//   @override
//   void didPop() {
//     widget.onDidPop(context, widget.notifier);
//     super.didPop();
//   }

//   @override
//   void didPushNext() {
//     widget.onDidPopNext(context, widget.notifier);
//     super.didPushNext();
//   }

//   @override
//   Widget build(_) => widget.child;
// }
