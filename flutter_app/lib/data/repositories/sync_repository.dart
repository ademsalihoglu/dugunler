// =====================================================
// Sync Repository
// Offline-First Senkronizasyon Servisi
// =====================================================

import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import '../datasources/local/app_database.dart';

class SyncRepository {
  final AppDatabase _db;
  final Connectivity _connectivity = Connectivity();
  
  SyncRepository(this._db);
  
  // İnternet bağlantısı var mı?
  Future<bool> hasInternet() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
  
  // Sync kuyruğuna ekle
  Future<void> queueForSync({
    required String tableName,
    required String recordId,
    required String operation,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
  }) async {
    await _db.addToSyncQueue(SyncQueueItemsCompanion.insert(
      userId: '', // Will be set from auth
      tableName: tableName,
      recordId: recordId,
      operation: operation,
      oldData: oldData != null ? Value(jsonEncode(oldData)) : const Value.absent(),
      newData: newData != null ? Value(jsonEncode(newData)) : const Value.absent(),
      status: const Value('bekliyor'),
      createdAt: Value(DateTime.now()),
    ));
  }
  
  // Tüm bekleyen kayıtları senkronize et
  Future<SyncResult> syncAll() async {
    if (!await hasInternet()) {
      return SyncResult(
        success: false,
        syncedCount: 0,
        failedCount: 0,
        message: 'İnternet bağlantısı yok',
      );
    }
    
    final pendingItems = await _db.getPendingSyncItems();
    int synced = 0;
    int failed = 0;
    
    for (final item in pendingItems) {
      try {
        bool success = await _syncItem(item);
        if (success) {
          await _db.markSynced(item.id);
          synced++;
        } else {
          await _db.markSyncFailed(item.id);
          failed++;
        }
      } catch (e) {
        await _db.markSyncFailed(item.id);
        failed++;
      }
    }
    
    return SyncResult(
      success: failed == 0,
      syncedCount: synced,
      failedCount: failed,
      message: '$synced kayıt senkronize edildi, $failed hata',
    );
  }
  
  // Tek bir kaydı senkronize et
  Future<bool> _syncItem(SyncQueueItem item) async {
    // Bu method Supabase'e veri gönderecek
    // API call burada yapılacak
    
    // Örnek:
    // final response = await supabase.from(item.tableName).upsert(...)
    
    return true; // Mock success
  }
  
  // Son senkronizasyon zamanı
  Future<DateTime?> getLastSyncTime() async {
    // settings box'tan oku
    return null;
  }
}

class SyncResult {
  final bool success;
  final int syncedCount;
  final int failedCount;
  final String message;
  
  SyncResult({
    required this.success,
    required this.syncedCount,
    required this.failedCount,
    required this.message,
  });
}

// =====================================================
// Gift Repository
// Supabase + Local Database
// =====================================================

class GiftRepository {
  final AppDatabase _db;
  final SyncRepository _syncRepo;
  
  GiftRepository(this._db, this._syncRepo);
  
  // Lokal veritabanından takıları getir
  Future<List<Gift>> getGiftsByWedding(String weddingId) =>
    _db.getGiftsByWedding(weddingId);
  
  // Takıları dinle (stream)
  Stream<List<Gift>> watchGiftsByWedding(String weddingId) =>
    _db.watchGiftsByWedding(weddingId);
  
  // Takı ekle (önce local, sonra sync kuyruğu)
  Future<void> addGiftLocalOnly({
    required String weddingId,
    String? guestId,
    required String giftTypeId,
    required double quantity,
    required double unitValue,
    required double totalTry,
    required DateTime giftDate,
    required String giftTime,
    String? recordedBy,
    String? note,
  }) async {
    final localId = DateTime.now().millisecondsSinceEpoch.toString();
    
    await _db.insertGift(GiftsCompanion.insert(
      id: Value(localId), // Local ID
      weddingId: weddingId,
      guestId: Value(guestId),
      giftTypeId: giftTypeId,
      quantity: quantity,
      unitValue: unitValue,
      totalTry: totalTry,
      giftDate: giftDate,
      giftTime: giftTime,
      recordedBy: Value(recordedBy),
      note: Value(note),
      syncStatus: const Value('yerel_bekliyor'),
      localId: Value(localId),
      createdAt: Value(DateTime.now()),
    ));
    
    // Sync kuyruğuna ekle
    await _syncRepo.queueForSync(
      tableName: 'gifts',
      recordId: localId,
      operation: 'INSERT',
      newData: {
        'weddingId': weddingId,
        'giftTypeId': giftTypeId,
        'quantity': quantity,
        'totalTry': totalTry,
        'syncStatus': 'senkron_bekliyor',
      },
    );
  }
  
  // Senkronize et
  Future<SyncResult> syncPendingGifts() async {
    return _syncRepo.syncAll();
  }
  
  // Güncel kurları al
  Future<double?> getCurrentRate(String currency) async {
    final rate = await _db.getCurrentRate(currency);
    return rate?.rate;
  }
  
  // TL değerini hesapla
  Future<double> calculateTryValue(String giftTypeCode, double quantity) async {
    double rate = 1.0;
    
    if (giftTypeCode.contains('GOLD')) {
      rate = await getCurrentRate('GOLD') ?? 2700.0;
      if (giftTypeCode == 'QUARTER_GOLD') {
        quantity = quantity * 0.75; // Çeyrek = ~0.75 gram
      }
    } else if (giftTypeCode == 'USD') {
      rate = await getCurrentRate('USD') ?? 32.50;
    } else if (giftTypeCode == 'EUR') {
      rate = await getCurrentRate('EUR') ?? 35.0;
    }
    
    return quantity * rate;
  }
}