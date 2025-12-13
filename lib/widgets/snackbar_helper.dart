import 'package:flutter/material.dart';

/// Affiche un message type "Toast" en haut de l'écran via Overlay avec un design moderne.
void showTopSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  Duration duration = const Duration(seconds: 3),
  IconData? icon,
  bool isError = false,
}) {
  final overlay = Overlay.of(context);
  final topPadding = MediaQuery.of(context).padding.top;

  // Définir les couleurs selon le type
  final bgColor = backgroundColor ?? 
    (isError ? const Color(0xFFDC2626) : const Color(0xFF10B981));
  
  final overlayEntry = OverlayEntry(
    builder: (context) => _AnimatedSnackBar(
      topPadding: topPadding,
      message: message,
      backgroundColor: bgColor,
      icon: icon ?? (isError ? Icons.error_outline : Icons.check_circle_outline),
      duration: duration,
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(duration, () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}

class _AnimatedSnackBar extends StatefulWidget {
  final double topPadding;
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final Duration duration;

  const _AnimatedSnackBar({
    required this.topPadding,
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.duration,
  });

  @override
  State<_AnimatedSnackBar> createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<_AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    // Auto-dismiss avec animation
    Future.delayed(widget.duration - const Duration(milliseconds: 400), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.topPadding + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center( // Center to allow width constraints to take effect
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400), // Limit width for large screens/web
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16), // Margin for mobile
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.backgroundColor,
                        widget.backgroundColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.backgroundColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
