// =====================================================
// Advertiser & Ad Models - Reklam Modülü
// =====================================================

import 'package:freezed_annotation/freezed_annotation.dart';

part 'advertiser_model.freezed.dart';
part 'advertiser_model.g.dart';

enum AdStatus { bekliyor, aktif, pasif, reddedildi }

@freezed
class AdvertiserModel with _$AdvertiserModel {
  const factory AdvertiserModel({
    required String id,
    required String ownerUserId,
    required String businessName,
    required String category,
    String? subCategory,
    String? description,
    String? logoUrl,
    String? coverImageUrl,
    String? websiteUrl,
    String? phone,
    String? email,
    @Default(AdStatus.bekliyor) AdStatus status,
    @Default(0.0) double balance,
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    DateTime? createdAt,
    DateTime? verifiedAt,
  }) = _AdvertiserModel;

  factory AdvertiserModel.fromJson(Map<String, dynamic> json) => _$AdvertiserModelFromJson(json);
}

@freezed
class AdvertiserLocationModel with _$AdvertiserLocationModel {
  const factory AdvertiserLocationModel({
    required String id,
    required String advertiserId,
    String? locationName,
    String? address,
    double? latitude,
    double? longitude,
    String? region,
    String? city,
    String? district,
    String? phone,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _AdvertiserLocationModel;

  factory AdvertiserLocationModel.fromJson(Map<String, dynamic> json) => _$AdvertiserLocationModelFromJson(json);
}

@freezed
class AdCampaignModel with _$AdCampaignModel {
  const factory AdCampaignModel({
    required String id,
    required String advertiserId,
    required String name,
    required String category,
    String? title,
    String? description,
    String? imageUrl,
    String? ctaText,
    String? ctaLink,
    List<String>? targetRegions,
    List<String>? targetCities,
    DateTime? startDate,
    DateTime? endDate,
    double? dailyBudget,
    double? totalBudget,
    @Default(0.50) double costPerClick,
    @Default(0.01) double costPerView,
    @Default(AdStatus.bekliyor) AdStatus status,
    @Default(0) int impressionsCount,
    @Default(0) int clicksCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AdCampaignModel;

  factory AdCampaignModel.fromJson(Map<String, dynamic> json) => _$AdCampaignModelFromJson(json);
}

@freezed
class AdPlacementModel with _$AdPlacementModel {
  const factory AdPlacementModel({
    required String id,
    required String name,
    String? description,
    @Default(320) int width,
    @Default(100) int height,
    required String format,  // 'banner', 'interstitial', 'native'
    @Default(true) bool isActive,
    @Default(0.01) double minBid,
  }) = _AdPlacementModel;

  factory AdPlacementModel.fromJson(Map<String, dynamic> json) => _$AdPlacementModelFromJson(json);
}

@freezed
class AdImpressionModel with _$AdImpressionModel {
  const factory AdImpressionModel({
    required String id,
    String? campaignId,
    required String placementId,
    String? userId,
    String? weddingId,
    @Default(1) int impressionCount,
    @Default(false) bool isClicked,
    Map<String, dynamic>? deviceInfo,
    String? userRegion,
    DateTime? shownAt,
  }) = _AdImpressionModel;

  factory AdImpressionModel.fromJson(Map<String, dynamic> json) => _$AdImpressionModelFromJson(json);
}

// Return from ad request
@freezed
class AdResponse with _$AdResponse {
  const factory AdResponse({
    required AdCampaignModel campaign,
    required AdPlacementModel placement,
    required String imageUrl,
    required String title,
    String? description,
    String? ctaText,
    String? ctaLink,
  }) = _AdResponse;

  factory AdResponse.fromJson(Map<String, dynamic> json) => _$AdResponseFromJson(json);
}