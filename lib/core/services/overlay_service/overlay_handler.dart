import 'package:flutter/material.dart';

class OverlayHandlerProvider {
  OverlayEntry? overlayEntry;
  final double _aspectRatio = 1.77;

  bool get overlayActive => overlayEntry != null;
  get aspectRatio => _aspectRatio;

  insertOverlay(BuildContext context, OverlayEntry overlay) {
    if (overlayEntry != null) {
      overlayEntry?.remove();
    }
    overlayEntry = null;
    Overlay.of(context)?.insert(overlay);
    overlayEntry = overlay;
  }

  removeOverlay(BuildContext context) {
    if (overlayEntry != null) {
      overlayEntry?.remove();
    }
    overlayEntry = null;
  }
}
