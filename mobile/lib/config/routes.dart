import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/onboarding/onboarding_page.dart';
import '../presentation/pages/home/main_shell.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/messages/messages_page.dart';
import '../presentation/pages/schedule/schedule_page.dart';
import '../presentation/pages/profile/profile_page.dart';
import '../presentation/pages/doctor/doctor_list_page.dart';
import '../presentation/pages/doctor/doctor_detail_page.dart';
import '../presentation/pages/ar_scanner/ar_scanner_page.dart';
import '../presentation/pages/pharmacy/pharmacy_search_page.dart';
import '../presentation/pages/family/family_dashboard_page.dart';
import '../presentation/pages/emergency/emergency_page.dart';
import '../presentation/pages/medication/medication_list_page.dart';
import '../presentation/pages/medication/medication_detail_page.dart';
import '../presentation/pages/medication/add_medication_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String messages = '/messages';
  static const String schedule = '/schedule';
  static const String profile = '/profile';
  static const String doctors = '/doctors';
  static const String doctorDetail = '/doctors/detail';
  static const String arScanner = '/ar-scanner';
  static const String pharmacy = '/pharmacy';
  static const String family = '/family';
  static const String emergency = '/emergency';
  static const String medications = '/medications';
  static const String medicationDetail = '/medications/:id';
  static const String addMedication = '/medications/add';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      // ── Splash ──
      GoRoute(
        path: splash,
        builder: (context, state) => const _SplashScreen(),
      ),

      // ── Onboarding ──
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),

      // ── Auth ──
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterPage(),
      ),

      // ── Main App with Bottom Nav ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: arScanner,
                builder: (context, state) => const ARScannerPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: emergency,
                builder: (context, state) => const EmergencyPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: pharmacy,
                builder: (context, state) => const PharmacySearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: family,
                builder: (context, state) => const FamilyDashboardPage(),
              ),
            ],
          ),
        ],
      ),

      // ── Standalone Pages (pushed on top of nav) ──
      GoRoute(
        path: doctors,
        builder: (context, state) => const DoctorListPage(),
      ),
      GoRoute(
        path: doctorDetail,
        builder: (context, state) => const DoctorDetailPage(),
      ),
      GoRoute(
        path: messages,
        builder: (context, state) => const MessagesPage(),
      ),
      GoRoute(
        path: schedule,
        builder: (context, state) => const SchedulePage(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: medications,
        builder: (context, state) => const MedicationListPage(),
      ),
      GoRoute(
        path: addMedication,
        builder: (context, state) => const AddMedicationPage(),
      ),
      GoRoute(
        path: medicationDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MedicationDetailPage(medicationId: id);
        },
      ),
    ],
  );
}

// ── Splash Screen ──────────────────────────────────────────────────────────────
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();
  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go(AppRoutes.onboarding);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  size: 52,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'AASHA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your Health Guardian',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
