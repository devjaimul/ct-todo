
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/views/sign_in_screen.dart';
import '../../features/auth/views/sign_up_screen.dart';
import '../../features/home/views/add_edit_todo_screen.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/splash/splash_screen.dart';

/// Centralized GoRouter configuration with named routes.
class AppRouter {
  AppRouter._();

  // ── Route Names ────────────────────────────────────────────────────────
  static const String splash = 'splash';
  static const String signIn = 'signIn';
  static const String signUp = 'signUp';
  static const String home = 'home';
  static const String addTodo = 'addTodo';
  static const String editTodo = 'editTodo';

  // ── Route Paths ────────────────────────────────────────────────────────
  static const String splashPath = '/';
  static const String signInPath = '/sign-in';
  static const String signUpPath = '/sign-up';
  static const String homePath = '/home';
  static const String addTodoPath = '/add-todo';
  static const String editTodoPath = '/edit-todo';

  // ── Router ─────────────────────────────────────────────────────────────
  static final GoRouter router = GoRouter(
    initialLocation: splashPath,
    routes: [
      GoRoute(
        path: splashPath,
        name: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: signInPath,
        name: signIn,
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignInScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: signUpPath,
        name: signUp,
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignUpScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: homePath,
        name: home,
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: addTodoPath,
        name: addTodo,
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddEditTodoScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: editTodoPath,
        name: editTodo,
        pageBuilder: (_, state) {
          final todoId = state.uri.queryParameters['id'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: AddEditTodoScreen(todoId: todoId),
            transitionsBuilder: _slideUpTransition,
          );
        },
      ),
    ],
  );

  // ── Transitions ────────────────────────────────────────────────────────
  static Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }

  static Widget _slideUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final tween = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutCubic));
    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}
