import 'package:flutter/material.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/constants/color_constants.dart';
import 'package:vilsa/core/constants/padding_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';

class SuccessDialog extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Duration duration;

  const SuccessDialog({
    super.key,
    required this.message,
    this.icon = Icons.check_circle_outline_rounded,
    this.backgroundColor,
    this.iconColor,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Otomatik kapanma
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          Navigator.of(context).pop();
        });
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
    return Material(
      color: Colors.transparent,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  margin: PaddingConstants.allMedium,
                  padding: PaddingConstants.allMedium,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? context.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    spacing: 12,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.iconColor ?? AppColors.white,
                        size: 24,
                      ),
                      Expanded(
                        child: Helper(
                          text: widget.message,
                          color: widget.iconColor ?? AppColors.white,
                          isBold: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
