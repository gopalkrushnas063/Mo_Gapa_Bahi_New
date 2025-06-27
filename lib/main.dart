import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mogapabahi/features/content/view/content_screen.view.dart';
import 'package:mogapabahi/features/introduction/view/introduction_page.dart';
import 'package:mogapabahi/features/notification/view/notification_screen.dart';
import 'package:mogapabahi/features/story/view/story_details_view.dart';
import 'package:mogapabahi/services/onsignal_service.dart';
import 'package:mogapabahi/theme/light_and_dark_theme.dart';
import 'package:mogapabahi/theme/provider/theme_provider.dart';
import 'package:mogapabahi/welcome_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  OneSignalService.initializeOneSignal();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const WelcomeScreen();
      },
    ),
    GoRoute(
      path: '/intro',
      builder: (BuildContext context, GoRouterState state) {
        return const IntroductionPage();
      },
    ),
    // ContentScreen
    GoRoute(
      path: '/content',
      builder: (BuildContext context, GoRouterState state) {
        return const ContentScreen();
      },
    ),
    //StoryDetailsPage
    GoRoute(
      path: '/story',
      builder: (BuildContext context, GoRouterState state) {
        return StoryDetailsPage();
      },
    ),

    //StoryDetailsPage
    GoRoute(
      path: '/story',
      builder: (BuildContext context, GoRouterState state) {
        return const NotificationScreen();
      },
    ),
  ],
);

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize the theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeNotifier = ref.read(themeProvider.notifier);
      themeNotifier.loadTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(255, 218, 142, 11),
    ));

    // Lock orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set status bar color based on the theme
    SystemChrome.setSystemUIOverlayStyle(
      theme == darkTheme
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent, // or any dark color
              statusBarIconBrightness:
                  Brightness.light, // Light icons for dark theme
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent, // or any light color
              statusBarIconBrightness:
                  Brightness.dark, // Dark icons for light theme
            ),
    );

    OneSignalService.handleNotificationClick();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mo Gapa Bahi',
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: const Color.fromARGB(255, 218, 142, 11),
      //   ),
      //   useMaterial3: true,
      // ),
      home: const WelcomeScreen(),
      theme: lightTheme, // Light theme
      darkTheme: darkTheme, // Dark theme
      themeMode: theme == darkTheme
          ? ThemeMode.dark
          : ThemeMode.light, // Set the theme mode
      navigatorKey: navigatorKey,
    );
  }
}
