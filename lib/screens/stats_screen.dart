import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/stats_service.dart';
import '../services/gamification_service.dart'; // Added
import '../models/badge.dart' as model; // Added
import '../constants.dart';
import '../l10n/app_localizations.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final StatsService _statsService = StatsService();
  final GamificationService _gamificationService =
      GamificationService(); // Added
  Map<String, int> _weeklyStats = {};
  bool _isLoading = true;

  // Gamification State
  int _streak = 0;
  int _xp = 0;
  int _level = 1;
  List<model.Badge> _badges = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _statsService.getWeeklyStats();
    await _gamificationService.load(); // Load gamification data

    if (mounted) {
      setState(() {
        _weeklyStats = stats;
        _isLoading = false;
        // Update local state
        _streak = _gamificationService.streak;
        _xp = _gamificationService.xp;
        _level = _gamificationService.level;
        _badges = _gamificationService.badges;
      });
    }
  }

  int get _totalMinutes => _weeklyStats.values.fold(0, (sum, val) => sum + val);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).translate('productivity_stats'),
          style: TextStyle(color: colors.onBackground),
        ),
        iconTheme: IconThemeData(color: colors.onBackground),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(colors),
                  const SizedBox(height: 40),
                  Text(
                    AppLocalizations.of(context).translate('last_7_days'),
                    style: TextStyle(
                      color: colors.onBackground,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildGamificationSection(colors),
                  const SizedBox(height: 30),
                  Text(
                    AppLocalizations.of(context).translate('last_7_days'),
                    style: TextStyle(
                      color: colors.onBackground,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(height: 300, child: _buildChart(colors)),
                  const SizedBox(height: 40), // Extra bottom padding
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('weekly_focus'),
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "$_totalMinutes min",
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(ColorScheme colors) {
    if (_weeklyStats.isEmpty) return const SizedBox();

    int maxVal = _weeklyStats.values.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) maxVal = 60; // Default scale

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _weeklyStats.entries.map((entry) {
        final date = DateTime.parse(entry.key);
        final heightFactor = entry.value / maxVal;
        final isToday =
            DateFormat('yyyy-MM-dd').format(DateTime.now()) == entry.key;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "${entry.value}",
              style: TextStyle(
                color: colors.onBackground.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 30, // Fixed width bars
              height: 200 * heightFactor + 10, // Min height 10
              decoration: BoxDecoration(
                color: isToday ? AppColors.primary : colors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              DateFormat('E').format(date), // Mon, Tue
              style: TextStyle(
                color: isToday
                    ? AppColors.primary
                    : colors.onBackground.withOpacity(0.5),
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildGamificationSection(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Streak & Level Row
        Row(
          children: [
            Expanded(
              child: _buildStatBox(
                colors,
                AppLocalizations.of(context).translate('streak'),
                "$_streak🔥",
                Colors.orangeAccent,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildStatBox(
                colors,
                "${AppLocalizations.of(context).translate('level')} $_level",
                "$_xp ${AppLocalizations.of(context).translate('xp')}",
                AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),

        // Badges Section
        Text(
          AppLocalizations.of(context).translate('badges'),
          style: TextStyle(
            color: colors.onBackground,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns for better visibility
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 2.5, // Rectangular cards
          ),
          itemCount: _badges.length,
          itemBuilder: (context, index) {
            final badge = _badges[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(15),
                border: badge.isLocked
                    ? Border.all(color: colors.onSurface.withOpacity(0.1))
                    : Border.all(color: AppColors.primary.withOpacity(0.5)),
                boxShadow: badge.isLocked
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: badge.isLocked
                          ? Colors.grey.withOpacity(0.2)
                          : AppColors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      badge.icon,
                      color: badge.isLocked ? Colors.grey : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          ).translate(badge.translationKeyName),
                          style: TextStyle(
                            color: badge.isLocked
                                ? colors.onBackground.withOpacity(0.5)
                                : colors.onBackground,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).translate(badge.translationKeyDesc),
                          style: TextStyle(
                            color: colors.onBackground.withOpacity(0.5),
                            fontSize: 10,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatBox(
    ColorScheme colors,
    String title,
    String value,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: colors.onBackground.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
