import 'package:flutter/material.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/constants/general_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';

/// Tüm sayfalarda tutarlı bir şekilde kullanılabilen bölüm container'ı
/// Başlık ve içerik alanlarından oluşur
class SectionContainer extends StatefulWidget {
  final String title;
  final Widget content;
  final Widget? trailing;
  final EdgeInsets contentPadding;
  final bool showShadow;
  final Color? headerColor;
  final Color? borderColor;

  const SectionContainer({
    super.key,
    required this.title,
    required this.content,
    this.trailing,
    this.contentPadding = const EdgeInsets.all(12),
    this.showShadow = true,
    this.headerColor,
    this.borderColor,
  });

  @override
  State<SectionContainer> createState() => _SectionContainerState();
}

class _SectionContainerState extends State<SectionContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
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

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.onPrimary,
            borderRadius: GeneralConstants.instance.borderRadius,
            border: Border.all(
              color: widget.borderColor ?? context.secondary.withValues(alpha: 0.2),
            ),
            boxShadow: widget.showShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık kısmı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.headerColor ?? context.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: GeneralConstants.instance.borderRadius.topLeft,
                    topRight: GeneralConstants.instance.borderRadius.topRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Label(
                      text: widget.title,
                      isBold: true,
                      fontSize: 14,
                      color: context.primary,
                    ),
                    if (widget.trailing != null) widget.trailing!,
                  ],
                ),
              ),

              // İçerik kısmı
              Padding(
                padding: widget.contentPadding,
                child: widget.content,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// İçinde satır bileşeni olan section container versiyonu
class SectionWithRows extends StatefulWidget {
  final String title;
  final List<Map<String, String>> rows;
  final Widget? trailing;
  final EdgeInsets contentPadding;
  final bool showShadow;
  final Color? headerColor;
  final Color? borderColor;

  const SectionWithRows({
    super.key,
    required this.title,
    required this.rows,
    this.trailing,
    this.contentPadding = const EdgeInsets.all(12),
    this.showShadow = true,
    this.headerColor,
    this.borderColor,
  });

  @override
  State<SectionWithRows> createState() => _SectionWithRowsState();
}

class _SectionWithRowsState extends State<SectionWithRows> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
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

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SectionContainer(
          title: widget.title,
          trailing: widget.trailing,
          contentPadding: widget.contentPadding,
          showShadow: widget.showShadow,
          headerColor: widget.headerColor?.withValues(alpha: 0.5),
          borderColor: widget.borderColor,
          content: Column(
            children: widget.rows.map((row) {
              final entry = row.entries.first;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Label(
                      text: entry.key,
                      color: context.onSurface,
                    ),
                    Helper(
                      text: entry.value,
                      isBold: true,
                      color: context.onSurface,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Grafik bileşenini içeren section container versiyonu
class ChartSectionContainer extends StatefulWidget {
  final String title;
  final Widget chart;
  final Widget? trailing;
  final double height;
  final EdgeInsets contentPadding;
  final bool showShadow;
  final Color? headerColor;
  final Color? borderColor;

  const ChartSectionContainer({
    super.key,
    required this.title,
    required this.chart,
    this.trailing,
    this.height = 200,
    this.contentPadding = const EdgeInsets.all(12),
    this.showShadow = true,
    this.headerColor,
    this.borderColor,
  });

  @override
  State<ChartSectionContainer> createState() => _ChartSectionContainerState();
}

class _ChartSectionContainerState extends State<ChartSectionContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
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

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SectionContainer(
          title: widget.title,
          trailing: widget.trailing,
          contentPadding: widget.contentPadding,
          showShadow: widget.showShadow,
          headerColor: widget.headerColor,
          borderColor: widget.borderColor,
          content: SizedBox(
            height: widget.height,
            child: widget.chart,
          ),
        ),
      ),
    );
  }
}
