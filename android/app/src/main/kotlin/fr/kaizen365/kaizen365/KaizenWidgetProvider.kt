package fr.kaizen365.kaizen365

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/** Home screen widget: year score, time elapsed and next check-in, written by the app through home_widget. */
class KaizenWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.kaizen_widget).apply {
                setTextViewText(R.id.widget_year, widgetData.getString("year", "Kaizen 365"))
                setTextViewText(R.id.widget_score, widgetData.getString("score", "–"))
                setTextViewText(R.id.widget_score_label, widgetData.getString("scoreLabel", ""))
                setTextViewText(R.id.widget_elapsed, widgetData.getString("elapsed", "–"))
                setTextViewText(R.id.widget_elapsed_label, widgetData.getString("elapsedLabel", ""))
                setTextViewText(R.id.widget_next, widgetData.getString("next", ""))
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
