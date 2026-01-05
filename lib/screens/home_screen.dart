import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Assuming AudioPlayer needs this
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../l10n/app_localizations.dart'; // Added
import '../services/timer_service.dart';
import '../services/stats_service.dart';
import '../services/sound_service.dart';
import '../widgets/circular_timer.dart';
import 'settings_screen.dart';
import 'stats_screen.dart'; // Added
import '../services/gamification_service.dart';
import '../services/remote_config_service.dart'; // Added
import '../models/badge.dart' as model;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TimerService _timerService = TimerService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final StatsService _statsService = StatsService();
  final SoundService _soundService =
      SoundService(); // Added // Add StatsService
  final GamificationService _gamificationService = GamificationService();

  double _progress = 1.0;
  bool _isBreak = false;

  // Settings
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  int _longBreakMinutes = 15;
  int _longBreakInterval = 4;
  bool _autoStartBreak = false;
  bool _autoStartFocus = false;

  // State
  int _pomodorosCompleted = 0;
  bool _controlsVisible = true;

  // Ritual State
  bool _isRitualActive = false;
  late AnimationController _ritualController;
  late Animation<double> _ritualAnimation;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _gamificationService.load();

    // Ritual Animation
    _ritualController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Match ritual duration
    )..repeat(reverse: true); // Breathing effect
    _ritualAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _ritualController, curve: Curves.easeInOut),
    );

    // Setup Timer Callbacks
    _timerService.onTick = (progress) {
      if (mounted) {
        setState(() {
          _progress = progress;
        });
      }
    };

    _timerService.onFinished = () {
      _playAlarm();
      if (mounted) {
        _handleTimerFinish();
      }
    };
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
    // Initialize timer with current settings if not running
    if (!_timerService.isRunning) {
      _timerService.setDuration(_focusMinutes * 60);
      _timerService.resetTimer();
    }
  }

  void _handleTimerFinish() {
    if (!_isBreak) {
      // Finished Focus Session
      _statsService.addMinutes(_focusMinutes); // Record Stats
      _processGamification();

      setState(() {
        _pomodorosCompleted++;
      });

      bool isLongBreak =
          _pomodorosCompleted > 0 &&
          (_pomodorosCompleted % _longBreakInterval == 0);
      int breakDuration = isLongBreak ? _longBreakMinutes : _breakMinutes;

      setState(() {
        _isBreak = true;
        _progress = 1.0;
        _timerService.setDuration(breakDuration * 60);
        _timerService.resetTimer();
      });

      if (_autoStartBreak) {
        _timerService.startTimer();
      }
    } else {
      // Finished Break
      setState(() {
        _isBreak = false;
        _progress = 1.0;
        _timerService.setDuration(_focusMinutes * 60);
        _timerService.resetTimer();
      });

      if (_autoStartFocus) {
        _timerService.startTimer();
      }
    }
  }

  void _toggleTimer() {
    if (_timerService.isRunning) {
      _timerService.pauseTimer();
      setState(() {
        _controlsVisible = true; // Show controls on pause
      });
    } else {
      // Start Ritual
      if (!_isBreak) {
        _startRitual();
      } else {
        _startTimerLogic();
      }
    }
  }

  void _startRitual() {
    setState(() {
      _isRitualActive = true;
      _controlsVisible = false;
    });
    // Play sound if possible (omitted for now)

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isRitualActive = false;
        });
        _startTimerLogic();
      }
    });
  }

  void _startTimerLogic() {
    _timerService.startTimer();
    // Auto-hide controls in 2 seconds for Zen Mode effect
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _timerService.isRunning) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
    setState(() {});
  }

  void _resetTimer() {
    // Micro-Failure Interception
    // Show dialog if session has started (remaining < total) AND it's a focus session
    // This allows interception even if paused.
    bool hasStarted =
        _timerService.remainingTime < _timerService.currentDuration;
    if (hasStarted && !_isBreak) {
      _timerService.pauseTimer();
      setState(() => _controlsVisible = true);
      _showMicroFailureDialog();
    } else {
      _performReset();
    }
  }

  void _performReset() {
    _timerService.resetTimer();
    setState(() {
      _progress = 1.0;
    });
  }

  void _switchMode() {
    _timerService.stopTimer();
    setState(() {
      _isBreak = !_isBreak;
      // If manually switching to break, assumes short break unless we want to be smart?
      // Let's just default to short for manual switch to keep it simple.
      int minutes = _isBreak ? _breakMinutes : _focusMinutes;
      _timerService.setDuration(minutes * 60);
      _resetTimer();
    });
  }

  Future<void> _playAlarm() async {
    debugPrint("ALARM RANG!");
    // Placeholder for actual sound
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );

    if (result == true) {
      _loadSettings();
    }
  }

  String get _timerString {
    int totalSeconds = _timerService.remainingTime;
    int m = totalSeconds ~/ 60;
    int s = totalSeconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timerService.dispose();
    _audioPlayer.dispose();
    _ritualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow gradient to go behind app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          RemoteConfigService().getString(AppConfig.welcomeMessage),
          style: TextStyle(color: colors.onBackground),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.music_note_rounded,
              color: colors.onSurface.withOpacity(0.7),
            ),
            onPressed: _showSoundSelector,
          ),
          IconButton(
            icon: Icon(
              Icons.bar_chart_rounded,
              color: colors.onSurface.withOpacity(0.7),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: colors.onSurface.withOpacity(0.7),
            ),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkBackgroundGradient
              : AppColors.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        _controlsVisible = !_controlsVisible;
                      });
                    },
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),

                            // Controls Wrapper
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: _controlsVisible ? 1.0 : 0.0,
                              child: IgnorePointer(
                                ignoring: !_controlsVisible,
                                child: Column(
                                  children: [
                                    // Mode Switcher
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.surface.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: colors.onSurface.withOpacity(
                                            0.1,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        _getModeLabel(),
                                        style: TextStyle(
                                          color: colors.onBackground,
                                          fontSize: 16,
                                          letterSpacing: 1.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Timer (Always Visible)
                            CircularTimer(
                              percent: _progress,
                              timeString: _timerString,
                            ),

                            const SizedBox(height: 40),

                            // Bottom Controls Wrapper
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: _controlsVisible ? 1.0 : 0.0,
                              child: IgnorePointer(
                                ignoring: !_controlsVisible,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Play/Pause Button
                                        GestureDetector(
                                          onTap: _toggleTimer,
                                          child: Container(
                                            height: 80,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              gradient:
                                                  AppColors.primaryGradient,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.primary
                                                      .withOpacity(0.4),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 10),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              _timerService.isRunning
                                                  ? Icons.pause_rounded
                                                  : Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 30),

                                        // Stop Button
                                        IconButton(
                                          iconSize: 40,
                                          icon: Icon(
                                            Icons.stop_circle_outlined,
                                            color: colors.onSurface.withOpacity(
                                              0.5,
                                            ),
                                          ),
                                          onPressed: _resetTimer,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    TextButton(
                                      onPressed: _switchMode,
                                      style: TextButton.styleFrom(
                                        foregroundColor: colors.onSurface
                                            .withOpacity(0.7),
                                      ),
                                      child: Text(
                                        _isBreak
                                            ? AppLocalizations.of(
                                                context,
                                              ).translate('switch_to_focus')
                                            : AppLocalizations.of(
                                                context,
                                              ).translate('switch_to_break'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Ritual Overlay
                  if (_isRitualActive) _buildRitualOverlay(colors),
                ],
              ); // End Stack (was LayoutBuilder child)
            },
          ),
        ),
      ),
    );
  }

  String _getModeLabel() {
    if (!_isBreak) return AppLocalizations.of(context).translate('focus_time');
    if (_timerService.currentDuration == _longBreakMinutes * 60)
      return AppLocalizations.of(context).translate('long_break');
    return AppLocalizations.of(context).translate('break_time');
  }

  void _showSoundSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).translate('soundscapes'),
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ..._soundService.sounds.keys.map((sound) {
                // Determine if selected
                final isSelected =
                    _soundService.currentSound == sound ||
                    (sound == 'None' &&
                        (_soundService.currentSound == null ||
                            _soundService.currentSound == ''));

                return ListTile(
                  leading: Icon(
                    sound == 'None' ? Icons.volume_off : Icons.music_note,
                    color: isSelected ? AppColors.primary : colors.onSurface,
                  ),
                  title: Text(
                    sound,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : colors.onBackground,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    _soundService.playSound(sound);
                    Navigator.pop(context);
                    setState(() {}); // Update UI if needed
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processGamification() async {
    final newBadges = await _gamificationService.processSession(_focusMinutes);
    if (newBadges.isNotEmpty && mounted) {
      _showBadgeDialog(newBadges);
    }
  }

  void _showBadgeDialog(List<model.Badge> newBadges) {
    showDialog(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            AppLocalizations.of(context).translate('congratulations'),
            style: TextStyle(color: colors.onBackground),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).translate('badge_unlocked'),
                style: TextStyle(color: colors.onBackground),
              ),
              const SizedBox(height: 20),
              ...newBadges.map(
                (badge) => ListTile(
                  leading: Icon(badge.icon, color: AppColors.primary, size: 40),
                  title: Text(
                    AppLocalizations.of(
                      context,
                    ).translate(badge.translationKeyName),
                    style: TextStyle(
                      color: colors.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    AppLocalizations.of(
                      context,
                    ).translate(badge.translationKeyDesc),
                    style: TextStyle(
                      color: colors.onBackground.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showMicroFailureDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            AppLocalizations.of(context).translate('micro_fail_title'),
            style: TextStyle(color: colors.onBackground),
          ),
          content: Text(
            AppLocalizations.of(context).translate('micro_fail_body'),
            style: TextStyle(color: colors.onBackground),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performReset();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).translate('encouragement'),
                    ),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: Text(
                AppLocalizations.of(context).translate('micro_fail_no'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _timerService.setDuration(3 * 60); // 3 minutes
                _startTimerLogic();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                AppLocalizations.of(context).translate('micro_fail_yes'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRitualOverlay(ColorScheme colors) {
    return Container(
      color: colors.background, // Full screen opaque
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _ritualAnimation,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 50,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.self_improvement,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              AppLocalizations.of(context).translate('ritual_phrase'),
              style: TextStyle(
                color: colors.onBackground,
                fontSize: 24,
                fontWeight: FontWeight.w300,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
