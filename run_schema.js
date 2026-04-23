// Schema Runner Script
// Supabase'e schema'yı yüklemek için

const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

// Supabase credentials
const supabaseUrl = 'https://sb_publishable_P1mrq8ISYFFfHcG898iWuA_bbr67GaV.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJtdXhoa2Nnb2xsd3Brd2x2b295Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5NjYxMDYsImV4cCI6MjA5MjU0MjEwNn0.mqUbmfjJybeumI2Mo0l112X1tvhInXbzNeKVwBC1IjA';

// Service role key (settings'den alın)
const serviceKey = 'YOUR_SERVICE_ROLE_KEY';

const supabase = createClient(supabaseUrl, serviceKey);

// Read schema file
const schemaPath = path.join(__dirname, 'supabase/schema.sql');
const schema = fs.readFileSync(schemaPath, 'utf-8');

// Execute using PostgreSQL function
async function runSchema() {
  try {
    console.log('⏳ Schema çalıştırılıyor...');
    
    // Note: This requires a database function to execute raw SQL
    // For now, tables must be created via Supabase Dashboard SQL Editor
    
    console.log('❌ Direct SQL execution not available via JS SDK.');
    console.log('');
    console.log('📋 Alternatif Yöntemler:');
    console.log('');
    console.log('1. Supabase Dashboard > SQL Editor');
    console.log('2. Aşağıdaki kodu yapıştırın:');
    console.log('');
    console.log('-- Copy from supabase/schema.sql --');
    console.log('');
    console.log('3. Veya psql kullanın:');
    console.log('   psql "postgresql://[user]:[password]@db.rmuxhkcngollwpkwlvoy.supabase.co:5432/postgres" -f supabase/schema.sql');
    
  } catch (err) {
    console.error('Hata:', err.message);
  }
}

runSchema();