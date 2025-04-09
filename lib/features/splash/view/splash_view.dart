import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/constants/color_constants.dart';
import 'package:vilsa/core/constants/padding_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/features/home/view/home_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startTimer();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.65, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.primary,
      body: SafeArea(
        child: Padding(
          padding: PaddingConstants.allMedium,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(), // Pushes the text to the bottom

                    Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Center(
                          child: Image.asset(
                            'assets/icon/app_icon.png',
                            width: context.width * 0.8,
                            height: context.width * 0.8,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(), // Pushes the text to the bottom
                    Opacity(
                      opacity: _opacityAnimation.value,
                      child: Headline(
                        text: 'Vilsa',
                        color: AppColors.white,
                        isCentred: true,
                      ),
                    ),
                    Opacity(
                      opacity: _opacityAnimation.value,
                      child: Content(
                        text: 'Finansal Yönetim',
                        color: AppColors.white.withValues(alpha: 0.9),
                        isCentred: true,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
