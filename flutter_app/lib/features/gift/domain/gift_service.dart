// =====================================================
// Gift Service - Takı Kaydetme Servisi
// Offline-first: İnternet olmasa bile hızlıca kaydet
// =====================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/local/app_database.dart';
import '../../../data/repositories/sync_repository.dart';

// =====================================================
// PROVIDERS
// =====================================================

// Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Sync Repository Provider
final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncRepository(db);
});

// Gift Repository Provider
final giftRepositoryProvider = Provider<GiftRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final syncRepo = ref.watch(syncRepositoryProvider);
  return GiftRepository(db, syncRepo);
});

// =====================================================
// GIFT SERVICE
// =====================================================

class GiftService {
  final GiftRepository _repository;
  
  GiftService(this._repository);
  
  // Takı tiplerini getir
  Future<List<GiftType>> getGiftTypes() => _repository._db.getAllGiftTypes();
  
  // Takı tiplerini dinle
  Stream<List<GiftType>> watchGiftTypes() => _repository._db.watchAllGiftTypes();
  
  // Bir düğünün takılarını getir
  Future<List<Gift>> getGiftsByWedding(String weddingId) =>
    _repository.getGiftsByWedding(weddingId);
  
  // Bir düğünün takılarını dinle
  Stream<List<Gift>> watchGiftsByWedding(String weddingId) =>
    _repository.watchGiftsByWedding(weddingId);
  
  // --- HIZLI KAYIT (OFFLINE FIRST) ---
  
  /// İnternet olmasa bile takı kaydet
  /// Internet geldiğinde otomatik senkronize olur
  Future<void> quickAddGift({
    required String weddingId,
    String? guestId,
    required String giftTypeId,
    required double quantity,
    String? note,
    String? recordedBy,
  }) async {
    // Birim değerini ve TL karşılığını hesapla
    final giftTypes = await getGiftTypes();
    final giftType = giftTypes.firstWhere(
      (t) => t.id == giftTypeId,
      orElse: () => throw Exception('Gift type not found'),
    );
    
    // TL değerini hesapla
    final totalTry = await _repository.calculateTryValue(
      giftType.code,
      quantity,
    );
    
    // Local olarak kaydet (hemen)
    await _repository.addGiftLocalOnly(
      weddingId: weddingId,
      guestId: guestId,
      giftTypeId: giftTypeId,
      quantity: quantity,
      unitValue: totalTry / quantity, // Birim değeri
      totalTry: totalTry,
      giftDate: DateTime.now(),
      giftTime: '${DateTime.now().hour}:${DateTime.now().minute}',
      recordedBy: recordedBy,
      note: note,
    );
  }
  
  /// Güncel kuru al
  Future<double?> getCurrentRate(String currency) =>
    _repository.getCurrentRate(currency);
  
  /// TL değerini hesapla
  Future<double> calculateTry(String giftTypeCode, double quantity) =>
    _repository.calculateTryValue(giftTypeCode, quantity);
  
  /// Bekleyen takıları senkronize et
  Future<SyncResult> syncPendingGifts() => _repository.syncPendingGifts();
  
  /// Toplam takı değerini hesapla
  Future<Map<String, dynamic>> calculateTotalGifts(String weddingId) async {
    final gifts = await getGiftsByWedding(weddingId);
    
    double totalTry = 0;
    double currentTry = 0;
    int count = gifts.length;
    
    for (final gift in gifts) {
      totalTry += gift.totalTry;
      currentTry += gift.currentTry ?? gift.totalTry;
    }
    
    return {
      'totalTry': totalTry,
      'currentTry': currentTry,
      'giftCount': count,
    };
  }
}

// Gift Service Provider
final giftServiceProvider = Provider<GiftService>((ref) {
  final repo = ref.watch(giftRepositoryProvider);
  return GiftService(repo);
});

// =====================================================
// STATE NOTIFIERS
// =====================================================

// Gift Types State
class GiftTypesNotifier extends StateNotifier<AsyncValue<List<GiftType>>> {
  final GiftService _service;
  
  GiftTypesNotifier(this._service) : super(const AsyncValue.loading()) {
    _load();
  }
  
  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final types = await _service.getGiftTypes();
      state = AsyncValue.data(types);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> refresh() => _load();
}

final giftTypesProvider = StateNotifierProvider<GiftTypesNotifier, AsyncValue<List<GiftType>>>((ref) {
  final service = ref.watch(giftServiceProvider);
  return GiftTypesNotifier(service);
});

// Gifts by Wedding State
class GiftsByWeddingNotifier extends StateNotifier<AsyncValue<List<Gift>>> {
  final GiftService _service;
  final String weddingId;
  
  GiftsByWeddingNotifier(this._service, this.weddingId) : super(const AsyncValue.loading()) {
    _load();
  }
  
  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final gifts = await _service.getGiftsByWedding(weddingId);
      state = AsyncValue.data(gifts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> refresh() => _load();
}

final giftsByWeddingProvider = StateNotifierProvider.family<GiftsByWeddingNotifier, AsyncValue<List<Gift>>, String>((ref, weddingId) {
  final service = ref.watch(giftServiceProvider);
  return GiftsByWeddingNotifier(service, weddingId);
});

// Quick Add State
class QuickAddGiftState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  
  const QuickAddGiftState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });
  
  QuickAddGiftState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return QuickAddGiftState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }
}

class QuickAddGiftNotifier extends StateNotifier<QuickAddGiftState> {
  final GiftService _giftService;
  
  QuickAddGiftNotifier(this._giftService) : super(const QuickAddGiftState());
  
  Future<void> addGift({
    required String weddingId,
    String? guestId,
    required String giftTypeId,
    required double quantity,
    String? note,
  }) async {
    state = state.copyWith(isLoading: true, isSuccess: false, error: null);
    
    try {
      await _giftService.quickAddGift(
        weddingId: weddingId,
        guestId: guestId,
        giftTypeId: giftTypeId,
        quantity: quantity,
        note: note,
      );
      
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  void reset() {
    state = const QuickAddGiftState();
  }
}

final quickAddGiftProvider = StateNotifierProvider<QuickAddGiftNotifier, QuickAddGiftState>((ref) {
  final service = ref.watch(giftServiceProvider);
  return QuickAddGiftNotifier(service);
});