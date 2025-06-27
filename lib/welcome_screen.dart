import 'dart:io'; // For Platform.isAndroid/IOS
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mogapabahi/features/introduction/view/introduction_page.dart';
import 'package:mogapabahi/theme/light_and_dark_theme.dart';
import 'package:mogapabahi/theme/provider/theme_provider.dart';
import 'package:package_info_plus/package_info_plus.dart'; // For app version

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  Future<void> _initDeviceAndAppInfo() async {
    try {
      // --- Device Info (Android/iOS) ---
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        debugPrint('--- ANDROID DEVICE INFO ---');
        debugPrint('Model: ${androidInfo.model}');
        debugPrint('Manufacturer: ${androidInfo.manufacturer}');
        debugPrint('Android OS: ${androidInfo.version.release}');
        debugPrint('minSdk: ${androidInfo.version.sdkInt}');
        debugPrint(
          'targetSdk: ${androidInfo.version.previewSdkInt} (may not be accurate)',
        );
        debugPrint('Security Patch: ${androidInfo.version.securityPatch}');
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        debugPrint('--- iOS DEVICE INFO ---');
        debugPrint('Model: ${iosInfo.utsname.machine}');
        debugPrint('iOS Version: ${iosInfo.systemVersion}');
      }

      // --- App Version Info ---
      final packageInfo = await PackageInfo.fromPlatform();
      debugPrint('--- APP VERSION INFO ---');
      debugPrint('App Name: ${packageInfo.appName}');
      debugPrint('Package: ${packageInfo.packageName}');
      debugPrint('versionName: ${packageInfo.version}');
      debugPrint('versionCode: ${packageInfo.buildNumber}');
    } catch (e) {
      debugPrint('Error fetching info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final isDarkMode = theme == darkTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/home_logo.png", width: 200),
              Text(
                "ମୋ ଗପ ବହି",
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? const Color(0xFFD0D0D0) : Colors.black,
                ),
              ),
              Column(
                children: [
                  Image.asset("assets/images/energi-energy.gif", width: 200),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset("assets/images/celebration.gif", width: 70),
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.141),
                        child: Image.asset(
                          "assets/images/celebration.gif",
                          width: 70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                "ଆସ ଆମେ ପଢିବା ଆମ ପିଲାଦିନ ଗପ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? const Color(0xFFD0D0D0) : Colors.black,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          _initDeviceAndAppInfo(); // Log device + app info
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const IntroductionPage()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF2a2a2a)
                  : const Color.fromARGB(255, 200, 132, 8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "ଆସନ୍ତୁ ଆଗକୁ ବଢ଼ିବା",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
