import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/constants/padding_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/features/splash/viewmodel/splash_viewmodel.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  // AnimationController for the scale and opacity
  late AnimationController _animationController;

  // Animation for the scale
  late Animation<double> _scaleAnimation;

  // Animation for the opacity
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Setting up the animations
    _setupAnimations();

    // Checking the connectivity and preloading the data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashViewModel>().checkConnectivityAndPreloadData(context);
    });
  }

  // Setting up the animations
  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // Scale animation for the image
    _scaleAnimation = Tween<double>(begin: 1.0, end: 120.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.fastLinearToSlowEaseIn),
      ),
    );

    // Opacity animation for the image
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    // Forwarding the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    // Disposing the animation controller
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold for the splash screen
    return Scaffold(
      // Background color
      backgroundColor: context.primary,

      // Safe area for the splash screen
      body: SafeArea(
        child: Padding(
          // Padding for the splash screen
          padding: PaddingConstants.allMedium,

          // Animation for the splash screen
          child: AnimatedBuilder(
            // Animation controller for the scale and opacity
            animation: _animationController,
            builder: (context, child) {
              // Center for the splash screen
              return Center(
                // Opacity for the splash screen
                child: Opacity(
                  // Opacity for the splash screen
                  opacity: _opacityAnimation.value,

                  // Transform scale for the image
                  child: Transform.scale(
                    // Scale for the image
                    scale: _scaleAnimation.value,

                    // App icon
                    child: Image.asset(
                      'asset/icon/app_icon.png',

                      // Width for the image
                      width: context.width * 0.8,

                      // Height for the image
                      height: context.width * 0.8,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
