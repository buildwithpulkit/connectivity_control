package me.pulkitagarwal.connectivity_control.network 

import android.annotation.SuppressLint
import android.net.NetworkCapabilities

object NetworkUtils {
    fun hasInternet(capabilities: NetworkCapabilities): Boolean {
        return capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
    }

    fun isValidated(capabilities: NetworkCapabilities): Boolean {
        return capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
    }

    fun isMetered(capabilities: NetworkCapabilities): Boolean {
        return !capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED)
    }

    // Added in API 30, though some API 29 devices report it. Older
    // releases treat the unknown capability as absent.
    @SuppressLint("InlinedApi")
    fun isTemporarilyUnmetered(capabilities: NetworkCapabilities): Boolean {
        return capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_TEMPORARILY_NOT_METERED)
    }
}