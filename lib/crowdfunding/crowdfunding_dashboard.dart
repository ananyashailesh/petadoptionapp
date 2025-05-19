import 'package:adoption_ui_app/crowdfunding/pages/page_list.dart';
import 'package:adoption_ui_app/crowdfunding/pages/page_typography.dart';
import 'package:adoption_ui_app/crowdfunding/pages/post_page.dart';
import 'package:adoption_ui_app/crowdfunding/pages/success_story_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
// ignore: depend_on_referenced_packages
import 'package:responsive_framework/responsive_framework.dart';

class CrowdfundingDashboard extends StatelessWidget {
  const CrowdfundingDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: MaterialApp(
        builder: (context, child) => ResponsiveBreakpoints.builder(
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
          child: child!,
        ),
        initialRoute: '/',
        onGenerateInitialRoutes: (initialRoute) {
          final Uri uri = Uri.parse(initialRoute);
          return [buildPage(path: uri.path, queryParams: uri.queryParameters)];
        },
        onGenerateRoute: (RouteSettings settings) {
          final Uri uri = Uri.parse(settings.name ?? '/');
          return buildPage(path: uri.path, queryParams: uri.queryParameters);
        },
        theme: ThemeData(
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: SharedAxisPageTransitionsBuilder(
                transitionType: SharedAxisTransitionType.vertical,
                fillColor: Colors.transparent,
              ),
              TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
                transitionType: SharedAxisTransitionType.vertical,
                fillColor: Colors.transparent,
              ),
              TargetPlatform.fuchsia: SharedAxisPageTransitionsBuilder(
                transitionType: SharedAxisTransitionType.vertical,
                fillColor: Colors.transparent,
              ),
              TargetPlatform.linux: SharedAxisPageTransitionsBuilder(
                transitionType: SharedAxisTransitionType.vertical,
                fillColor: Colors.transparent,
              ),
              TargetPlatform.macOS: SharedAxisPageTransitionsBuilder(
                transitionType: SharedAxisTransitionType.vertical,
                fillColor: Colors.transparent,
              ),
              TargetPlatform.windows: SharedAxisPageTransitionsBuilder(
                transitionType: SharedAxisTransitionType.vertical,
                fillColor: Colors.transparent,
              ),
            },
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  Route<dynamic> buildPage({
    required String path,
    Map<String, String> queryParams = const {},
  }) {
    return PageRouteBuilder(
      settings: RouteSettings(
        name: (path.startsWith('/') == false) ? '/$path' : path,
      ),
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        String pathName =
            path != '/' && path.startsWith('/') ? path.substring(1) : path;
        return SelectionArea(
          child: switch (pathName) {
            '/' || ListPage.name => const ListPage(),
            'post' => PostPage(),
            'success_story' => SuccessStoryPage(),
            TypographyPage.name => const TypographyPage(),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}
