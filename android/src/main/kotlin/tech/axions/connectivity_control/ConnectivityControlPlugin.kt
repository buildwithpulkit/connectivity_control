package tech.axions.connectivity_control

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import tech.axions.connectivity_control.ActiveNetworkStreamHandler
import tech.axions.connectivity_control.network.NetworkInformationMapper


class ConnectivityControlPlugin :
    FlutterPlugin,
    MethodCallHandler {
    private lateinit var methodChannel: MethodChannel

    private lateinit var eventChannel: EventChannel

    private lateinit var context: Context

    private lateinit var connectivityManager: ConnectivityManager

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "connectivity_control/methods")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "connectivity_control/events")
        eventChannel.setStreamHandler(ActiveNetworkStreamHandler(
                connectivityManager = connectivityManager,
                getActiveNetworks = { getActiveNetworks() }
            )
        )
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        if(call.method == "getActiveNetworks"){
            val networks = getActiveNetworks()
            result.success(networks)
        } else {
            result.notImplemented()
        }
    }

    private fun getActiveNetworks() : List<Map<String, Any?>> {
        val network = connectivityManager.activeNetwork ?: return emptyList()

        val networkCapabilities = connectivityManager.getNetworkCapabilities(network) ?: return emptyList()

        return NetworkInformationMapper.map(networkCapabilities)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }
}