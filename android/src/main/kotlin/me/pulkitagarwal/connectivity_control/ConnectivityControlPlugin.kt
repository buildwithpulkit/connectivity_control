package me.pulkitagarwal.connectivity_control

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import me.pulkitagarwal.connectivity_control.network.NetworkInformationMapper

class ConnectivityControlPlugin :
    FlutterPlugin,
    MethodCallHandler {
    private lateinit var channel: MethodChannel

    private lateinit var context: Context

    private lateinit var connectivityManager: ConnectivityManager

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "connectivity_control/methods")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if(call.method == "getActiveNetworks"){
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
        channel.setMethodCallHandler(null)
    }
}