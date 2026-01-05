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
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
