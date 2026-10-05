import 'dart:async';

import 'package:customer_app/features/ai_assistant/presentation/screens/assistant_screen.dart';
import 'package:customer_app/features/alternatives/presentation/screens/alternatives_screen.dart';
import 'package:customer_app/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:customer_app/features/collections/presentation/screens/collections_screen.dart';
import 'package:customer_app/features/compare/presentation/screens/compare_screen.dart';
import 'package:customer_app/features/activity/presentation/screens/activity_screen.dart';
import 'package:customer_app/features/compatibility/presentation/screens/compatibility_screen.dart';
import 'package:customer_app/features/duplicates/presentation/screens/duplicates_screen.dart';
import 'package:customer_app/features/preferences/presentation/screens/privacy_screen.dart';
import 'package:customer_app/features/preferences/presentation/screens/shopping_profile_screen.dart';
import 'package:customer_app/features/recommendations/presentation/screens/recommendations_screen.dart';
import 'package:customer_app/features/sentiment/presentation/screens/sentiment_screen.dart';
import 'package:customer_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:customer_app/features/merchants/presentation/screens/merchants_screen.dart';
import 'package:customer_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:customer_app/features/price_tracking/presentation/screens/price_tracking_screen.dart';
import 'package:customer_app/features/shell/presentation/screens/main_shell.dart';
import 'package:customer_app/features/visual_search/presentation/screens/visual_search_screen.dart';
import 'package:customer_app/features/web_search/presentation/screens/web_search_screen.dart';
import 'package:customer_app/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:decoze_core/core.dart';
import 'package:decoze_core/repositories_impl/category_repository_impl.dart';
import 'package:decoze_core/repositories_impl/product_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';
import 'features/auth/presentation/screens/sign_up_screen.dart';
import 'features/onboarding/presentation/screens/welcome_screen.dart';

class AppRouter {
  final AuthCubit authCubit;

  AppRouter(this.authCubit);

  late final GoRouter router = GoRouter(
    initialLocation: '/welcome',
    refreshListenable: _AuthCubitListenable(authCubit),
    redirect: (context, state) {
      final authState = authCubit.state;
      final isAuthScreen =
          state.matchedLocation == '/sign-in' ||
          state.matchedLocation == '/sign-up';
      final isSplashOrOnboarding =
          state.matchedLocation == '/welcome' ||
          state.matchedLocation == '/onboarding';

      // لسه ماعرفناش حالة المستخدم (أول تحميل) — سيبه في مكانه.
      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      // مسجّل دخول، لكن واقف في شاشة تسجيل دخول أو Splash — وديه Home.
      if (authState is AuthAuthenticated &&
          (isAuthScreen || isSplashOrOnboarding)) {
        return '/home';
      }

      // مش مسجّل دخول، ومحاول يوصل لـ Home مباشرة — امنعه ووديه Sign in.
      if (authState is AuthUnauthenticated &&
          !isAuthScreen &&
          !isSplashOrOnboarding) {
        return '/sign-in';
      }

      return null; // من غير تحويل
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => BlocProvider(
          create: (_) => HomeCubit(
            categoryRepository: CategoryRepositoryImpl(),
            productRepository: ProductRepositoryImpl(),
          ),
          child: const MainShell(),
        ),
      ),

      // =========================================================================
      // AI Shopping Features
      // =========================================================================

      // المساعد الذكي (تاب في MainShell + شاشة مستقلة)
      GoRoute(
        path: '/assistant',
        builder: (context, state) => const AssistantScreen(),
      ),

      // البحث البصري
      GoRoute(
        path: '/visual-search',
        builder: (context, state) => const VisualSearchScreen(),
      ),

      // المقارنة الذكية — بياخد
      // List<ProductEntity> في extra.
      GoRoute(
        path: '/compare',
        builder: (context, state) {
          final products = state.extra as List<ProductEntity>? ?? const [];
          return CompareScreen(products: products);
        },
      ),

      // تتبع الأسعار والتنبيهات
      GoRoute(
        path: '/price-tracking',
        builder: (context, state) => const PriceTrackingScreen(),
      ),

      // البدائل — بياخد productId في extra.
      GoRoute(
        path: '/alternatives',
        builder: (context, state) {
          final productId = state.extra as String? ?? '';
          return AlternativesScreen(productId: productId);
        },
      ),

      // المجموعات (AI collection builder)
      GoRoute(
        path: '/collections',
        builder: (context, state) => const CollectionsScreen(),
      ),

      // قائمة الرغبات الذكية
      GoRoute(
        path: '/wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),

      // البحث عبر المواقع — بياخد
      // query في extra.
      GoRoute(
        path: '/web-search',
        builder: (context, state) {
          final query = state.extra as String? ?? '';
          return WebSearchScreen(initialQuery: query);
        },
      ),

      // التجار والموثوقية
      GoRoute(
        path: '/merchants',
        builder: (context, state) => const MerchantsScreen(),
      ),

      // التحليلات
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),

      // تحليل المشاعر — بياخد
      // productId في extra.
      GoRoute(
        path: '/sentiment',
        builder: (context, state) {
          final productId = state.extra as String? ?? '';
          return SentimentScreen(productId: productId);
        },
      ),

      // التوافق — بياخد
      // productId في extra.
      GoRoute(
        path: '/compatibility',
        builder: (context, state) {
          final productId = state.extra as String? ?? '';
          return CompatibilityScreen(productId: productId);
        },
      ),

      // كشف التكرار (نفس المنتج
      // في أكتر من موقع)
      GoRoute(
        path: '/duplicates',
        builder: (context, state) => const DuplicatesScreen(),
      ),

      // ملف التسوق الشخصي
      GoRoute(
        path: '/shopping-profile',
        builder: (context, state) => const ShoppingProfileScreen(),
      ),

      // إعدادات الخصوصية
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),

      // ذاكرة التسوق
      GoRoute(
        path: '/activity',
        builder: (context, state) => const ActivityScreen(),
      ),

      // التوصية التفسيرية +
      // تقييم المستخدم
      GoRoute(
        path: '/recommendations',
        builder: (context, state) => const RecommendationsScreen(),
      ),
    ],
  );
}

/// go_router محتاج Listenable عشان يعرف "امتى يعيد تقييم الـ redirect".
/// الكلاس ده بيحوّل Stream الخاص بحالة AuthCubit لـ ChangeNotifier
/// بسيط يفهمه go_router.
class _AuthCubitListenable extends ChangeNotifier {
  _AuthCubitListenable(AuthCubit cubit) {
    _subscription = cubit.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
