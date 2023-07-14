import "package:amplify_todo_riverpod/pages/add_view.dart";
import "package:amplify_todo_riverpod/pages/home_view.dart";
import "package:amplify_todo_riverpod/routes/transition.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

// ignore: avoid_classes_with_only_static_members
class Routes {
  static List<RouteBase> routes = [
    /* Start Employee routes */
    GoRoute(
      path: "/",
      pageBuilder: (BuildContext context, GoRouterState state) =>
          FadeTransitionPage(
        key: state.pageKey,
        child: const HomePage(),
      ),
      routes: [
        GoRoute(
          path: "add",
          builder: (context, state) {
            return const AddPage();
          },
        ),
      ],
    ),
    /* End Employee routes */
  ];
}
