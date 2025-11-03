import 'package:book_swap/presentation/pages/browse_listings_page.dart';
import 'package:book_swap/presentation/pages/chat_detail_page.dart';
import 'package:book_swap/presentation/pages/chats_list_page.dart';
import 'package:book_swap/presentation/pages/main_wrapper.dart';
import 'package:book_swap/presentation/pages/my_listings_page.dart';
import 'package:book_swap/presentation/pages/post_book_page.dart';
import 'package:book_swap/presentation/pages/settings_page.dart';
import 'package:book_swap/presentation/pages/auth/welcome_page.dart';
import 'package:book_swap/presentation/pages/auth/signin_page.dart';
import 'package:book_swap/presentation/pages/auth/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static const String initial = '/';
  static const String welcome = '/welcome';
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String browseListings = '/browse';
  static const String myListings = '/my-listings';
  static const String chats = '/chats';
  static const String settings = '/settings';
  static const String postBook = '/post-book';
  static const String chatDetail = 'chat-detail/:chatId/:otherUserId';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final isLoggedIn = ValueNotifier<bool>(firebaseAuth.currentUser != null);

  firebaseAuth.authStateChanges().listen((user) {
    isLoggedIn.value = user != null;
  });

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: isLoggedIn,
    initialLocation: AppRoutes.initial,
    routes: [
      GoRoute(
        path: AppRoutes.initial,
        redirect: (context, state) {
          if (!isLoggedIn.value) {
            return AppRoutes.welcome;
          }
          return AppRoutes.browseListings;
        },
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: AppRoutes.signin,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainWrapper(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.browseListings,
            name: AppRoutes.browseListings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BrowseListingsPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.myListings,
            name: AppRoutes.myListings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MyListingsPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.chats,
            name: AppRoutes.chats,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ChatsListPage(),
            ),
            routes: [
              GoRoute(
                path: AppRoutes.chatDetail,
                name: AppRoutes.chatDetail,
                builder: (context, state) {
                  final chatId = state.pathParameters['chatId']!;
                  final otherUserId = state.pathParameters['otherUserId']!;
                  return ChatDetailPage(chatId: chatId, otherUserId: otherUserId);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: AppRoutes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.postBook,
        name: AppRoutes.postBook,
        builder: (context, state) => const PostBookPage(),
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          return ChatDetailPage(chatId: chatId);
        },
      ),
    ],
    redirect: (context, state) {
      if (isLoggedIn.value && (state.fullPath == AppRoutes.welcome || state.fullPath == AppRoutes.signin || state.fullPath == AppRoutes.signup)) {
        return AppRoutes.browseListings;
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Error: ${state.error}')),
    ),
  );
});
