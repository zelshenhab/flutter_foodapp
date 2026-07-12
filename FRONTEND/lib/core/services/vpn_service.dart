// core/services/vpn_service.dart
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

class VpnService {
  static Future<bool> isVpnActive() async {
    try {
      // Check 1: Network interface names
      final interfaces = await NetworkInterface.list(
        includeLinkLocal: false,
        type: InternetAddressType.any,
      );

      // Common VPN interface names
      final vpnKeywords = [
        'tun', 'tap', 'utun', 'ppp', 'ipsec', 'wireguard',
        'openvpn', 'vpn', 'tunnel', 'ppp0', 'ppp1',
        'utun0', 'utun1', 'utun2', 'utun3',
      ];

      for (var iface in interfaces) {
        final name = iface.name.toLowerCase();
        for (var keyword in vpnKeywords) {
          if (name.contains(keyword)) {
            // Use debugPrint instead of print
            debugPrint('🔍 VPN detected: $name');
            return true;
          }
        }
      }

      // Check 2: Connectivity type
      final connectivityResult = await Connectivity().checkConnectivity();
      
      // ConnectivityResult is now a list in newer versions
      // Check if any connection type is VPN
      if (connectivityResult.contains(ConnectivityResult.vpn)) {
        debugPrint('🔍 VPN detected via connectivity');
        return true;
      }

    } catch (e) {
      debugPrint('⚠️ VPN detection error: $e');
    }

    return false;
  }

  // Check if we can reach Supabase
  static Future<bool> canReachSupabase() async {
    try {
      final result = await InternetAddress.lookup('nwaphgvmxtaalyxpgfdt.supabase.co')
          .timeout(const Duration(seconds: 5));
      
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      debugPrint('⚠️ Cannot reach Supabase: $e');
      return false;
    }
  }

  // Combined check: VPN or no internet
  static Future<Map<String, bool>> checkNetworkStatus() async {
    final isVpn = await isVpnActive();
    final canReach = await canReachSupabase();
    
    return {
      'isVpn': isVpn,
      'canReachSupabase': canReach,
      'needsVpn': !canReach || isVpn,
    };
  }
}