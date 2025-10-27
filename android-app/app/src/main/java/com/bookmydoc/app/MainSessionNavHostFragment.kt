package com.bookmydoc.app

import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import dev.hotwire.turbo.config.TurboPathConfiguration
import dev.hotwire.turbo.session.TurboSessionNavHostFragment
import kotlin.reflect.KClass

class MainSessionNavHostFragment : TurboSessionNavHostFragment() {

    override val sessionName = "main"

    override val startLocation = MainActivity.BASE_URL

    override val registeredActivities: List<KClass<out AppCompatActivity>>
        get() = listOf(
            // Register any custom activities here
        )

    override val registeredFragments: List<KClass<out Fragment>>
        get() = listOf(
            WebFragment::class,
            // Register any custom fragments here
        )

    override val pathConfigurationLocation: TurboPathConfiguration.Location
        get() = TurboPathConfiguration.Location(
            assetFilePath = "json/configuration.json"
        )

    override fun onCreateView(
        inflater: android.view.LayoutInflater,
        container: android.view.ViewGroup?,
        savedInstanceState: Bundle?
    ): android.view.View? {
        Log.d("MainSessionNavHost", "onCreateView called")
        Log.d("MainSessionNavHost", "Start location: $startLocation")
        return super.onCreateView(inflater, container, savedInstanceState)
    }

    override fun onViewCreated(view: android.view.View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        Log.d("MainSessionNavHost", "onViewCreated called")
        Log.d("MainSessionNavHost", "Session name: $sessionName")
    }
}
