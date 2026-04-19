// lib/presentation/promos/data/real_promos_repo.dart
import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../models/promo.dart';

class RealPromosRepo {
  static Future<List<Promo>> fetchActive() async {
    try {
      print('📦 Fetching promos from API...');
      final response = await dio.get('/promos');
      print('📦 Response status: ${response.statusCode}');
      
      final data = response.data as Map<String, dynamic>;
      print('📦 Full response: $data');
      
      // Check if data['data'] exists and is a list
      if (!data.containsKey('data')) {
        print('❌ No "data" field in response');
        return [];
      }
      
      final promosData = data['data'];
      if (promosData is! List) {
        print('❌ "data" is not a list, it\'s a ${promosData.runtimeType}');
        return [];
      }
      
      print('📦 Found ${promosData.length} promos in response');
      
      if (promosData.isEmpty) {
        print('⚠️ No promos found - check your database');
        return [];
      }
      
      return promosData.map((json) {
        print('📦 Processing promo: ${json['code']}');
        return Promo(
          id: (json['id'] as num).toString(),
          title: json['title'] as String,
          description: json['description'] as String? ?? '',
          type: json['type'] == 'percent' ? PromoType.percent : PromoType.fixed,
          amount: (json['value'] as num).toDouble(),
          code: json['code'] as String,
          validTo: json['validTo'] != null 
              ? DateTime.tryParse(json['validTo'] as String) 
              : null,
          minSubtotal: (json['minSubtotal'] as num?)?.toDouble() ?? 0,
        );
      }).toList();
    } catch (e, stacktrace) {
      debugPrint('❌ Error fetching promos: $e');
      debugPrint('❌ Stacktrace: $stacktrace');
      return [];
    }
  }
}