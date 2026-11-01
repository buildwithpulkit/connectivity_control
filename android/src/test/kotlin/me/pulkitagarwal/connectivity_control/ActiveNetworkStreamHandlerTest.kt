package me.pulkitagarwal.connectivity_control

import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import io.flutter.plugin.common.EventChannel
import org.mockito.ArgumentCaptor
import org.mockito.Mockito
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals

internal class ActiveNetworkStreamHandlerTest {
    private class RecordingSink : EventChannel.EventSink {
        val events = mutableListOf<Any?>()
        override fun success(event: Any?) { events.add(event) }
        override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {}
        override fun endOfStream() {}
    }

    private lateinit var connectivityManager: ConnectivityManager
    private lateinit var sink: RecordingSink
    private val network = Mockito.mock(Network::class.java)

    @BeforeTest
    fun setUp() {
        connectivityManager = Mockito.mock(ConnectivityManager::class.java)
        sink = RecordingSink()
    }

    private fun listen(sdkInt: Int = 36): ConnectivityManager.NetworkCallback {
        val handler = ActiveNetworkStreamHandler(
            connectivityManager = connectivityManager,
            getActiveNetworks = { emptyList() },
            sdkInt = sdkInt,
            postToMain = { it() }
        )
        handler.onListen(null, sink)
        val captor = ArgumentCaptor.forClass(ConnectivityManager.NetworkCallback::class.java)
        Mockito.verify(connectivityManager).registerDefaultNetworkCallback(captor.capture())
        return captor.value
    }

    private fun capabilities(vararg transports: Int): NetworkCapabilities {
        val caps = Mockito.mock(NetworkCapabilities::class.java)
        transports.forEach { Mockito.`when`(caps.hasTransport(it)).thenReturn(true) }
        return caps
    }

    private fun types(event: Any?): List<Any?> =
        (event as List<*>).map { (it as Map<*, *>)["type"] }

    @Test
    fun registersDefaultNetworkCallbackAndEmitsInitialState() {
        listen()

        Mockito.verify(connectivityManager, Mockito.never())
            .registerNetworkCallback(Mockito.any(), Mockito.any(ConnectivityManager.NetworkCallback::class.java))
        assertEquals(listOf<Any?>(emptyList<Any?>()), sink.events)
    }

    @Test
    fun emitsVpnFromCallbackCapabilities() {
        val callback = listen()

        callback.onCapabilitiesChanged(
            network,
            capabilities(NetworkCapabilities.TRANSPORT_WIFI, NetworkCapabilities.TRANSPORT_VPN)
        )

        assertEquals(listOf<Any?>("wifi", "vpn"), types(sink.events.last()))
        Mockito.verify(connectivityManager, Mockito.never()).getNetworkCapabilities(Mockito.any())
    }

    @Test
    fun emitsEmptyListWhenDefaultNetworkIsLost() {
        val callback = listen()
        callback.onCapabilitiesChanged(network, capabilities(NetworkCapabilities.TRANSPORT_VPN))

        callback.onLost(network)

        assertEquals(emptyList<Any?>(), sink.events.last())
    }

    @Test
    fun onAvailableDefersToCapabilitiesChangedOnApi26AndAbove() {
        val callback = listen(sdkInt = 26)

        callback.onAvailable(network)

        assertEquals(1, sink.events.size)
    }

    @Test
    fun onAvailableQueriesThatNetworkBelowApi26() {
        val cellular = capabilities(NetworkCapabilities.TRANSPORT_CELLULAR)
        Mockito.`when`(connectivityManager.getNetworkCapabilities(network)).thenReturn(cellular)
        val callback = listen(sdkInt = 25)

        callback.onAvailable(network)

        assertEquals(listOf<Any?>("cellular"), types(sink.events.last()))
    }
}
