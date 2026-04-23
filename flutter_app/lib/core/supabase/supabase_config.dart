// Supabase Config
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://sb_publishable_P1mrq8ISYFFfHcG898iWuA_bbr67GaV.supabase.co';
  static const String key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJtdXhoa2Nnb2xsd3Brd2x2b295Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5NjYxMDYsImV4cCI6MjA5MjU0MjEwNn0.mqUbmfjJybeumI2Mo0l112X1tvhInXbzNeKVwBC1IjA';

  static Future<void> init() => Supabase.initialize(url: url, anonKey: key);
  static SupabaseClient get client => Supabase.instance.client;
}

class Db {
  final SupabaseClient c;
  Db(this.c);

  List<dynamic> getGifts(String id) => c.from('gifts').select().eq('wedding_id', id);
  List<dynamic> getWeddings(String id) => c.from('weddings').select().eq('owner_id', id);
  List<dynamic> getGuests(String id) => c.from('wedding_guests').select().eq('wedding_id', id);
  List<dynamic> getRates() => c.from('exchange_rates').select().eq('is_current', true);
  List<dynamic> getTypes() => c.from('gift_types').select().eq('is_active', true);
}