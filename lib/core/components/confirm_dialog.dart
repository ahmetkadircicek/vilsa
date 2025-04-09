import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vilsa/core/constants/color_constants.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/extensions/context_extension.dart';

class ConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final Color? backgroundColor;
  final Color? confirmButtonColor;
  final Color? cancelButtonColor;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = "Sil",
    this.cancelText = "İptal",
    this.icon = Icons.delete_forever_rounded,
    this.backgroundColor,
    this.confirmButtonColor,
    this.cancelButtonColor,
  });

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> with SingleTickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Close dialog with animation
  void _closeWithResult(bool result) {
    _controller.reverse().then((_) {
      Navigator.of(context).pop(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: widget.backgroundColor ?? AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon at the top
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.icon,
                            color: AppColors.error,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Title
                        Headline(
                          text: widget.title,
                          color: context.onSurface,
                          fontSize: 20,
                          isBold: true,
                          isCentred: true,
                        ),
                        const SizedBox(height: 8),
                        // Message
                        Content(
                          text: widget.message,
                          color: context.onSurface.withOpacity(0.7),
                          isCentred: true,
                        ),
                        const SizedBox(height: 24),
                        // Buttons
                        Row(
                          children: [
                            // Cancel button
                            Expanded(
                              flex: 1,
                              child: _buildCancelButton(context),
                            ),
                            const SizedBox(width: 12),
                            // Confirm button
                            Expanded(
                              flex: 1,
                              child: _buildConfirmButton(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _closeWithResult(false),
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.cancelButtonColor ?? Colors.grey.shade200,
        foregroundColor: context.onSurface,
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        widget.cancelText,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: context.onSurface.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _closeWithResult(true),
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.confirmButtonColor ?? AppColors.error,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        widget.confirmText,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
    );
  }
}
