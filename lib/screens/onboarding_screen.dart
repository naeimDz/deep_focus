import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../constants.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  Future<void> _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);

    if (context.mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  Widget _buildImage(IconData icon, Color color) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 100, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final textColor = isDark ? Colors.white : Colors.black;

    final pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 19.0,
        color: textColor.withValues(alpha: 0.8),
      ),
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: backgroundColor,
      imagePadding: EdgeInsets.only(top: 50, bottom: 20),
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: backgroundColor,
      allowImplicitScrolling: true,
      autoScrollDuration: 4000,
      infiniteAutoScroll: false,

      pages: [
        PageViewModel(
          title: loc.translate('onboarding_title_1'),
          body: loc.translate('onboarding_body_1'),
          image: _buildImage(Icons.timer_outlined, AppColors.primary),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: loc.translate('onboarding_title_2'),
          body: loc.translate('onboarding_body_2'),
          image: _buildImage(Icons.self_improvement, Colors.tealAccent),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: loc.translate('onboarding_title_3'),
          body: loc.translate('onboarding_body_3'),
          image: _buildImage(Icons.emoji_events_outlined, Colors.orangeAccent),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      back: const Icon(Icons.arrow_back),
      skip: Text(
        loc.translate('onboarding_skip'),
        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
      ),
      next: const Icon(Icons.arrow_forward, color: AppColors.primary),
      done: Text(
        loc.translate('onboarding_done'),
        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: textColor.withValues(alpha: 0.4),
        activeSize: const Size(22.0, 10.0),
        activeShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
        activeColor: AppColors.primary,
      ),
    );
  }
}
