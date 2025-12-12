import 'package:flutter/material.dart';

/// Affiche un message type "Toast" en haut de l'écran via Overlay.
void showTopSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  final topPadding = MediaQuery.of(context).padding.top;

  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: topPadding + 10,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.black87,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(duration, () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}
