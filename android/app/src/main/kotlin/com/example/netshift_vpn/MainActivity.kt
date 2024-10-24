package com.example.netshift_vpn


import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.NetworkInfo
import android.net.VpnService
import android.os.Bundle
import android.os.RemoteException
import android.provider.Settings
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.annotation.Nullable
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.multidex.MultiDex
import org.json.JSONObject
import java.io.IOException
import java.io.StringReader

import de.blinkt.openvpn.VpnProfile
import de.blinkt.openvpn.core.ConfigParser
import de.blinkt.openvpn.core.OpenVPNService
import de.blinkt.openvpn.core.OpenVPNThread
import de.blinkt.openvpn.core.ProfileManager
import de.blinkt.openvpn.core.VPNLaunchHelper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var vpnControlMethod: MethodChannel
    private lateinit var vpnControlEvent: EventChannel
    private lateinit var vpnStatusEvent: EventChannel
    private var vpnStageSink: EventChannel.EventSink? = null
    private var vpnStatusSink: EventChannel.EventSink? = null

    private val EVENT_CHANNEL_VPN_STAGE = "vpnStage"
    private val EVENT_CHANNEL_VPN_STATUS = "vpnStatus"
    private val METHOD_CHANNEL_VPN_CONTROL = "vpnControl"
    private val VPN_REQUEST_ID = 1
    private val TAG = "VPN"

    private var vpnProfile: VpnProfile? = null

    private var config = ""
    private var username = ""
    private var password = ""
    private var name = ""
    private var dns1 = VpnProfile.DEFAULT_DNS1
    private var dns2 = VpnProfile.DEFAULT_DNS2

    private var bypassPackages: ArrayList<String>? = null

    private var attached = true

    private var localJson: JSONObject? = null

    override fun finish() {
        vpnControlEvent.setStreamHandler(null)
        vpnControlMethod.setMethodCallHandler(null)
        vpnStatusEvent.setStreamHandler(null)
        super.finish()
    }

    override fun attachBaseContext(newBase: Context) {
        super.attachBaseContext(newBase)
        MultiDex.install(this)
    }

    override fun onDetachedFromWindow() {
        attached = false
        super.onDetachedFromWindow()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        LocalBroadcastManager.getInstance(this).registerReceiver(object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val stage = intent.getStringExtra("state")
                stage?.let { setStage(it) }

                vpnStatusSink?.let {
                    try {
                        var duration = intent.getStringExtra("duration")
                        var lastPacketReceive = intent.getStringExtra("lastPacketReceive")
                        var byteIn = intent.getStringExtra("byteIn")
                        var byteOut = intent.getStringExtra("byteOut")

                        if (duration == null) duration = "00:00:00"
                        if (lastPacketReceive == null) lastPacketReceive = "0"
                        if (byteIn == null) byteIn = " "
                        if (byteOut == null) byteOut = " "

                        val jsonObject = JSONObject()
                        jsonObject.put("duration", duration)
                        jsonObject.put("last_packet_receive", lastPacketReceive)
                        jsonObject.put("byte_in", byteIn)
                        jsonObject.put("byte_out", byteOut)

                        localJson = jsonObject

                        if (attached) it.success(jsonObject.toString())
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }
        }, IntentFilter("connectionState"))
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        vpnControlEvent = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL_VPN_STAGE)
        vpnControlEvent.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                vpnStageSink = events
            }

            override fun onCancel(arguments: Any?) {
                vpnStageSink?.endOfStream()
            }
        })

        vpnStatusEvent = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL_VPN_STATUS)
        vpnStatusEvent.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                vpnStatusSink = events
            }

            override fun onCancel(arguments: Any?) {}
        })

        vpnControlMethod = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_VPN_CONTROL)
        vpnControlMethod.setMethodCallHandler { call, result ->
            when (call.method) {
                "stop" -> {
                    OpenVPNThread.stop()
                    setStage("disconnected")
                }
                "start" -> {
                    config = call.argument("config") ?: ""
                    name = call.argument("country") ?: ""
                    username = call.argument("username") ?: ""
                    password = call.argument("password") ?: ""

                    call.argument<String>("dns1")?.let { dns1 = it }
                    call.argument<String>("dns2")?.let { dns2 = it }

                    bypassPackages = call.argument("bypass_packages")

                    if (config.isEmpty() || name.isEmpty()) {
                        Log.e(TAG, "Config not valid!")
                        return@setMethodCallHandler
                    }

                    prepareVPN()
                }
                "refresh" -> updateVPNStages()
                "refresh_status" -> updateVPNStatus()
                "stage" -> result.success(OpenVPNService.getStatus())
                "kill_switch" -> {
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                        val intent = Intent(Settings.ACTION_VPN_SETTINGS)
                        startActivity(intent)
                    }
                }
            }
        }
    }

    private fun prepareVPN() {
        if (isConnected()) {
            setStage("prepare")

            try {
                val configParser = ConfigParser()
                configParser.parseConfig(StringReader(config))
                vpnProfile = configParser.convertProfile()
            } catch (e: IOException) {
                e.printStackTrace()
            } catch (e: ConfigParser.ConfigParseError) {
                e.printStackTrace()
            }

            val vpnIntent = VpnService.prepare(this)
            if (vpnIntent != null) startActivityForResult(vpnIntent, VPN_REQUEST_ID)
            else startVPN()
        } else {
            setStage("nonetwork")
        }
    }

    private fun startVPN() {
        try {
            setStage("connecting")

            if (vpnProfile?.checkProfile(this) != de.blinkt.openvpn.R.string.no_error_found) {
                throw RemoteException(getString(vpnProfile?.checkProfile(this) ?: 0))
            }
            vpnProfile?.apply {
                mName = name
                mProfileCreator = packageName
                mUsername = username
                mPassword = password
                mDNS1 = dns1
                mDNS2 = dns2

                if (dns1.isNotEmpty() && dns2.isNotEmpty()) {
                    mOverrideDNS = true
                }

                bypassPackages?.let {
                    if (it.isNotEmpty()) {
                        mAllowedAppsVpn.addAll(it)
                        mAllowAppVpnBypass = true
                    }
                }
            }

            ProfileManager.setTemporaryProfile(this, vpnProfile)
            VPNLaunchHelper.startOpenVpn(vpnProfile, this)
        } catch (e: RemoteException) {
            setStage("disconnected")
            e.printStackTrace()
        }
    }

    private fun updateVPNStages() {
        setStage(OpenVPNService.getStatus())
    }

    private fun updateVPNStatus() {
        if (attached) vpnStatusSink?.success(localJson.toString())
    }

    private fun isConnected(): Boolean {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val nInfo: NetworkInfo? = cm.activeNetworkInfo

        return nInfo != null && nInfo.isConnectedOrConnecting
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == VPN_REQUEST_ID) {
            if (resultCode == RESULT_OK) {
                startVPN()
            } else {
                setStage("denied")
                Toast.makeText(this, "Permission is denied!", Toast.LENGTH_SHORT).show()
            }
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    private fun setStage(stage: String) {
        when (stage.uppercase()) {
            "CONNECTED" -> if (vpnStageSink != null && attached) vpnStageSink?.success("connected")
            "DISCONNECTED" -> if (vpnStageSink != null && attached) vpnStageSink?.success("disconnected")
            "WAIT" -> if (vpnStageSink != null && attached) vpnStageSink?.success("wait_connection")
            "AUTH" -> if (vpnStageSink != null && attached) vpnStageSink?.success("authenticating")
            "RECONNECTING" -> if (vpnStageSink != null && attached) vpnStageSink?.success("reconnect")
            "NONETWORK" -> if (vpnStageSink != null && attached) vpnStageSink?.success("no_connection")
            "CONNECTING" -> if (vpnStageSink != null && attached) vpnStageSink?.success("connecting")
            "PREPARE" -> if (vpnStageSink != null && attached) vpnStageSink?.success("prepare")
            "DENIED" -> if (vpnStageSink != null && attached) vpnStageSink?.success("denied")
        }
    }
}


