import 'package:hyppe/ui/constant/entities/web_view/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
// import 'package:hyppe/ui/inner/home/content/wallet/notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

class WalletWebView extends StatefulWidget {
  final String arguments;

  const WalletWebView({Key? key, required this.arguments}) : super(key: key);

  @override
  _WalletWebViewState createState() => _WalletWebViewState();
}

class _WalletWebViewState extends State<WalletWebView> {
  // late WalletNotifier _walletNotifier;

  @override
  void initState() {
    // _walletNotifier = Provider.of<WalletNotifier>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    // _walletNotifier.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surface;

    return SafeArea(
      child: Consumer<WebViewNotifier>(
        builder: (_, notifier, __) {
          return WillPopScope(
            onWillPop: notifier.onWillPop,
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: Colors.white,
                title: CustomTextWidget(
                  textToDisplay: 'DANA',
                  textStyle: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                  color: color,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => notifier.onWillPop(),
                ),
              ),
              body: InAppWebView(
                initialUrlRequest: URLRequest(url: Uri.tryParse(widget.arguments)),
                onWebViewCreated: (controller) => context.read<WebViewNotifier>().webViewController = controller,
              ),
            ),
          );
        },
      ),
    );
  }
}
