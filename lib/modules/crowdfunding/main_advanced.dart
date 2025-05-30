import 'package:adoption_ui_app/modules/crowdfunding/pages/page_list.dart';
import 'package:adoption_ui_app/modules/crowdfunding/pages/page_typography.dart';
import 'package:adoption_ui_app/modules/crowdfunding/pages/post_page.dart';
import 'package:adoption_ui_app/modules/crowdfunding/routes.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'utils/conditional_route_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Wrapping the app with a builder method makes breakpoints
      // accessible throughout the widget tree.
      builder:
          (context, child) => ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: [
              const Breakpoint(start: 0, end: 450, name: MOBILE),
              const Breakpoint(start: 451, end: 800, name: TABLET),
              const Breakpoint(start: 801, end: 1920, name: DESKTOP),
              const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
            ],
          ),
      initialRoute: '/',
      // The following code implements the legacy ResponsiveWrapper AutoScale functionality
      // using the new ResponsiveScaledBox. The ResponsiveScaledBox widget preserves
      // the legacy ResponsiveWrapper behavior, scaling the UI instead of resizing.
      //
      // A ConditionalRouteWidget is used to showcase how to disable the AutoScale
      // behavior for a page.
      onGenerateRoute: (RouteSettings settings) {
        // A custom `fadeThrough` route transition animation.
        return Routes.noAnimation(
          settings: settings,
          builder: (context) {
            // Wrap widgets with another widget based on the route.
            // Wrap the page with the ResponsiveScaledBox for desired pages.
            return ConditionalRouteWidget(
              routesExcluded: const [
                TypographyPage.name,
              ], // Excluding a page from AutoScale.
              builder:
                  (context, child) => ResponsiveScaledBox(
                    // ResponsiveScaledBox renders its child with a FittedBox set to the `width` value.
                    // Set the fixed width value based on the active breakpoint.
                    width:
                        ResponsiveValue<double>(
                          context,
                          conditionalValues: [
                            const Condition.equals(name: MOBILE, value: 450),
                            const Condition.between(
                              start: 800,
                              end: 1100,
                              value: 800,
                            ),
                            Condition.between(
                              start: 1000,
                              end: double.maxFinite.toInt(),
                              value: 1000,
                            ),
                          ],
                        ).value,
                    child: child!,
                  ),
              child: BouncingScrollWrapper.builder(
                context,
                buildPage(settings.name ?? ''),
                dragWithMouse: true,
              ),
            );
          },
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }

  // onGenerateRoute route switcher.
  // Navigate using the page name, `Navigator.pushNamed(context, ListPage.name)`.
  Widget buildPage(String name) {
    switch (name) {
      case '/':
      case ListPage.name:
        return const ListPage();
      case '/post':
        return const PostPage();
      case TypographyPage.name:
        return const TypographyPage();
      default:
        return const SizedBox.shrink();
    }
  }
}
