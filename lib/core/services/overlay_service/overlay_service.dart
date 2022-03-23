import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'overlay_handler.dart';

class OverlayService {
  addOverlayElement(BuildContext context, Widget widget) {
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) => widget);

    context.read<OverlayHandlerProvider>().insertOverlay(context, overlayEntry);
  }
}
