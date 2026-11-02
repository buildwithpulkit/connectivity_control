package me.pulkitagarwal.connectivity_control

import android.net.NetworkCapabilities
import me.pulkitagarwal.connectivity_control.network.NetworkInformationMapper
import org.mockito.Mockito
import kotlin.test.Test
import kotlin.test.assertEquals

internal class NetworkInformationMapperTest {
    private fun cellular(vararg capabilities: Int): NetworkCapabilities {
        val caps = Mockito.mock(NetworkCapabilities::class.java)
        Mockito.`when`(caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)).thenReturn(true)
        capabilities.forEach { Mockito.`when`(caps.hasCapability(it)).thenReturn(true) }
        return caps
    }

    @Test
    fun reportsTemporarilyUnmeteredNetworkAsStillMetered() {
        val network = NetworkInformationMapper.map(
            cellular(NetworkCapabilities.NET_CAPABILITY_TEMPORARILY_NOT_METERED)
        ).single()

        assertEquals(true, network["isMetered"])
        assertEquals(true, network["isTemporarilyUnmetered"])
    }

    @Test
    fun reportsMeteredNetworkAsNotTemporarilyUnmetered() {
        val network = NetworkInformationMapper.map(cellular()).single()

        assertEquals(true, network["isMetered"])
        assertEquals(false, network["isTemporarilyUnmetered"])
    }

    @Test
    fun reportsPermanentlyUnmeteredNetworkAsNotTemporarilyUnmetered() {
        val network = NetworkInformationMapper.map(
            cellular(NetworkCapabilities.NET_CAPABILITY_NOT_METERED)
        ).single()

        assertEquals(false, network["isMetered"])
        assertEquals(false, network["isTemporarilyUnmetered"])
    }
}
