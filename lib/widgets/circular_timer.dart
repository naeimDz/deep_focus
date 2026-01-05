import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../constants.dart';

class CircularTimer extends StatelessWidget {
  final double percent; // 0.0 to 1.0
  final String timeString; // "25:00"

  const CircularTimer({
    super.key,
    required this.percent,
    required this.timeString,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CircularPercentIndicator(
      radius: AppDimensions.timerRadius,
      lineWidth: 12.0,
      percent: percent.clamp(0.0, 1.0),
      center: Text(
        timeString,
        style: TextStyle(
          fontSize: 80.0,
          fontWeight: FontWeight.w200,
          color: colors.onSurface,
        ),
      ),
      progressColor: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animateFromLastPercent: true,
      animationDuration: 1000,
      widgetIndicator: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
