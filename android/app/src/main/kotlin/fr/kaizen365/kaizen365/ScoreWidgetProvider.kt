package fr.kaizen365.kaizen365

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/** Score widget (2×2): the year score as a ring, with the time elapsed. */
class ScoreWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val views = RemoteViews(context.packageName, R.layout.score_widget).apply {
            setProgressBar(R.id.score_ring, 100, widgetData.getInt("scorePercent", 0), false)
            setTextViewText(R.id.score_value, WidgetViews.text(widgetData, "score", "–"))
            setTextViewText(R.id.score_year, WidgetViews.text(widgetData, "year", "Kaizen 365"))
            setTextViewText(R.id.score_elapsed, WidgetViews.text(widgetData, "elapsedShort"))
            setOnClickPendingIntent(R.id.score_root, WidgetViews.openApp(context))
        }
        appWidgetIds.forEach { appWidgetManager.updateAppWidget(it, views) }
    }
}
