import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/auth_service.dart';
import '../../../home/presentation/views/main_screen.dart';
import '../../../../core/services/force_update_service.dart';
import '../views/login_view.dart';
import '../views/splash_view.dart';
import '../views/introduction_view.dart';
import '../providers/onboarding_provider.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Check for update after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ForceUpdateService().checkForUpdate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSeenOnboarding = ref.watch(onboardingProvider);

    if (!hasSeenOnboarding) {
      return const IntroductionView();
    }

    return StreamBuilder<User?>(
      stream: AuthService().onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashView();
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const MainScreen();
        }

        return const LoginView();
      },
    );
  }
}
