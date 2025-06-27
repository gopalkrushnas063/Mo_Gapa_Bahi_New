import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mogapabahi/features/notification/view/notification_screen.dart';
import 'package:mogapabahi/theme/app_font_family.dart';
import 'package:mogapabahi/theme/light_and_dark_theme.dart';
import 'package:mogapabahi/theme/provider/theme_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mogapabahi/data/model/story.dart';
import 'package:mogapabahi/features/content/controller/content.controller.dart';
import 'package:mogapabahi/features/introduction/view/introduction_page.dart';
import 'package:mogapabahi/features/story/view/story_details_view.dart';
import 'package:mogapabahi/utility/enum.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';

class ContentScreen extends ConsumerStatefulWidget {
  const ContentScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContentScreenState();
}

class _ContentScreenState extends ConsumerState<ContentScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // AdMob Variables
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;
  bool _isShowingAd = false;

  int _storyViewCount = 0;

  List<Color> colors = [
    Colors.orange,
    Colors.green,
    Colors.indigo,
    Colors.brown,
    Colors.red,
    Colors.blue,
    Colors.redAccent,
    Colors.lime,
    Colors.pink,
    Colors.blueGrey,
    const Color.fromARGB(255, 58, 162, 13),
  ];

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  // Load Banner Ad
  void _loadBannerAd() {
    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-3940256099942544/2934735716';

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          _isBannerAdReady = false;
        },
      ),
    )..load();
  }

  // Load Interstitial Ad
  void _loadInterstitialAd() {
    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/1033173712'
        : 'ca-app-pub-3940256099942544/4411468910';

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (err) {
          _isInterstitialAdReady = false;
          _loadInterstitialAd();
        },
      ),
    );
  }

  // Load Rewarded Ad
  void _loadRewardedAd() {
    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/5224354917'
        : 'ca-app-pub-3940256099942544/1712485313';

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
        },
        onAdFailedToLoad: (err) {
          _isRewardedAdReady = false;
          _loadRewardedAd();
        },
      ),
    );
  }

  // Show Rewarded Ad
  Future<void> _showRewardedAd() async {
    if (_isRewardedAdReady && !_isShowingAd) {
      setState(() => _isShowingAd = true);

      final completer = Completer();

      _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          completer.complete();
          ad.dispose();
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          completer.complete();
          ad.dispose();
          _loadRewardedAd();
        },
      );

      _rewardedAd?.show(
        onUserEarnedReward: (ad, reward) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You earned ${reward.amount} ${reward.type}!'),
            ),
          );
        },
      );

      await completer.future;
      setState(() => _isShowingAd = false);
    }
  }

  // Show Interstitial Ad
  void _showInterstitialAd() {
    if (_isInterstitialAdReady) {
      _interstitialAd?.show();
    }
  }

  Future<void> navigateToStoryDetails(StoryModel story) async {
    _storyViewCount++;

    // Show rewarded ad first
    await _showRewardedAd();

    // Show interstitial ad every 3 views
    if (_storyViewCount % 3 == 0 && _isInterstitialAdReady) {
      _showInterstitialAd();
    }

    // Navigate to story details
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StoryDetailsPage(story: story)),
      );
    }
  }

  Future<void> shareContent(BuildContext context) async {
    String text =
        "For more story go to playstore and download\ncom.krishnatechworld.mogapabahi";
    String imageUrl =
        "https://play-lh.googleusercontent.com/lm16K3Mf2KE8FlTrIaumQzk-UiWyiaTJjhr-jchx3MZSZjdv05i_-YRZNOvzKMPKCA=w240-h480-rw";

    if (imageUrl.startsWith('http')) {
      final response = await http.get(Uri.parse(imageUrl));
      final documentDirectory = await getApplicationDocumentsDirectory();
      final file = File('${documentDirectory.path}/image.png');
      await file.writeAsBytes(response.bodyBytes);
      await Share.shareXFiles([XFile(file.path)], text: text);
    } else {
      await Share.shareXFiles([XFile(imageUrl)], text: text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentState = ref.watch(contentControllerProvider);
    final theme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDarkMode = ref.watch(themeProvider) == darkTheme;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Center(
          child: Text(
            "ସୂଚୀପତ୍ର",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        backgroundColor: theme == darkTheme
            ? Color(0xFF585858)
            : const Color(0xFFDA8E0B),
        leading: IconButton(
          icon: const Icon(Icons.dashboard, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await shareContent(context);
            },
            icon: const Icon(Icons.share, color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.lock_open, color: Colors.white),
            onPressed: _isRewardedAdReady ? _showRewardedAd : null,
            tooltip: 'Watch ad to unlock premium content',
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25.0),
            bottomRight: Radius.circular(25.0),
          ),
        ),
      ),
      drawer: _buildDrawer(theme, themeNotifier, isDarkMode),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: contentState.status == APIState.loading
                    ? _buildShimmerEffect()
                    : contentState.status == APIState.failed
                    ? const Center(child: Text('Failed to load stories'))
                    : contentState.stories != null &&
                          contentState.stories!.isNotEmpty
                    ? ListView.builder(
                        itemCount: contentState.stories!.length,
                        itemBuilder: (context, index) {
                          final story = contentState.stories![index];
                          int colorIndex = index % colors.length;
                          Color containerColor = colors[colorIndex];

                          return GestureDetector(
                            onTap: () => navigateToStoryDetails(story),
                            child: Container(
                              decoration: BoxDecoration(
                                color: containerColor,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 10.0,
                              ),
                              child: _buildStoryCard(
                                story,
                                containerColor,
                                theme,
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(child: Text('No stories found')),
              ),
              if (_isBannerAdReady)
                Container(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
            ],
          ),
          if (_isShowingAd)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildDrawer(
    ThemeData theme,
    ThemeNotifier themeNotifier,
    bool isDarkMode,
  ) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: theme == darkTheme
            ? Color(0xFF585858)
            : Color(0xFFDA8E0B),
      ),
      child: Drawer(
        backgroundColor: theme == darkTheme ? Color(0xFF2A2A2A) : Colors.white,
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: theme == darkTheme
                    ? Color(0xFF585858)
                    : Color(0xFFDA8E0B),
              ),
              accountName: Center(
                child: Text(
                  "ମୋ ଗପ",
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.w600),
                ),
              ),
              accountEmail: Text(
                "“ମୋ ଗପ” ହେଉଛି କାହାଣୀ ଜଗତର ପ୍ରବେଶ ଦ୍ୱାର ଯାହ ବୟସ ପ୍ରତିବନ୍ଧକକୁ ଅତି\nକ୍ରମ କରି ମନୋରଞ୍ଜନ,ନୈତିକତା ଏବଂ ଜ୍ଞାନକୁ ଅନ୍ତର୍ଭୁକ୍ତ କରେ\n",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10),
              ),
            ),
            ListTile(
              iconColor: Colors.orange,
              title: const Text(
                "ମୋ ଗପ ବିଷୟରେ ସଂକ୍ଷିପ୍ତ (About Us)",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IntroductionPage(),
                  ),
                );
              },
              leading: const Icon(Icons.info_outline_rounded),
            ),
            ListTile(
              iconColor: Colors.orange,
              leading: const Icon(Icons.share),
              title: const Text(
                "ସେୟାର୍ ଆପ୍ (Share App)",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              onTap: () async {
                await shareContent(context);
              },
            ),
            ListTile(
              iconColor: Colors.orange,
              leading: const Icon(Icons.notifications_outlined),
              title: const Text(
                "ଘୋଷଣା (Notification)",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.contrast,
                        size: 20,
                        color: theme == darkTheme
                            ? const Color(0xFFDCDCDC)
                            : const Color(0xFF080808),
                      ),
                      const SizedBox(width: 13),
                      Text(
                        "Dark Mode",
                        style: TextStyle(
                          color: theme == darkTheme
                              ? const Color(0xFFDCDCDC)
                              : const Color(0xFF080808),
                          fontSize: 16,
                        ),
                        textAlign: null,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isDarkMode,
                  onChanged: (val) {
                    themeNotifier.toggleTheme();
                  },
                  activeTrackColor: const Color(0xFF276EF1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard(
    StoryModel story,
    Color containerColor,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(left: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme == darkTheme ? Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 10.0,
          ),
          leading: Container(
            padding: const EdgeInsets.only(right: 12.0),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 1.0, color: containerColor),
              ),
            ),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(containerColor, BlendMode.srcIn),
              child: Image.network(
                story.icon,
                width: 38,
                height: 38,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.error_outline,
                    color: containerColor,
                    size: 38,
                  );
                },
              ),
            ),
          ),
          title: Text(
            story.title,
            style: TextStyle(
              color: containerColor,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Row(
            children: <Widget>[
              Icon(Icons.linear_scale, color: containerColor),
              Text(
                story.type,
                style: TextStyle(
                  color: containerColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          trailing: Icon(Icons.fast_forward, color: containerColor, size: 30.0),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: const Color.fromARGB(255, 244, 226, 200),
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 10.0,
            ),
            child: Card(
              margin: const EdgeInsets.only(left: 8.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.only(right: 12.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 1.0, color: Colors.grey),
                      ),
                    ),
                    child: Container(
                      width: 38,
                      height: 38,
                      color: Colors.white,
                    ),
                  ),
                  title: Container(height: 20, color: Colors.white),
                  subtitle: Row(
                    children: <Widget>[
                      Container(width: 20, height: 20, color: Colors.white),
                      const SizedBox(width: 5),
                      Container(width: 100, height: 15, color: Colors.white),
                    ],
                  ),
                  trailing: Container(
                    width: 30,
                    height: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
