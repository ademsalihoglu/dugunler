// =====================================================
// Wedding Guest Model
// =====================================================

import 'package:freezed_annotation/freezed_annotation.dart';

part 'guest_model.freezed.dart';
part 'guest_model.g.dart';

enum InvitationStatus { bekliyor, davetEdildi, katilacak, katilmayacak }

@freezed
class GuestModel with _$GuestModel {
  const factory GuestModel({
    required String id,
    required String weddingId,
    String? userId,  // Sistemde kayıtlıysa
    required String guestName,
    String? guestPhone,
    String? guestEmail,
    String? relationship,      // 'akraba', 'arkadaş', 'iş', 'komşu'
    String? relationDetail,   // 'amcaoğlu', 'iş arkadaşı'
    @Default(InvitationStatus.bekliyor) InvitationStatus invitationStatus,
    bool? willAttend,
    @Default(1) int partySize,
    String? dietaryNotes,
    String? address,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _GuestModel;

  factory GuestModel.fromJson(Map<String, dynamic> json) => _$GuestModelFromJson(json);
}

// Geri Dönüş (Return Visit) - Kimin düğününe gitmişiz
@freezed
class ReturnVisitModel with _$ReturnVisitModel {
  const factory ReturnVisitModel({
    required String id,
    required String userId,
    String? weddingId,
    String? weddingOwnerId,
    String? giftTypeId,
    double? giftQuantity,
    double? giftTry,
    String? giftNote,
    DateTime? createdAt,
  }) = _ReturnVisitModel;

  factory ReturnVisitModel.fromJson(Map<String, dynamic> json) => _$ReturnVisitModelFromJson(json);
}