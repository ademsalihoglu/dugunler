// =====================================================
// Gift Model - Takı Kaydı
// Enflasyon koruması için hem anlık hem güncel TL değeri
// =====================================================

import 'package:freezed_annotation/freezed_annotation.dart';

part 'gift_model.freezed.dart';
part 'gift_model.g.dart';

enum GiftSyncStatus { yerelBekliyor, senkronBekliyor, senkronize, hata }

@freezed
class GiftModel with _$GiftModel {
  const GiftModel._();

  const factory GiftModel({
    required String id,
    required String weddingId,
    String? guestId,
    required String giftTypeId,
    
    // Miktar bilgileri
    required double quantity,           // Kaç adet/gram
    required double unitValue,         // Birim değeri
    required double totalTry,           // Toplam TL (kaydedildiği andaki kur)
    
    // Güncel değer (enflasyon koruması)
    double? currentTry,              // Güncel kurlarla TL
    String? rateId,
    
    // Zaman
    required DateTime giftDate,
    required String giftTime,
    
    // Kayıt
    String? recordedBy,
    String? note,
    
    @Default(GiftSyncStatus.senkronize) GiftSyncStatus syncStatus,
    String? localId,
    String? deviceId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _GiftModel;

  factory GiftModel.fromJson(Map<String, dynamic> json) => _$GiftModelFromJson(json);

  //gift_type_id'den ikon almak için helper
  String get icon {
    // Bu genellikle gift_types tablosundan çekilecek
    if (giftTypeId.contains('GOLD')) return '💰';
    if (giftTypeId == 'USD') return '💵';
    if (giftTypeId == 'EUR') return '💶';
    return '₺';
  }
}

// Gift Type Model
@freezed
class GiftTypeModel with _$GiftTypeModel {
  const factory GiftTypeModel({
    required String id,
    required String name,
    required String code,
    required String unit,  // 'adet', 'gram', 'tl', 'dolar', 'euro'
    String? icon,
    @Default(0) int displayOrder,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _GiftTypeModel;

  factory GiftTypeModel.fromJson(Map<String, dynamic> json) => _$GiftTypeModelFromJson(json);
}

// Gift Statistics
@freezed
class GiftStats with _$GiftStats {
  const factory GiftStats({
    required double totalTry,
    required double currentTry,
    required int giftCount,
    required Map<String, double> breakdownByType,
  }) = _GiftStats;
}