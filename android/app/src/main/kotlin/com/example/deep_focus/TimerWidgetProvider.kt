package com.example.deep_focus

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class TimerWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Get data from SharedPreferences (synced by HomeWidget)
                val percent = widgetData.getInt("timer_percent", 0)
                val timeText = widgetData.getString("timer_text", "--:--")
                val isRunning = widgetData.getBoolean("timer_status", false)

                // Update Views
                setTextViewText(R.id.widget_timer_text, timeText)
                setProgressBar(R.id.widget_progress, 100, percent, false)
                
                // Optional: Change status text color or text based on isRunning
                setTextViewText(R.id.widget_status_text, if (isRunning) "FOCUSING" else "PAUSED")

                // Intent to launch app on click
                val intent = android.content.Intent(context, MainActivity::class.java).apply {
                    action = android.content.Intent.ACTION_MAIN
                    addCategory(android.content.Intent.CATEGORY_LAUNCHER)
                    flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK or android.content.Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
                }
                val pendingIntent = android.app.PendingIntent.getActivity(
                    context, 
                    0, 
                    intent, 
                    android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent) // Clicking background opens app
                // Also add to frame layout just in case
                setOnClickPendingIntent(R.id.widget_progress, pendingIntent) 
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
