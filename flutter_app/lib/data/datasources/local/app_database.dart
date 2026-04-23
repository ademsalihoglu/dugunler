// =====================================================
// Drift Database Definition
// Offline-First Local Storage
// =====================================================

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// =====================================================
// TABLE DEFINITIONS
// =====================================================

// Users Table
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get phone => text()();
  TextColumn get fullName => text()();
  TextColumn get profilePhotoUrl => text().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get region => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get aboutMe => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Weddings Table
class Weddings extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text().references(Users, #id)();
  TextColumn get brideName => text()();
  TextColumn get groomName => text()();
  DateTimeColumn get weddingDate => dateTime()();
  TextColumn get weddingTime => text()();
  TextColumn get venueName => text().nullable()();
  TextColumn get venueAddress => text().nullable()();
  RealColumn get venueLatitude => real().nullable()();
  RealColumn get venueLongitude => real().nullable()();
  TextColumn get region => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('planlandi'))();
  IntColumn get guestCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Gift Types Table
class GiftTypes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get code => text()();
  TextColumn get unit => text()();
  TextColumn get icon => text().nullable()();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Gifts Table (Takı Kayıtları)
class Gifts extends Table {
  TextColumn get id => text()();
  TextColumn get weddingId => text().references(Weddings, #id)();
  TextColumn get guestId => text().nullable()();
  TextColumn get giftTypeId => text().references(GiftTypes, #id)();
  RealColumn get quantity => real()();
  RealColumn get unitValue => real()();
  RealColumn get totalTry => real()();
  RealColumn get currentTry => real().nullable()();
  TextColumn get rateId => text().nullable()();
  DateTimeColumn get giftDate => dateTime()();
  TextColumn get giftTime => text()();
  TextColumn get recordedBy => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('senkronize'))();
  TextColumn get localId => text().nullable()();
  TextColumn get deviceId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Wedding Guests Table
class WeddingGuests extends Table {
  TextColumn get id => text()();
  TextColumn get weddingId => text().references(Weddings, #id)();
  TextColumn get userId => text().nullable()();
  TextColumn get guestName => text()();
  TextColumn get guestPhone => text().nullable()();
  TextColumn get guestEmail => text().nullable()();
  TextColumn get relationship => text().nullable()();
  TextColumn get relationDetail => text().nullable()();
  TextColumn get invitationStatus => text().withDefault(const Constant('bekliyor'))();
  BoolColumn get willAttend => boolean().nullable()();
  IntColumn get partySize => integer().withDefault(const Constant(1))();
  TextColumn get dietaryNotes => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Exchange Rates Table
class ExchangeRates extends Table {
  TextColumn get id => text()();
  TextColumn get baseCurrency => text()();
  TextColumn get targetCurrency => text()();
  RealColumn get rate => real()();
  DateTimeColumn get fetchedAt => dateTime().nullable()();
  BoolColumn get isCurrent => boolean().withDefault(const Constant(true))();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Sync Queue Table
class SyncQueueItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get tableName => text()();
  TextColumn get recordId => text()();
  TextColumn get operation => text()();  // 'INSERT', 'UPDATE', 'DELETE'
  TextColumn get oldData => text().nullable()();
  TextColumn get newData => text().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('bekliyor'))();
}

// =====================================================
// DATABASE CLASS
// =====================================================

@DriftDatabase(tables: [
  Users,
  Weddings,
  GiftTypes,
  Gifts,
  WeddingGuests,
  ExchangeRates,
  SyncQueueItems,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Insert default gift types
        await _insertDefaultGiftTypes();
        // Insert default exchange rates
        await _insertDefaultExchangeRates();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations
      },
    );
  }

  Future<void> _insertDefaultGiftTypes() async {
    final defaultTypes = [
      GiftTypesCompanion.insert(
        id: Value('quarte_gold'), name: 'Çeyrek Altın', code: 'QUARTER_GOLD', unit: 'adet',
        icon: const Value('💍'), displayOrder: const Value(1),
      ),
      GiftTypesCompanion.insert(
        id: Value('half_gold'), name: 'Yarım Altın', code: 'HALF_GOLD', unit: 'adet',
        icon: const Value('💍'), displayOrder: const Value(2),
      ),
      GiftTypesCompanion.insert(
        id: Value('full_gold'), name: 'Tam Altın', code: 'FULL_GOLD', unit: 'adet',
        icon: const Value('💍'), displayOrder: const Value(3),
      ),
      GiftTypesCompanion.insert(
        id: Value('gram_gold'), name: 'Gram Altın', code: 'GRAM_GOLD', unit: 'gram',
        icon: const Value('🥇'), displayOrder: const Value(4),
      ),
      GiftTypesCompanion.insert(
        id: Value('republic_gold'), name: 'Cumhuriyet Altını', code: 'REPUBLIC_GOLD', unit: 'adet',
        icon: const Value('💰'), displayOrder: const Value(5),
      ),
      GiftTypesCompanion.insert(
        id: Value('five_gold'), name: 'Beşli Altın', code: 'FIVE_GOLD', unit: 'adet',
        icon: const Value('💎'), displayOrder: const Value(6),
      ),
      GiftTypesCompanion.insert(
        id: Value('usd'), name: 'Dolar', code: 'USD', unit: 'dolar',
        icon: const Value('💵'), displayOrder: const Value(7),
      ),
      GiftTypesCompanion.insert(
        id: Value('eur'), name: 'Euro', code: 'EUR', unit: 'euro',
        icon: const Value('💶'), displayOrder: const Value(8),
      ),
      GiftTypesCompanion.insert(
        id: Value('try'), name: 'Türk Lirası', code: 'TRY', unit: 'tl',
        icon: const Value('₺'), displayOrder: const Value(9),
      ),
    ];
    
    for (final type in defaultTypes) {
      await into(giftTypes).insert(type);
    }
  }

  Future<void> _insertDefaultExchangeRates() async {
    final defaultRates = [
      ExchangeRatesCompanion.insert(
        id: Value('gold_rate'), baseCurrency: 'GOLD', targetCurrency: 'TRY',
        rate: 2700.00, fetchedAt: Value(DateTime.now()), isCurrent: const Value(true),
      ),
      ExchangeRatesCompanion.insert(
        id: Value('usd_rate'), baseCurrency: 'USD', targetCurrency: 'TRY',
        rate: 32.50, fetchedAt: Value(DateTime.now()), isCurrent: const Value(true),
      ),
      ExchangeRatesCompanion.insert(
        id: Value('eur_rate'), baseCurrency: 'EUR', targetCurrency: 'TRY',
        rate: 35.00, fetchedAt: Value(DateTime.now()), isCurrent: const Value(true),
      ),
    ];
    
    for (final rate in defaultRates) {
      await into(exchangeRates).insert(rate);
    }
  }

  // =====================================================
  // QUERY METHODS
  // =====================================================

  // Gift Types
  Future<List<GiftType>> getAllGiftTypes() => select(giftTypes).get();
  Stream<List<GiftType>> watchAllGiftTypes() => select(giftTypes).watch();
  
  // Gifts by Wedding
  Future<List<Gift>> getGiftsByWedding(String weddingId) =>
    (select(gifts)..where((g) => g.weddingId.equals(weddingId))).get();
  
  Stream<List<Gift>> watchGiftsByWedding(String weddingId) =>
    (select(gifts)..where((g) => g.weddingId.equals(weddingId))).watch();
  
  // Pending Sync Items
  Future<List<SyncQueueItem>> getPendingSyncItems() =>
    (select(syncQueueItems)..where((s) => s.status.equals('bekliyor'))).get();
  
  // Exchange Rates
  Future<ExchangeRate?> getCurrentRate(String baseCurrency) =>
    (select(exchangeRates)
      ..where((r) => r.baseCurrency.equals(baseCurrency) & r.isCurrent.equals(true)))
    .getSingleOrNull();
  
  // =====================================================
  // INSERT/UPDATE METHODS
  // =====================================================

  Future<void> insertGift(GiftsCompanion gift) async {
    await into(gifts).insert(gift);
  }

  Future<void> updateGift(GiftsCompanion gift) async {
    await (update(gifts)..where((g) => g.id.equals(gift.id.value)))
      .write(gift);
  }

  Future<void> deleteGift(String id) async {
    await (delete(gifts)..where((g) => g.id.equals(id))).go();
  }

  // Sync Queue Operations
  Future<int> addToSyncQueue(SyncQueueItemsCompanion item) async {
    return await into(syncQueueItems).insert(item);
  }

  Future<void> markSynced(int syncId) async {
    await (update(syncQueueItems)..where((s) => s.id.equals(syncId)))
      .write(SyncQueueItemsCompanion(
        status: const Value('basarili'),
        syncedAt: Value(DateTime.now()),
      ));
  }

  Future<void> markSyncFailed(int syncId) async {
    await (update(syncQueueItems)..where((s) => s.id.equals(syncId)))
      .write(SyncQueueItemsCompanion(
        status: const Value('basarisiz'),
        retryCount: syncQueueItems.retryCount + const Value(1),
      ));
  }

  // Wedding Operations
  Future<void> insertWedding(WeddingsCompanion wedding) async {
    await into(weddings).insert(wedding);
  }

  Future<void> insertGuest(WeddingGuestsCompanion guest) async {
    await into(weddingGuests).insert(guest);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dugun_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}