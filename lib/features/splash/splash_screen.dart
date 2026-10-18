import 'package:flutter/material.dart';

import '../../core/accessibility/accessibility_scope.dart';
import '../../core/auth/auth_service.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/models/post.dart';
import '../../core/navigation/deep_link_service.dart';
import '../../core/navigation/fade_route.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../../core/network/server_status.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/brand_launch_backdrop.dart';
import '../auth/login_screen.dart';
import '../kid_listo/kid_listo_welcome_screen.dart';
import '../maintenance/under_maintenance_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = context.accessibility.reduceMotion ||
        MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _controller.value = 1;
      return;
    }
    if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _waitMinSplash(DateTime start) async {
    final elapsed = DateTime.now().difference(start);
    final remaining = const Duration(milliseconds: 1200) - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
  }

  Future<void> _openNext(Widget page) async {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(fadeRoute<void>(page));
  }

  Future<void> _loadInitialData() async {
    final start = DateTime.now();
    List<Post> posts = [];

    final reachable = await ServerStatus.isReachable();
    if (!mounted) return;
    if (!reachable) {
      await _waitMinSplash(start);
      await _openNext(const UnderMaintenanceScreen());
      return;
    }

    final loggedIn = await AuthService.ensureValidSession();

    try {
      final token = loggedIn ? await AuthService.getToken() : null;
      final api = ApiClient(token: token);
      final res = await api.get<Map<String, dynamic>>(Endpoints.posts);
      final root = res.data ?? <String, dynamic>{};
      final data = (root['data'] is Map<String, dynamic>)
          ? (root['data']['data'] as List<dynamic>? ?? const [])
          : <dynamic>[];
      posts = data
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      posts = [];
    }

    final elapsed = DateTime.now().difference(start);
    final remaining = const Duration(seconds: 5) - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    if (!mounted) return;

    if (loggedIn) {
      await _openNext(KidListoWelcomeScreen(initialPosts: posts));
    } else {
      await _openNext(
        LoginScreen(
          asAuthGate: true,
          initialPosts: posts,
        ),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService.consumePending();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final sealSize = shortest < 360 ? 120.0 : 132.0;

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: BrandLaunchBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              children: [
                Expanded(
                  child: Align(
                    alignment: const Alignment(0, -0.12),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BrandSeal(size: sealSize),
                            const SizedBox(height: 30),
                            Text(
                              l10n.splashAppName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 4.2,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.splashFullName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 128,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      color: AppColors.accentYellow,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.splashFooter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
