package fr.kaizen365.kaizen365

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/** Overview widget (4×2): year score, time elapsed and next check-in. */
class KaizenWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val views = RemoteViews(context.packageName, R.layout.kaizen_widget).apply {
            setTextViewText(R.id.widget_year, WidgetViews.text(widgetData, "year", "Kaizen 365"))
            setTextViewText(R.id.widget_score, WidgetViews.text(widgetData, "score", "–"))
            setTextViewText(R.id.widget_score_label, WidgetViews.text(widgetData, "scoreLabel"))
            setTextViewText(R.id.widget_elapsed, WidgetViews.text(widgetData, "elapsed", "–"))
            setTextViewText(R.id.widget_elapsed_label, WidgetViews.text(widgetData, "elapsedLabel"))
            setTextViewText(R.id.widget_next, WidgetViews.text(widgetData, "next"))
            setOnClickPendingIntent(R.id.widget_root, WidgetViews.openApp(context))
        }
        appWidgetIds.forEach { appWidgetManager.updateAppWidget(it, views) }
    }
}
