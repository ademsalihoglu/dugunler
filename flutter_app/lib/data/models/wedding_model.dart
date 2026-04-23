// =====================================================
// Wedding Model - Freezed
// =====================================================

import 'package:freezed_annotation/freezed_annotation.dart';

part 'wedding_model.freezed.dart';
part 'wedding_model.g.dart';

enum WeddingStatus { planlandi, aktif, tamamlandi, iptal }

@freezed
class WeddingModel with _$WeddingModel {
  const WeddingModel._();

  const factory WeddingModel({
    required String id,
    required String ownerId,
    required String brideName,
    required String groomName,
    required DateTime weddingDate,
    required String weddingTime,
    String? venueName,
    String? venueAddress,
    double? venueLatitude,
    double? venueLongitude,
    String? region,
    String? city,
    String? description,
    String? coverImageUrl,
    @Default(WeddingStatus.planlandi) WeddingStatus status,
    @Default(0) int guestCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _WeddingModel;

  factory WeddingModel.fromJson(Map<String, dynamic> json) => _$WeddingModelFromJson(json);

  String get coupleName => '$brideName & $groomName';
  
  String get formattedDate {
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${weddingDate.day} ${months[weddingDate.month - 1]} ${weddingDate.year}';
  }
  
  bool get isUpcoming => weddingDate.isAfter(DateTime.now());
  
  int get daysUntilWedding => weddingDate.difference(DateTime.now()).inDays;
}