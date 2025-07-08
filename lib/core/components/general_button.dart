import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/core/init/network/debounce_service.dart';

import '../constants/general_constants.dart';

class GeneralButton extends StatelessWidget {
  const GeneralButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.textColor,
    required this.backgroundColor,
    this.isEnable = true,
    this.icon,
    this.isSecondary = false,
    this.borderColor,
    this.debounceKey,
    this.debounceTime,
  });

  final VoidCallback? onPressed;
  final String text;
  final Color textColor;
  final Color backgroundColor;
  final Widget? icon;
  final bool isEnable;
  final bool isSecondary;
  final Color? borderColor;
  final String? debounceKey;
  final Duration? debounceTime;

  void _handleTap() {
    if (onPressed == null) return;

    if (debounceKey != null) {
      // Use debounce with provided key
      final debounceService = DebounceService();
      debounceService.execute(
        debounceKey!,
        onPressed!,
        debounceTime: debounceTime,
      );
    } else {
      // Execute immediately without debounce
      onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: GestureDetector(
        onTap: isEnable ? _handleTap : null,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: isSecondary
                ? null
                : [
                    BoxShadow(
                      color: context.onSurface.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
            color: isSecondary ? null : backgroundColor,
            borderRadius: GeneralConstants.instance.borderRadius,
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 2)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                context.spacerWidthFixed(10),
              ],
              Text(
                text,
                style: GoogleFonts.montserrat(
                  fontWeight: isSecondary ? FontWeight.normal : FontWeight.bold,
                  fontSize: isSecondary ? 14 : 16,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
