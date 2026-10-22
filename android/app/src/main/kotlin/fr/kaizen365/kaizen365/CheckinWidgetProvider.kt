package fr.kaizen365.kaizen365

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/** Check-in widget (2×1): a shortcut straight to the check-in sheet. */
class CheckinWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val views = RemoteViews(context.packageName, R.layout.checkin_widget).apply {
            setTextViewText(R.id.checkin_label, WidgetViews.text(widgetData, "checkinLabel", "Check-in"))
            setTextViewText(R.id.checkin_next, WidgetViews.text(widgetData, "nextShort"))
            setOnClickPendingIntent(R.id.checkin_root, WidgetViews.openCheckin(context))
        }
        appWidgetIds.forEach { appWidgetManager.updateAppWidget(it, views) }
    }
}
