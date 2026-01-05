import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  // Simple in-memory translation for MVP
  // In a larger app, we would load JSON files.
  // Converted to getter to ensure Hot Reload picks up changes
  static Map<String, Map<String, String>> get _localizedValues => {
    'en': {
      'focus_time': 'Focus Time',
      'break_time': 'Break Time',
      'long_break': 'Long Break',
      'switch_to_focus': 'Switch to Focus',
      'switch_to_break': 'Switch to Break',
      'settings': 'Settings',
      'appearance': 'Appearance',
      'light': 'Light',
      'dark': 'Dark',
      'timer': 'Timer',
      'focus_duration': 'Focus Duration',
      'short_break': 'Short Break',
      'sessions_until_long': 'Sessions until Long Break',
      'sessions': 'sessions',
      'min': 'min',
      'automation': 'Automation',
      'auto_start_breaks': 'Auto-start Breaks',
      'auto_start_focus': 'Auto-start Focus',
      'save_changes': 'Save Changes',
      'settings_saved': 'Settings Saved',
      'productivity_stats': 'Productivity Stats',
      'weekly_focus': 'Weekly Focus',
      'last_7_days': 'Last 7 Days',
      'soundscapes': 'Soundscapes',
      'language': 'Language',
      'english': 'English',
      'arabic': 'Arabic',
      'streak': 'Streak',
      'xp': 'XP',
      'level': 'Level',
      'badges': 'Badges',
      'badge_first_step': 'First Step',
      'badge_desc_first_step': 'Complete your first focus session',
      'badge_on_fire': 'On Fire',
      'badge_desc_on_fire': 'Achieve a 3-day streak',
      'badge_dedicated': 'Dedicated',
      'badge_desc_dedicated': 'Complete 10 total sessions',
      'badge_master': 'Zen Master',
      'badge_desc_master': 'Reach Level 5',
      'badge_unlocked': 'New Badge Unlocked!',
      'congratulations': 'Congratulations!',
      'ritual_phrase': 'Breathe... Focus...',
      'micro_fail_title': 'Struggling to focus?',
      'micro_fail_body':
          'It happens. Do you want to continue for just 3 minutes?',
      'micro_fail_yes': 'Yes, 3 mins',
      'micro_fail_no': 'No, stop',
      'encouragement': 'Good job for trying today!',
      'onboarding_title_1': 'Master Your Focus',
      'onboarding_body_1':
          'Use the Pomodoro technique to achieve flow state and get more done.',
      'onboarding_title_2': 'Science-Backed Rituals',
      'onboarding_body_2':
          'Prime your brain for deep work with our exclusive breathing rituals.',
      'onboarding_title_3': 'Level Up Your Life',
      'onboarding_body_3':
          'Earn XP, unlock badges, and build a streak of unstoppable productivity.',
      'onboarding_done': 'Get Started',
      'onboarding_skip': 'Skip',
      'onboarding_next': 'Next',
    },
    'ar': {
      'focus_time': 'وقت التركيز',
      'break_time': 'وقت الراحة',
      'long_break': 'استراحة طويلة',
      'switch_to_focus': 'ابدأ التركيز',
      'switch_to_break': 'ابدأ الاستراحة',
      'settings': 'الإعدادات',
      'appearance': 'المظهر',
      'light': 'فاتح',
      'dark': 'داكن',
      'timer': 'المؤقت',
      'focus_duration': 'مدة التركيز',
      'short_break': 'استراحة قصيرة',
      'sessions_until_long': 'جلسات حتى الاستراحة الطويلة',
      'sessions': 'جلسات',
      'min': 'دقيقة',
      'automation': 'الأتمتة',
      'auto_start_breaks': 'بدء الاستراحة تلقائياً',
      'auto_start_focus': 'بدء التركيز تلقائياً',
      'save_changes': 'حفظ التغييرات',
      'settings_saved': 'تم حفظ الإعدادات',
      'productivity_stats': 'إحصائيات الإنتاجية',
      'weekly_focus': 'التركيز الأسبوعي',
      'last_7_days': 'آخر 7 أيام',
      'soundscapes': 'موسيقى الخلفية',
      'language': 'اللغة',
      'english': 'English',
      'arabic': 'العربية',
      'streak': 'تتابع',
      'xp': 'نقاط خبرة',
      'level': 'مستوى',
      'badges': 'الأوسمة',
      'badge_first_step': 'الخطوة الأولى',
      'badge_desc_first_step': 'أكمل جلسة تركيز واحدة',
      'badge_on_fire': 'مشعل الحماس',
      'badge_desc_on_fire': 'حقق تتابع لمدة 3 أيام',
      'badge_dedicated': 'مخلص',
      'badge_desc_dedicated': 'أكمل 10 جلسات إجمالاً',
      'badge_master': 'أستاذ الزن',
      'badge_desc_master': 'صل للمستوى 5',
      'badge_unlocked': 'تم فتح وسام جديد!',
      'congratulations': 'تهانينا!',
      'ritual_phrase': 'تنفس... ركّز...',
      'micro_fail_title': 'تواجه صعوبة في التركيز؟',
      'micro_fail_body': 'هذا طبيعي. هل تريد الاستمرار لمدة 3 دقائق فقط؟',
      'micro_fail_yes': 'نعم، 3 دقائق',
      'micro_fail_no': 'لا، توقف',
      'encouragement': 'أحسنت المحاولة اليوم!',
      'onboarding_title_1': 'أتقن تركيزك',
      'onboarding_body_1':
          'استخدم تقنية بومودورو للوصول إلى حالة التدفق وإنجاز المزيد.',
      'onboarding_title_2': 'طقوس مدعومة علمياً',
      'onboarding_body_2': 'هيئ عقلك للعمل العميق من خلال طقوس التنفس الحصرية.',
      'onboarding_title_3': 'ارتقِ بحياتك',
      'onboarding_body_3':
          'اكسب نقاط الخبرة، وافتح الأوسمة، وابنِ تتابعاً من الإنتاجية المذهلة.',
      'onboarding_done': 'ابدأ الآن',
      'onboarding_skip': 'تخطي',
      'onboarding_next': 'التالي',
    },
  };

  Future<bool> load() async {
    _localizedStrings =
        _localizedValues[locale.languageCode] ?? _localizedValues['en']!;
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
