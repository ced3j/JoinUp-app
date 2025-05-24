import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  late AnimationController _shineController;
  late Animation<double> _shineAnimation;

  late AnimationController _slideControllerJ;
  late Animation<Offset> _slideAnimationJ;

  late AnimationController _dropControllerJoinUp;
  late Animation<double> _dropAnimationJoinUp;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  final Color joinUpColor = const Color(0xFF6F2DBD);

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _shineAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _shineController, curve: Curves.linear));

    _slideControllerJ = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _slideAnimationJ = Tween<Offset>(
      begin: const Offset(-1.2, 0), // Soldan başla
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideControllerJ, curve: Curves.easeOut),
    );

    _dropControllerJoinUp = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Yukarıdan aşağıya düşme animasyonu, başta çok yukarıda (gözükmez)
    _dropAnimationJoinUp = Tween<double>(
      begin: -1000, // ekran dışı çok yukarıda
      end: 0, // final pozisyon (ekran içinde)
    ).animate(
      CurvedAnimation(parent: _dropControllerJoinUp, curve: Curves.easeOutBack),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.4,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    // Animasyonları sırayla başlatıyoruz
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideControllerJ.forward();
      _scaleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      _dropControllerJoinUp.forward();
    });

    Timer(const Duration(seconds: 4), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _shineController.dispose();
    _slideControllerJ.dispose();
    _dropControllerJoinUp.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SlideTransition(
                position: _slideAnimationJ,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _rotationController,
                    _shineController,
                  ]),
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            begin: Alignment(-1, 0),
                            end: Alignment(1, 0),
                            colors: [
                              joinUpColor.withOpacity(0.3),
                              Colors.white.withOpacity(0.8),
                              joinUpColor.withOpacity(0.3),
                            ],
                            stops: [
                              (_shineAnimation.value - 0.3).clamp(0.0, 1.0),
                              _shineAnimation.value.clamp(0.0, 1.0),
                              (_shineAnimation.value + 0.3).clamp(0.0, 1.0),
                            ],
                          ).createShader(bounds);
                        },
                        child: child,
                        blendMode: BlendMode.srcATop,
                      ),
                    );
                  },
                  child: Text(
                    'J',
                    style: TextStyle(
                      fontSize: 65,
                      fontWeight: FontWeight.bold,
                      color: joinUpColor.withOpacity(0.9),
                      shadows: [
                        Shadow(
                          color: joinUpColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 0),
                        ),
                      ],
                      letterSpacing: -5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),

              AnimatedBuilder(
                animation: _dropAnimationJoinUp,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _dropAnimationJoinUp.value),
                    child: child,
                  );
                },
                child: Text(
                  'oin Up',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: joinUpColor,
                    letterSpacing: -1,
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
