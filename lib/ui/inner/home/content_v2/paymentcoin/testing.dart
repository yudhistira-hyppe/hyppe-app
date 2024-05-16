import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class TestingPage extends StatefulWidget {
  const TestingPage({super.key});

  @override
  State<TestingPage> createState() => _TestingPageState();
}

class _TestingPageState extends State<TestingPage> {
  LocalizationModelV2? lang;
  Timer? _timer;
  int _start = 10;

  @override
  void initState() {
    lang = context.read<TranslateNotifierV2>().translate;
    if (_timer != null) {
      _timer!.cancel();
      _start = 10;
    }
    _timer = Timer.periodic(Duration(seconds: _start), (timer) { 
      Navigator.pushReplacementNamed(context, Routes.topUpCoins);
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
            onPressed: () => Routing().moveBack(),
            icon: const Icon(Icons.arrow_back_ios)),
        title: CustomTextWidget(
          textStyle: theme.textTheme.titleMedium,
          textToDisplay: '${lang?.awaitingpayment}',
        ),
      ),
    );
  }
}