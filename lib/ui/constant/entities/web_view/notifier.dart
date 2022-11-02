import 'package:hyppe/ux/routing.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewNotifier {
  InAppWebViewController? webViewController;

  Future<bool> onWillPop() async {
    try {
      final canGoBack = await webViewController?.canGoBack();
      if (canGoBack ?? false) {
        webViewController?.goBack();
        return Future.value(false);
      } else {
        Routing().moveBack();
        return Future.value(true);
      }
    } catch (e) {
      Routing().moveBack();
      return Future.value(true);
    }
  }
}
