package app.muscale.muscale

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.content.res.ColorStateList
import android.content.res.Configuration
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.time.LocalDate
import java.util.Locale
import kotlin.math.abs
import kotlin.math.roundToInt

/**
 * Homescreen-Widget: Kalorien und Eiweiß von heute, Knopf zum Scanner.
 * Die App schreibt die Werte (siehe lib/services/home_widget_sync.dart); nach Mitternacht zeigt das Widget
 * von selbst einen leeren Tag, bis die App wieder geöffnet wird.
 */
class TodayWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val isToday = widgetData.getString("day", null) == LocalDate.now().toString()
        val kcalTarget = widgetData.getInt("kcal_target", 0)
        val proteinTarget = widgetData.getInt("protein_target", 0)
        val kcalEaten = if (isToday) widgetData.getInt("kcal_eaten", 0) else 0
        val proteinEaten = if (isToday) widgetData.getInt("protein_eaten", 0) else 0
        val night = (context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) ==
            Configuration.UI_MODE_NIGHT_YES
        val primary = widgetData.getInt(if (night) "primary_dark" else "primary_light", 0)

        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.today_widget)
            val left = kcalTarget - kcalEaten
            views.setTextViewText(R.id.widget_kcal_left, if (kcalTarget > 0) format(abs(left)) else "–")
            views.setTextViewText(
                R.id.widget_kcal_label,
                if (kcalTarget == 0) "Profil in der App anlegen" else if (left >= 0) "kcal übrig · Heute" else "kcal drüber · Heute",
            )
            views.setTextViewText(R.id.widget_kcal_value, "${format(kcalEaten)} / ${format(kcalTarget)} kcal")
            views.setTextViewText(R.id.widget_protein_value, "${format(proteinEaten)} / ${format(proteinTarget)} g")
            views.setProgressBar(R.id.widget_kcal_progress, 1000, permille(kcalEaten, kcalTarget), false)
            views.setProgressBar(R.id.widget_protein_progress, 1000, permille(proteinEaten, proteinTarget), false)

            // Farben der App übernehmen: Knopf über Farbfilter (alle Versionen), Balken ab Android 12.
            if (primary != 0) {
                views.setInt(R.id.widget_scan_circle, "setColorFilter", primary)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    views.setColorStateList(R.id.widget_kcal_progress, "setProgressTintList", ColorStateList.valueOf(primary))
                }
            }

            views.setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("muscale://today")),
            )
            views.setOnClickPendingIntent(
                R.id.widget_scan,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("muscale://scan")),
            )
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private fun format(value: Int) = String.format(Locale.GERMANY, "%,d", value)

    private fun permille(value: Int, target: Int) =
        if (target <= 0) 0 else (value * 1000.0 / target).roundToInt().coerceIn(0, 1000)
}
