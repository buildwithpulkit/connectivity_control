package me.pulkitagarwal.connectivity_control

import android.os.Build
import android.os.Looper
import android.os.Handler
import android.net.Network
import android.net.NetworkCapabilities
import android.net.ConnectivityManager
import io.flutter.plugin.common.EventChannel
import me.pulkitagarwal.connectivity_control.network.NetworkInformationMapper

class ActiveNetworkStreamHandler(
    private val connectivityManager: ConnectivityManager,
    private val getActiveNetworks: () -> List<Map<String, Any?>>,
    private val sdkInt: Int = Build.VERSION.SDK_INT,
    private val postToMain: (() -> Unit) -> Unit =
        Handler(Looper.getMainLooper()).let { handler -> { block -> handler.post(block) } }
) : EventChannel.StreamHandler  {

    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        // Tracks the app's default network, VPNs included. A NetworkRequest
        // would carry NOT_VPN by default and never match a VPN.
        networkCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                // On API 26+ onCapabilitiesChanged always follows onAvailable.
                if (sdkInt >= Build.VERSION_CODES.O) return
                val capabilities = connectivityManager.getNetworkCapabilities(network) ?: return
                emit(events, NetworkInformationMapper.map(capabilities))
            }

            override fun onLost(network: Network) {
                // The default callback only reports a loss when no other
                // network replaces it, so the device is offline.
                emit(events, emptyList())
            }

            override fun onCapabilitiesChanged(
                network: Network,
                networkCapabilities: NetworkCapabilities
            ) {
                emit(events, NetworkInformationMapper.map(networkCapabilities))
            }
        }

        // The callback stays silent when there is no default network, so
        // send the current state up front.
        emit(events, getActiveNetworks())

        connectivityManager.registerDefaultNetworkCallback(networkCallback!!)
    }

    private fun emit(events: EventChannel.EventSink, networks: List<Map<String, Any?>>) {
        postToMain {
            events.success(networks)
        }
    }

    override fun onCancel(arguments: Any?) {
        networkCallback?.let {
            connectivityManager.unregisterNetworkCallback(it)
        }
        networkCallback = null
    }
}
