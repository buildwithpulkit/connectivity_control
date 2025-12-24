package me.pulkitagarwal.connectivity_control

import android.net.NetworkRequest
import android.net.NetworkCapabilities
import android.net.ConnectivityManager
import io.flutter.plugin.common.EventChannel

class ActiveNetworkStreamHandler(
    private val connectivityManager: ConnectivityManager,
    private val getActiveNetworks: () -> List<Map<String, Any?>>
) : EventChannel.StreamHandler  {

    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        val networkRequest = NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build()

        networkCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: android.net.Network) {
                events.success(getActiveNetworks())
            }

            override fun onLost(network: android.net.Network) {
                events.success(getActiveNetworks())
            }

            override fun onCapabilitiesChanged(
                network: android.net.Network,
                networkCapabilities: NetworkCapabilities
            ) {
                events.success(getActiveNetworks())
            }

            override fun onLinkPropertiesChanged(
                network: android.net.Network,
                linkProperties: android.net.LinkProperties
            ) {
                events.success(getActiveNetworks())
            }
        }

        events.success(getActiveNetworks())

        connectivityManager.registerNetworkCallback(
            networkRequest,
            networkCallback!!
        )
    }

    override fun onCancel(arguments: Any?) {
        networkCallback?.let {
            connectivityManager.unregisterNetworkCallback(it)
        }
        networkCallback = null
    }
}
