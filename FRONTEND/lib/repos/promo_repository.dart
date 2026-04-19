// import 'package:dio/dio.dart';
// import 'package:flutter_foodapp/presentation/promos/models/promo.dart';

// import '../core/api_client.dart';

// class PromoRepository {
//   // Fetch all active promos from backend
//   Future<List<Promo>> fetchActivePromos() async {
//     try {
//       final response = await dio.get('/promo');
//       final data = response.data as Map<String, dynamic>;
//       final List<dynamic> promosData = data['data'] ?? [];
      
//       return promosData.map((json) => Promo.fromJson(json)).toList();
//     } catch (e) {
//       print('Error fetching promos: $e');
//       return [];
//     }
//   }

//   // Validate a promo code
//   Future<PromoValidationResult> validatePromoCode(String code, double subtotal) async {
//     try {
//       final response = await dio.post(
//         '/promo/validate',
//         data: {
//           'code': code,
//           'subtotal': subtotal,
//         },
//       );
      
//       final data = response.data as Map<String, dynamic>;
//       return PromoValidationResult.fromJson(data);
//     } catch (e) {
//       if (e is DioException && e.response?.statusCode == 404) {
//         return PromoValidationResult(
//           valid: false,
//           message: 'Invalid promo code',
//         );
//       }
//       return PromoValidationResult(
//         valid: false,
//         message: 'Failed to validate promo code',
//       );
//     }
//   }

//   // Apply promo and get discount
//   Future<PromoApplicationResult> applyPromoCode(String code, double subtotal) async {
//     try {
//       final response = await dio.post(
//         '/promo/apply',
//         data: {
//           'code': code,
//           'subtotal': subtotal,
//         },
//       );
      
//       final data = response.data as Map<String, dynamic>;
//       return PromoApplicationResult.fromJson(data);
//     } catch (e) {
//       throw Exception('Failed to apply promo code');
//     }
//   }
// }

// // Result models
// class PromoValidationResult {
//   final bool valid;
//   final String? message;
//   final Map<String, dynamic>? promo;

//   PromoValidationResult({
//     required this.valid,
//     this.message,
//     this.promo,
//   });

//   factory PromoValidationResult.fromJson(Map<String, dynamic> json) {
//     return PromoValidationResult(
//       valid: json['valid'] ?? false,
//       message: json['message'],
//       promo: json['promo'],
//     );
//   }
// }

// class PromoApplicationResult {
//   final bool valid;
//   final double discount;
//   final double discountedTotal;
//   final Map<String, dynamic>? promo;

//   PromoApplicationResult({
//     required this.valid,
//     required this.discount,
//     required this.discountedTotal,
//     this.promo,
//   });

//   factory PromoApplicationResult.fromJson(Map<String, dynamic> json) {
//     return PromoApplicationResult(
//       valid: json['valid'] ?? false,
//       discount: (json['discount'] ?? 0).toDouble(),
//       discountedTotal: (json['discountedTotal'] ?? 0).toDouble(),
//       promo: json['promo'],
//     );
//   }
// }