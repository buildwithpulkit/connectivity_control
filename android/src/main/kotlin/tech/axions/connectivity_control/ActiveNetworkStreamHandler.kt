package tech.axions.connectivity_control

import android.os.Looper
import android.os.Handler
import android.net.NetworkRequest
import android.net.NetworkCapabilities
import android.net.ConnectivityManager
import io.flutter.plugin.common.EventChannel

class ActiveNetworkStreamHandler(
    private val connectivityManager: ConnectivityManager,
    private val getActiveNetworks: () -> List<Map<String, Any?>>
) : EventChannel.StreamHandler  {

    private var networkCallback: ConnectivityManager.NetworkCallback? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        val networkRequest = NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build()

        networkCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: android.net.Network) {
                emit(events)
            }

            override fun onLost(network: android.net.Network) {
                emit(events)
            }

            override fun onCapabilitiesChanged(
                network: android.net.Network,
                networkCapabilities: NetworkCapabilities
            ) {
                emit(events)
            }

            override fun onLinkPropertiesChanged(
                network: android.net.Network,
                linkProperties: android.net.LinkProperties
            ) {
                emit(events)
            }
        }

        emit(events)

        connectivityManager.registerNetworkCallback(
            networkRequest,
            networkCallback!!
        )
    }

    private fun emit(events: EventChannel.EventSink) {
        mainHandler.post {
            events.success(getActiveNetworks())
        }
    }

    override fun onCancel(arguments: Any?) {
        networkCallback?.let {
            connectivityManager.unregisterNetworkCallback(it)
        }
        networkCallback = null
    }
}
