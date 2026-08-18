import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:zpasjidoliturgii/features/liturgical_courses/presentation/bloc/study_plan_bloc.dart';
import 'package:zpasjidoliturgii/features/liturgical_courses/presentation/screens/completorium_screen.dart';
import 'package:zpasjidoliturgii/features/liturgical_courses/presentation/screens/course_details_screen.dart';

import 'main_wrapper.dart';
import '../features/liturgical_courses/data/repositories/course_repository_impl.dart';
import '../features/liturgical_courses/presentation/bloc/courses_bloc.dart';
import '../features/liturgical_courses/presentation/bloc/courses_event.dart';
import '../features/liturgical_courses/presentation/screens/home_screen.dart';
import '../features/liturgical_courses/presentation/screens/path_screen.dart'; 
import '../features/auth/presentation/screens/profile_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/liturgical_courses/data/repositories/progress_repository.dart';
import '../features/liturgical_courses/presentation/bloc/progress_bloc.dart';
import '../features/liturgical_courses/presentation/screens/completorium_day_detail_screen.dart';

import 'package:zpasjidoliturgii/features/liturgical_courses/presentation/screens/podcast_screen.dart';

class AppRoutes {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    navigatorKey: _rootNavigatorKey,

    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/courses',
                builder: (context, state) {
                  final tabIndex = state.extra as int? ?? 0;
                  return BlocProvider(
                    create: (context) => CoursesBloc(
                      courseRepository: CourseRepositoryImpl(),
                    )..add(LoadCourses()),
                    child: PathScreen(initialTabIndex: tabIndex), 
                  );
                },
                routes: [
                  GoRoute(
                    path: 'details/:id',
                    pageBuilder: (context, state) {
                      final courseId = state.pathParameters['id']!;
                      final courseTitle = state.extra as String? ?? 'Szczegóły kursu';

                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (context) => StudyPlanBloc(
                                courseRepository: CourseRepositoryImpl(),
                              )..add(LoadStudyPlans(courseId)),
                            ),
                            BlocProvider(
                              create: (context) => ProgressBloc(
                                progressRepository: ProgressRepository(),
                              )..add(LoadProgress(courseId)),
                            ),
                          ],
                          child: CourseDetailsScreen(
                            courseId: courseId, 
                            courseTitle: courseTitle
                          ),
                        ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                            child: child,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          
          
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/completorium',
                builder: (context, state) => const CompletoriumScreen(),
                routes: [
                  GoRoute(
                    path: 'details',
                    builder: (context, state) {
                      final extraData = state.extra as Map<String, dynamic>? ?? {};
                      final title = extraData['title'] as String? ?? 'Kompleta';
                      final youtubeUrl = extraData['url'] as String? ?? '';

                      return CompletoriumDayDetailScreen(
                        dayTitle: title, 
                        youtubeUrl: youtubeUrl,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/podcast',
                builder: (context, state) => const PodcastScreen(),
              ),
            ],
          ),

        ],
      ),
    ],
  );
}