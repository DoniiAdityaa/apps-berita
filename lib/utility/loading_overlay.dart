import 'package:app_berita/ui/color.dart';
import 'package:flutter/material.dart';

import '../ui/dimension.dart';
import '../ui/typography.dart';

class LoadingOverlay {
  LoadingOverlay();

  OverlayEntry? _overlay;

  void show(BuildContext context) {
    if (_overlay == null) {
      _overlay = OverlayEntry(
        // replace with your own layout
        builder: (context) => PopScope(
          onPopInvoked: (didPop) {
            if (didPop) {
              hide();
            }
          },
          child: Container(
            color: Colors.black.withOpacity(0.5),
            width: double.infinity,
            height: double.infinity,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: primaryColor),
              ),
            ),
          ),
        ),
      );
      Overlay.of(context).insert(_overlay!);
    }
  }

  void showProcess(
    BuildContext context, {
    String? title,
    String? message,
    String? image,
  }) {
    if (_overlay == null) {
      _overlay = OverlayEntry(
        // replace with your own layout
        builder: (context) => Scaffold(
          backgroundColor: bgBackdrop,
          body: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  image ?? "assets/images/img_process_payment.png",
                  width: 150,
                  height: 150,
                ),
              ),
              const SizedBox(height: spacing6),
              Center(child: Text(title ?? "Tunggu sebentar", style: mBold)),
              const SizedBox(height: spacing6),
              Center(
                child: Text(message ?? "Sedang memproses...", style: sRegular),
              ),
            ],
          ),
        ),
      );
      Overlay.of(context).insert(_overlay!);
    }
  }

  void hide() {
    if (_overlay != null) {
      _overlay?.remove();
      _overlay = null;
    }
  }
}
