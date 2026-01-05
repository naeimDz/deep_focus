import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'; // To access localeNotifier

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  int _longBreakMinutes = 15;
  int _longBreakInterval = 4;
  bool _autoStartBreak = false;
  bool _autoStartFocus = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _focusMinutes = prefs.getInt('focus_minutes') ?? 25;
      _breakMinutes = prefs.getInt('break_minutes') ?? 5;
      _longBreakMinutes = prefs.getInt('long_break_minutes') ?? 15;
      _longBreakInterval = prefs.getInt('long_break_interval') ?? 4;
      _autoStartBreak = prefs.getBool('auto_start_break') ?? false;
      _autoStartFocus = prefs.getBool('auto_start_focus') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('focus_minutes', _focusMinutes);
    await prefs.setInt('break_minutes', _breakMinutes);
    await prefs.setInt('long_break_minutes', _longBreakMinutes);
    await prefs.setInt('long_break_interval', _longBreakInterval);
    await prefs.setBool('auto_start_break', _autoStartBreak);
    await prefs.setBool('auto_start_focus', _autoStartFocus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('settings_saved'),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('settings'),
          style: TextStyle(color: colors.onBackground),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.onBackground),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Section
              _buildSectionHeader(
                AppLocalizations.of(context).translate('language'),
                colors.onBackground,
              ),
              const SizedBox(height: 10),
              _buildLanguageToggle(colors),
              const SizedBox(height: 30),

              // Appearance Section
              _buildSectionHeader(
                AppLocalizations.of(context).translate('appearance'),
                colors.onBackground,
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SwitchListTile(
                  title: Text(
                    isDark
                        ? AppLocalizations.of(context).translate('dark')
                        : AppLocalizations.of(context).translate('light'),
                    style: TextStyle(color: colors.onBackground),
                  ),
                  secondary: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: AppColors.primary,
                  ),
                  value: isDark,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    DeepFocusApp.themeNotifier.value = val
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  },
                ),
              ),

              const SizedBox(height: 30),

              // Timer Section
              _buildSectionHeader(
                AppLocalizations.of(context).translate('timer'),
                colors.onBackground,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildSliderSection(
                      title: AppLocalizations.of(
                        context,
                      ).translate('focus_duration'),
                      value: _focusMinutes,
                      min: 5,
                      max: 60,
                      colors: colors,
                      unit: AppLocalizations.of(context).translate('min'),
                      onChanged: (val) {
                        setState(() => _focusMinutes = val.toInt());
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSliderSection(
                      title: AppLocalizations.of(
                        context,
                      ).translate('short_break'),
                      value: _breakMinutes,
                      min: 1,
                      max: 15,
                      colors: colors,
                      unit: AppLocalizations.of(context).translate('min'),
                      onChanged: (val) =>
                          setState(() => _breakMinutes = val.toInt()),
                    ),
                    const SizedBox(height: 20),
                    _buildSliderSection(
                      title: AppLocalizations.of(
                        context,
                      ).translate('long_break'),
                      value: _longBreakMinutes,
                      min: 10,
                      max: 45,
                      colors: colors,
                      unit: AppLocalizations.of(context).translate('min'),
                      onChanged: (val) =>
                          setState(() => _longBreakMinutes = val.toInt()),
                    ),
                    const SizedBox(height: 20),
                    _buildSliderSection(
                      title: AppLocalizations.of(
                        context,
                      ).translate('sessions_until_long'),
                      value: _longBreakInterval,
                      min: 2,
                      max: 8,
                      colors: colors,
                      unit: AppLocalizations.of(context).translate('sessions'),
                      onChanged: (val) {
                        setState(() => _longBreakInterval = val.toInt());
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Automation Section
              _buildSectionHeader(
                AppLocalizations.of(context).translate('automation'),
                colors.onBackground,
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(
                          context,
                        ).translate('auto_start_breaks'),
                        style: TextStyle(color: colors.onBackground),
                      ),
                      value: _autoStartBreak,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => _autoStartBreak = val);
                      },
                    ),
                    Divider(
                      color: colors.onSurface.withOpacity(0.1),
                      height: 1,
                    ),
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(
                          context,
                        ).translate('auto_start_focus'),
                        style: TextStyle(color: colors.onBackground),
                      ),
                      value: _autoStartFocus,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => _autoStartFocus = val);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate('save_changes'),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(ColorScheme colors) {
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(Icons.language, color: AppColors.primary),
        title: Text(
          isArabic ? "العربية" : "English",
          style: TextStyle(color: colors.onBackground),
        ),
        trailing: Switch(
          value: isArabic,
          activeColor: AppColors.primary,
          onChanged: (val) {
            final newLocale = val ? const Locale('ar') : const Locale('en');
            DeepFocusApp.localeNotifier.value = newLocale;
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: color.withOpacity(0.6),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildSliderSection({
    required String title,
    required int value,
    required double min,
    required double max,
    required ColorScheme colors,
    required String unit,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(color: colors.onBackground, fontSize: 18),
            ),
            Text(
              "$value $unit",
              style: TextStyle(
                color: colors.onBackground.withOpacity(0.6),
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: colors.surface,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
