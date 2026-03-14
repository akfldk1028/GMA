import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final CurvedAnimation _logoScale;
  late final CurvedAnimation _logoOpacity;
  late final CurvedAnimation _titleOpacity;
  late final CurvedAnimation _titleSlideCurve;
  late final Animation<Offset> _titleSlide;
  late final CurvedAnimation _subtitleOpacity;
  late final CurvedAnimation _progressOpacity;

  Timer? _textDelayTimer;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    _titleOpacity = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );
    _titleSlideCurve = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(_titleSlideCurve);

    _subtitleOpacity = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
    );
    _progressOpacity = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    );

    _logoController.forward();
    _textDelayTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) _textController.forward();
    });

    _navigationTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) context.go('/dashboard');
    });
  }

  @override
  void dispose() {
    _textDelayTimer?.cancel();
    _navigationTimer?.cancel();
    _logoScale.dispose();
    _logoOpacity.dispose();
    _titleOpacity.dispose();
    _titleSlideCurve.dispose();
    _subtitleOpacity.dispose();
    _progressOpacity.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accentLight,   // violet-50
              AppColors.primaryLight,  // violet-100
              AppColors.accentLight,   // violet-50
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo with scale-in
              ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.link_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Title
              SlideTransition(
                position: _titleSlide,
                child: FadeTransition(
                  opacity: _titleOpacity,
                  child: const Text(
                    'LinkNote',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              FadeTransition(
                opacity: _subtitleOpacity,
                child: const Text(
                  'PDF-Linked Markdown Annotation',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Progress indicator
              FadeTransition(
                opacity: _progressOpacity,
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
