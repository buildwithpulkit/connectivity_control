package me.pulkitagarwal.connectivity_control.network

import android.net.NetworkCapabilities
import me.pulkitagarwal.connectivity_control.network.NetworkUtils

object NetworkInformationMapper {
    private val transports = listOf(
        NetworkCapabilities.TRANSPORT_WIFI to "wifi",
        NetworkCapabilities.TRANSPORT_VPN to "vpn",
        NetworkCapabilities.TRANSPORT_ETHERNET to "ethernet",
        NetworkCapabilities.TRANSPORT_CELLULAR to "cellular"
    )

    fun map(cap: NetworkCapabilities): List<Map<String, Any?>> {
        return transports
            .filter { cap.hasTransport(it.first) }
            .map { (_, type) -> buildNetworkMap(type, cap) }
    }

    private fun buildNetworkMap(
        type: String,
        cap: NetworkCapabilities
    ): Map<String, Any?> {
        return mapOf(
            "type" to type,
            "hasInternet" to NetworkUtils.hasInternet(cap),
            "isValidated" to NetworkUtils.isValidated(cap),
            "isMetered" to NetworkUtils.isMetered(cap),
            "downLinkKbps" to cap.linkDownstreamBandwidthKbps,
            "upLinkKbps" to cap.linkUpstreamBandwidthKbps
        )
    }
}