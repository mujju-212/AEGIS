package com.privacyai.privacy_ai

import android.app.ActivityManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val channel = "privacy_ai/device"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"getTotalRam" -> result.success(getTotalRamBytes())
					else -> result.notImplemented()
				}
			}
	}

	private fun getTotalRamBytes(): Long {
		val manager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
		val info = ActivityManager.MemoryInfo()
		manager.getMemoryInfo(info)
		return info.totalMem
	}
}
