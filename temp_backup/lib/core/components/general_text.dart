import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Base text component that all other text components extend from
class _GeneralText extends StatelessWidget {
  final String text;
  final Color? color;
  final bool isBold;
  final bool isCentred;
  final double fontSize;
  final bool overflow;

  const _GeneralText({
    super.key,
    required this.text,
    this.color = Colors.black,
    this.isBold = false,
    this.isCentred = false,
    this.fontSize = 16,
    this.overflow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: isCentred ? TextAlign.center : TextAlign.start,
      style: GoogleFonts.montserrat(
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
        color: color,
        letterSpacing: 0.5,
      ),
      overflow: overflow ? TextOverflow.ellipsis : TextOverflow.visible,
      maxLines: overflow ? 1 : null,
    );
  }
}

/// Headline - Used for main titles and important headers
/// Material Design equivalent: Headline Medium
class Headline extends _GeneralText {
  const Headline({
    super.key,
    required super.text,
    super.color = null,
    super.isBold = true,
    super.isCentred,
    super.fontSize = 24,
  });
}

/// SubHeadline - Used for section headers
/// Material Design equivalent: Headline Small
class SubHeadline extends _GeneralText {
  const SubHeadline({
    super.key,
    required super.text,
    super.color = null,
    super.isBold = true,
    super.isCentred,
    super.fontSize = 20,
  });
}

/// Highlight - Used for emphasized text and medium-importance headers
/// Material Design equivalent: Title Medium
class Highlight extends _GeneralText {
  const Highlight({
    super.key,
    required super.text,
    super.color = null,
    super.isBold = true,
    super.isCentred,
    super.fontSize = 16,
  });
}

/// Content - Used for regular body text
/// Material Design equivalent: Body Medium
class Content extends _GeneralText {
  const Content({
    super.key,
    required super.text,
    super.color = null,
    super.isBold = false,
    super.isCentred,
    super.fontSize = 14,
  });
}

/// Helper - Used for secondary/supporting text
/// Material Design equivalent: Body Small
class Helper extends _GeneralText {
  const Helper({
    super.key,
    required super.text,
    super.color = null,
    super.isBold = false,
    super.isCentred,
    super.fontSize = 12,
    super.overflow,
  });
}

/// Label - Used for captions, hints, and smallest text elements
/// Material Design equivalent: Label Small
class Label extends _GeneralText {
  const Label({
    super.key,
    required super.text,
    super.color = null,
    super.isBold = false,
    super.isCentred,
    super.fontSize = 10,
    super.overflow,
  });
}
