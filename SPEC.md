# DüğünDefteri - Teknik Mimari Dokümantasyonu

## 1. Genel Bakış

**Uygulama Adı:** DüğünDefteri  
**Hedef Kitle:** Doğu ve Güneydoğu Anadolu bölgesi düğün sahipleri ve konukları  
**Gelir Modeli:** Tamamen ücretsiz + Native Reklam (Adsense benzeri)  
**Offline Desteği:** Evet (veriler önce cihazda, sonra senkronize)

---

## 2. Veritabanı Şeması (PostgreSQL)

### 2.1 Kullanıcı Tabloları

```sql
-- Kullanıcılar (Düğün sahipleri ve konuklar)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(20) UNIQUE NOT NULL,           -- Telefon numarası (login için)
    full_name VARCHAR(100) NOT NULL,           -- Ad Soyad
    profile_photo_url TEXT,                     -- Profil fotoğrafı
    birth_date DATE,                           -- Doğum tarihi (yaş hesaplama için)
    region VARCHAR(50),                         -- Bölge (örn: Diyarbakır, Şanlıurfa)
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP
);

-- Kullanıcı Cihazları (Push bildirim için)
CREATE TABLE user_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    device_token VARCHAR(255) NOT NULL,         -- FCM Token
    device_type VARCHAR(20),                    -- android, ios
    app_version VARCHAR(20),
    last_active_at TIMESTAMP DEFAULT NOW()
);
```

### 2.2 Düğün Kayıtları

```sql
-- Düğünler
CREATE TABLE weddings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,  -- Düğün sahibi
    bride_name VARCHAR(100) NOT NULL,            -- Gelin adı
    groom_name VARCHAR(100) NOT NULL,            -- Damat adı
    wedding_date DATE NOT NULL,                 -- Düğün tarihi
    wedding_time TIME NOT NULL,                  -- Düğün saati
    venue_name VARCHAR(200),                    -- Düğün salonu/mekanı
    venue_address TEXT,                        -- Mekan adresi
    venue_latitude DECIMAL(10,8),               -- Konum
    venue_longitude DECIMAL(11,8),
    region VARCHAR(50),                        -- İl/İlçe
    description TEXT,                          -- Notlar
    status VARCHAR(20) DEFAULT 'active',       -- active, completed, cancelled
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Düğüne Katılan Konuklar (Takı Verenler)
CREATE TABLE wedding_guests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),            -- Sistemde kayıtlıysa
    guest_name VARCHAR(100) NOT NULL,           -- Konuk adı (misafirse)
    guest_phone VARCHAR(20),                    -- Konuk telefon
    relationship VARCHAR(50),                   -- Akraba, Arkadaş, İş vb.
    invitation_status VARCHAR(20) DEFAULT 'pending', -- pending, invited, confirmed, declined
    will_attend BOOLEAN,                        -- Katılacak mı?
    note TEXT,                                 -- Not
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 2.3 Takı (Hediye) Kayıtları

```sql
-- Takı Türleri
CREATE TABLE gift_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,                   -- Tür adı (Altın, Dolar, Euro, TL)
    code VARCHAR(10) UNIQUE NOT NULL,            -- Kod (GOLD, USD, EUR, TRY)
    icon VARCHAR(50),                           -- İkon
    is_crypto BOOLEAN DEFAULT FALSE             -- Kripto para mı?
);

-- Güncel Kurlar (Otomatik güncellenecek)
CREATE TABLE exchange_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    base_currency VARCHAR(10) NOT NULL,         -- Baz para birimi
    target_currency VARCHAR(10) NOT NULL,        -- Hedef para birimi
    rate DECIMAL(20, 6) NOT NULL,               -- Kur
    fetched_at TIMESTAMP DEFAULT NOW()
);

-- Takı Kayıtları
CREATE TABLE gifts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    guest_id UUID REFERENCES wedding_guests(id) ON DELETE SET NULL,
    gift_type_id UUID REFERENCES gift_types(id),
    
    -- Takı bilgileri
    quantity DECIMAL(15, 3),                     -- Miktar (çeyrek altın, adet Dolar vb.)
    amount TRY,                                 -- TL karşılığı (enflasyon koruması için)
    converted_amount TRY,                     -- Güncel kurlarla TL karşılığı
    
    -- Kayıt bilgileri
    gift_date DATE DEFAULT CURRENT_DATE,       -- Takıldığı tarih
    gift_time TIME,                            -- Takıldığı saat
    recorded_by UUID REFERENCES users(id),      -- Kim kaydetti
    note TEXT,                                 -- Not (hangi düğünde ne takıldı)
    
    -- Senkronizasyon
    sync_status VARCHAR(20) DEFAULT 'synced',   -- local_only, pending_sync, synced
    local_id UUID,                             -- Offline ID
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Takı Geçmişi (Değer artışı için)
CREATE TABLE gift_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gift_id UUID REFERENCES gifts(id) ON DELETE CASCADE,
    amount_before TRY,
    amount_after TRY,
    rate_id UUID REFERENCES exchange_rates(id),
    changed_at TIMESTAMP DEFAULT NOW()
);
```

### 2.4 Davetli Listesi & Geri Dönüş

```sql
-- Düğün Davetleri
CREATE TABLE invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
    guest_id UUID REFERENCES wedding_guests(id),
    invitation_code VARCHAR(20) UNIQUE,        -- Benzersiz davet kodu
    sent_at TIMESTAMP,                         -- Gönderildi
    responded_at TIMESTAMP,                    -- Yanıtlandı
    will_attend BOOLEAN,
    party_size INTEGER DEFAULT 1,               -- Kaç kişi gelecek
    dietary_restrictions TEXT,                 -- Diyet kısıtlamaları
    created_at TIMESTAMP DEFAULT NOW()
);

-- Geri Dönüş Takibi (Kimlerin düğününe gitmişiz)
CREATE TABLE return_visits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),            -- Biz
    attended_wedding_id UUID,                  -- Gittiğimiz düğün
    wedding_owner_id UUID,                      -- Düğün sahibi
    gift_amount TRY,                           -- Ne takmıştık
    gift_type VARCHAR(20),                      -- Altın/Para
    note TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 2.5 Reklam Modülü

```sql
-- Reklam Verenler (Esnaf/Kurumsal)
CREATE TABLE advertisers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_name VARCHAR(200) NOT NULL,       -- İşletme adı
    owner_user_id UUID REFERENCES users(id),   -- Hesap sahibi
    category VARCHAR(50) NOT NULL,              -- Kategori
    sub_category VARCHAR(50),                  -- Alt kategori
    description TEXT,
    logo_url TEXT,
    cover_image_url TEXT,
    website_url TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    status VARCHAR(20) DEFAULT 'pending',      -- pending, active, paused, rejected
    balance DECIMAL(15, 2) DEFAULT 0,          -- Bakiye
    created_at TIMESTAMP DEFAULT NOW(),
    verified_at TIMESTAMP
);

-- Reklam Veren Şubeleri/Locationları
CREATE TABLE advertiser_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    advertiser_id UUID REFERENCES advertisers(id) ON DELETE CASCADE,
    name VARCHAR(200),                          -- Şube adı
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    region VARCHAR(50),                        -- Bölge
    city VARCHAR(50),                          -- Şehir
   district VARCHAR(50),                      -- İlçe
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE
);

-- Reklam Kampanyaları
CREATE TABLE ad_campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    advertiser_id UUID REFERENCES advertisers(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL,             -- kuyumcu, duvar_salonu, gelinlik, damatlik, mobilya
    title VARCHAR(200),
    description TEXT,
    image_url TEXT,
    cta_text VARCHAR(50),                      -- "İndirim Kodu Al"
    cta_link TEXT,                             -- Deep link
    target_regions TEXT[],                     -- Hedef bölgeler
    start_date DATE,
    end_date DATE,
    daily_budget DECIMAL(15, 2),
    total_budget DECIMAL(15, 2),
    cost_per_click DECIMAL(10, 4),
    cost_per_view DECIMAL(10, 6),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Reklame Gösterim Yerleşimleri
CREATE TABLE ad_placements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,                 -- home_banner, calendar_interstitial, gift_entry
    description TEXT,
    width INTEGER,
    height INTEGER,
    format VARCHAR(20),                        -- banner, interstitial, native
    is_active BOOLEAN DEFAULT TRUE
);

-- Reklam Gösterim Kayıtları
CREATE TABLE ad_impressions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID REFERENCES ad_campaigns(id),
    placement_id UUID REFERENCES ad_placements(id),
    user_id UUID REFERENCES users(id),
    wedding_id UUID REFERENCES weddings(id),
    view_count INTEGER DEFAULT 1,
    is_clicked BOOLEAN DEFAULT FALSE,
    device_info JSONB,
    location JSONB,
    shown_at TIMESTAMP DEFAULT NOW()
);

-- Reklam İstatistikleri (Aggreigned)
CREATE TABLE ad_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID REFERENCES ad_campaigns(id),
    placement_id UUID REFERENCES ad_placements(id),
    date DATE NOT NULL,
    impressions INTEGER DEFAULT 0,
    clicks INTEGER DEFAULT 0,
    views INTEGER DEFAULT 0,
    spend DECIMAL(15, 2) DEFAULT 0,
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(campaign_id, placement_id, date)
);
```

### 2.6 Bildirimler

```sql
-- Bildirim Şablonları
CREATE TABLE notification_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title_template TEXT NOT NULL,
    body_template TEXT NOT NULL,
    type VARCHAR(50),                            -- wedding_reminder, gift_reminder, ad_promo
    action_type VARCHAR(50),                      -- navigate, deep_link
    action_data JSONB,
    is_active BOOLEAN DEFAULT TRUE
);

-- Kullanıcı Bildirimleri
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    template_id UUID REFERENCES notification_templates(id),
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    data JSONB,                                -- Extra data
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP,
    read_at TIMESTAMP
);

-- Push Bildirim Kuyruğu
CREATE TABLE push_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    data JSONB,
    scheduled_at TIMESTAMP,                    -- Zamanlanmış
    sent_at TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending',        -- pending, sent, failed
    retry_count INTEGER DEFAULT 0
);
```

### 2.7 Senkronizasyon

```sql
-- Offline Senkronizasyon Kuyruğu
CREATE TABLE sync_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    table_name VARCHAR(50) NOT NULL,
    record_id UUID NOT NULL,
    operation VARCHAR(20) NOT NULL,              -- insert, update, delete
    old_data JSONB,
    new_data JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    synced_at TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending'         -- pending, synced, failed
);

-- Son Senkronizasyon
CREATE TABLE user_sync_meta (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    last_synced_at TIMESTAMP,
    sync_token VARCHAR(100)
);
```

---

## 3. Reklam Yönetim Modülü

### 3.1 Mimari

```
┌─────────────────────────────────────────────────────────────┐
│                    REKLAM MOTORU                           │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐        │
│  │  Ad Server  │──▶│ Targeting  │──▶│  Auction   │        │
│  │   (API)    │   │   Engine   │   │   Engine   │        │
│  └─────────────┘   └─────────────┘   └─────────────┘        │
│        │               │               │                          │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐        │
│  │  Reporting │   │  Payment   │   │  Dashboard │        │
│  │  Service   │   │  Service   │   │   (Esnaf)  │        │
│  └─────────────┘   └─────────────┘   └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Reklam Yerleşimleri

| Yerleşim | Tip | Boyut | Açıklama |
|---------|-----|------|---------|
| home_banner | Banner | 320x100 | Ana sayfa üst/alt banner |
| calendar_header | Banner | 320x50 | Takvim üstü |
| calendar_interstitial | Interstitial | Full screen | Takvim geçiş |
| gift_entry | Native | List item | Takı girişinde |
| guest_list_native | Native | List item | Davetli listesinde |
| return_list_native | Native | List item | Geri dönüş listesinde |
| wedding_detail | Banner | 320x100 | Düğün detayında |

### 3.3 Hedefleme Kuralları

```python
# Targeting Engine Pseudocode
def select_ads(user, placement, context):
    criteria = {
        'user_region': user.region,
        'wedding_season': get_wedding_season(context),
        'user_category_prefs': get_user_preferences(user.id),
        'placement': placement.id
    }
    
    # Sorgu
    ads = AdCampaign.objects.filter(
        status='active',
        category__in=RELEVANT_CATEGORIES[criteria['placement']],
        target_regions__contains=criteria['user_region'],
        start_date__lte=today,
        end_date__gte=today,
        daily_budget__gt=0
    ).order_by('-cost_per_click')
    
    # En yüksek teklif seçilir (Second Price Auction)
    selected = auction(ads)
    return selected
```

### 3.4 Esnaf Dashboard Özellikleri

- **Kampanya Yönetimi**: Reklam oluşturma, bütçe ayarlama
- **Bölgesel Hedefleme**: İl/İlçe seçimi
- **İstatistikler**: Tıklama, görüntüleme, harcanan
- **Bakiye Yönetimi**: Ödeme yükleme, fatura
- **QR Kod**: Mağaza özel indirim kodu

### 3.5 Reklam Gelir Dağılımı

| Kalem | Oran |
|------|------|
| Platform (DüğünDefteri) | %30 |
| Geliştirici/Akaryükleme | %20 |
| Kullanıcı Ödülü (İsteğe bağlı) | %10 |
| Esnaf Geliri | %40 |

---

## 4. Kullanıcı Akış Şeması (User Flow)

### 4.1 Kayıt & Giriş Akışı

```
┌──────────┐
│  Start   │
└────┬─────┘
     │
     ▼
┌──────────────┐     ┌──────────────┐
│ Telefon No   │────▶│   SMS Kod    │
│ Girişi      │     │  Doğrulama   │
└──────────────┘     └──────┬───────┘
                            │
                            ▼
                   ┌──────────────┐
                   │  Profil    │
                   │ Oluşturma  │
                   └──────┬───────┘
                          │
                          ▼
                   ┌──────────────┐
                   │ Ana Sayfa  │
                   │ (Home)    │
                   └──────────┘
```

### 4.2 Düğün Yönetim Akışı

```
┌─────────────────────────────────────────────────────────────┐
│                     ANA SAYFA (Home)                        │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐       │
│  │ Takvim  │  │  Takı   │  │ Konuk   │  │ Geri    │       │
│  │  Icon  │  │ Muhasebe│  │  List   │  │ Dönüş   │       │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘       │
│       │           │           │           │                   │
│       ▼           ▼           ▼           ▼                   │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐       │
│  │ Takvim  │  │ Takı    │  │ Davetli│  │ Geri   │       │
│  │ Ekranı │  │ Listesi │  │ Liste  │  │ Dönüş  │       │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘       │
└─────────────────────────────────────────────────────────────┘
```

### 4.3 Takı Kaydetme Akışı (Offline First)

```
┌─────────────────────────────────────────────────────────────┐
│                TAKI KAYDETME (Quick Entry)                │
├─────────────────────────────────────────────────────────────┤
│  1. Konuk Seç (veya yeni konuk ekle)                       │
│  2. Takı Tipi Seç                                        │
│     ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐               │
│     │Altın │ │ Dolar│ │ Euro │ │  TL  │               │
│     └──────┘ └──────┘ └──────┘ └──────┘               │
│  3. Miktar Gir                                            │
│  4. [Opsiyonel] Not ekle                                 │
│  5. Kaydet ──▶ local_db.save()                           │
│              ──▶ sync_queue.add()                        │
│              ──▶ [İnternet var] → API.sync()             │
└─────────────────────────────────────────────────────────────┘
```

### 4.4 Geri Dönüş Listesi Akışı

```
┌─────────────────────────────────────────────────────────────┐
│                  GERİ DÖNÜŞ LİSTESİ                      │
├─────────────────────────────────────────────────────────────┤
│  "Kend düğünümüz olduğunda kimi çağırmalıyız?"            │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Geçmişte düğününe gittiğimiz kişiler             │   │
│  │ ────────────────────────────────────────────      │   │
│  │ □ Ahmet Yılmaz   (Diyarbakır, 2023)   Takı: 1   │   │
│  │                      çeyrek altın                   │   │
│  │ □ Ayşe Kaya     (Şanlıurfa, 2024)   Takı: 5000 TL│   │
│  │ □ Mehmet Demir  (Mardin, 2023)    Takı: 200$      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  [Tümünü Davet Et]  [Seçilileri Davet Et]                │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Ana Ekran Bileşenleri

### 5.1 HomeScreen

```
┌────────────────────────────────────────────┐
│  ┌──────────────────────────────────────┐  │
│  │  📅 Yaklaşan Düğünler           [+] │  │
│  │  ────────────────────────────────     │  │
│  │  15 Mayıs - Ahmet & Ayşe           │  │
│  │  22 Mayıs - Mehmet & Fatma        │  │
│  │  ────────────────────────────────     │  │
│  │  [Takvimı Aç]                     │  │
│  └──────────────────────────────────────┘  │
│                                            │
│  ┌──────────────────────────────────────┐  │
│  │     [REKLAM BANNER - 320x100]          │  │
│  └──────────────────────────────────────┘  │
│                                            │
│  ┌────────────┐  ┌────────────┐              │
│  │    💰     │  │    👥     │              │
│  │    Takı   │  │   Konuk    │              │
│  │  125.000  │  │    85     │              │
│  │    TL     │  │   Kişi    │              │
│  └────────────┘  └────────────┘              │
│                                            │
│  ┌────────────┐  ┌────────────┐              │
│  │    ↩️     │  │    🔔     │              │
│  │   Geri    │  │  Henüz    │              │
│  │  Dönüş    │  │  Açılmadı  │              │
│  └────────────┘  └────────────┘              │
│                                            │
│  [Navigation Bar: Home|Takvim|Takı|Konuk|Geri]│
└────────────────────────────────────────────┘
```

### 5.2 CalendarScreen

```
┌────────────────────────────────────────────┐
│  ◀  Mayıs 2026  ▶                 │
│  Pzt Sal Çar Per Cum Cmt Paz          │
│           1  2  3  4  5  6        │
│        7  8 [9]10 11 12 13 14      │
│       15 16 17 18 19 20 21        │
│       22 23 24 25 26 27 28        │
│       29 30 31                    │
│                                      │
│  ─────────────────────────────────   │
│                                      │
│  📅 9 Mayıs Düğünleri               │
│  ─────────────────────────────────   │
│  ● Ahmet Yılmaz & Ayşe Kaya         │
│    Saat: 14:00                      │
│    Yer: Grand Wedding Hall           │
│    Konuk: 120 kişi                  │
│                                      │
│  ⚠️ UYARI: 2 düğün çakışıyor!       │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ [REKLAM - Interstitial]        │  │
│  └────────────────────────────────┘  │
│                                      │
│  [+ Yeni Düğün Ekle]                  │
└────────────────────────────────────────────┘
```

### 5.3 GiftScreen (Takı Listesi)

```
┌────────────────────────────────────────────┐
│  💰 Takı Muhasebesi               [+]      │
│  ─────────────────────────────────        │
│  Toplam Değer: 125.450 TL                  │
│  (Güncel kurla: 145.200 TL)               │
│  ─────────────────────────────────        │
│  🔍 Konuk ara...                         │
│                                            │
│  ┌────────────────────────────────────┐   │
│  │ Ahmed Yılmaz              +---------│   │
│  │ ┌────┐ 1 çeyrek altın    │💰12000 TL│  │
│  │ │Altın│ Verildi: 15:30     │         │  │
│  │ └────┘                   │         │   │
│  │                      [Düzenle]    │   │
│  │ ─────────────────────────────────  │   │
│  │                                     │   │
│  │ Ayşe Demir                +---------│   │
│  │ ┌────┐ 500 TL           │💰500 TL │   │
│  │ │ TL │ Verildi: 14:45    │         │   │
│  │ └────┘                   │         │   │
│  │                      [Düzenle]    │   │
│  └────────────────────────────────────┘   │
│                                            │
│  ┌────────────────────────────────────┐   │
│  │   [REKLAM BANNER - Native]         │   │
│  │   Kuyumcu Mehmet - %20 İndirim     │   │
│  └────────────────────────────────────┘   │
│                                            │
│  [Filtre: Tümü|Altın|Dolar|Euro|TL]        │
└────────────────────────────────────────────┘
```

### 5.4 GuestScreen (Davetli Listesi)

```
┌────────────────────────────────────────────┐
│  👥 Davetli Listesi              [+ Konuk] │
│  ─────────────────────────────────         │
│  Toplam: 85 Kişi                            │
│  Davetli: 45  │  Onay: 25  │  Bekleyen: 15  │
│  ─────────────────────────────────         │
│  ┌────────────────────────────────────┐   │
│  │ 🔍 Konuk ara...                     │   │
│  └────────────────────────────────────┘   │
│                                            │
│  ┌─── Katılacak ─────────────────────┐     │
│  │ Ahmed Yılmaz        ┌─────────┐  │       │
│  │ Akraba (Birinci)    │ 👤 +2   │  │       │
│  │ ────────────────── │         │  │       │
│  │ Mehmet Yılmaz                   │  │       │
│  │ Ayşe Yılmaz                    │  │       │
│  └───────────────────┴─────────┴──┘       │
│                                            │
│  ┌─── Bekleyen ─────────────────────┐       │
│  │ Fatma Kaya                      │       │
│  │ ──────────────────            │       │
│  │ [Davet Gönder]  [Reddet]        │       │
│  └────────────────────────────────┘       │
│                                            │
│  [Tümü | Akraba | Arkadaş | İş]              │
└────────────────────────────────────────────┘
```

### 5.5 ReturnVisitScreen (Geri Dönüş)

```
┌────────────────────────────────────────────┐
│  ↩️ Geri Dönüş Listesi                      │
│  ─────────────────────────────────       │
│  "Düğünümüz olduğunda kimi çağırmalıyız?"    │
│  ─────────────────────────────────       │
│                                            │
│  ┌────────────────────────────────────┐   │
│  │ Geçmişte düğününe gittiğimiz kişiler │   │
│  │ ─────────────────────────────────  │   │
│  │                                     │   │
│  │ ☑️  Ahmet Yılmaz                  │   │
│  │    Diyarbakır - 15 Haz 2023        │   │
│  │    Takı: 1 çeyrek altın           │   │
│  │    ─────────────────────────────── │   │
│  │                                     │   │
│  │ ☐  Ayşe Kaya                    │   │
│  │    Şanlıurfa - 22 Tem 2024       │   │
│  │    Takı: 5.000 TL               │   │
│  │    ───────────────────────────── │   │
│  │                                     │   │
│  │ ☐  Mehmet Demir                  │   │
│  │    Mardin - 10 Ağu 2023          │   │
│  │    Takı: 200$                    │   │
│  └────────────────────────────────────┘   │
│                                            │
│  [Seçili Olanları Davet Et]                   │
└────────────────────────────────────────────┘
```

---

## 6. Offline First Mimarisi

### 6.1 Veri Senkronizasyon Akışı

```
┌─────────────────────────────────────────────────────────────┐
│                   OFFLINE SYNC FLOW                        │
├─────────────────────────────────────────────────────────────┤
│                                                      │
│   Mobile App                    Cloud API              │
│   ─────────                    ──────────              │
│                                                      │
│   ┌─────────────┐                              │       
│   │ Local DB   │                              │       
│   │ (Hive/     │                              │       
│   │  SQLite)  │                              │       
│   └─────┬─────┘                              │       
│         │                                    │       
│   [Internet Var?]                            │       
│         │                                    │       
│    ┌────┴────┐                              │       
│    │ EVET    │ HAYIR                       │       
│    ▼        │                              │       
│  API.sync() │                              │       
│    │       │                              │       
│    │  POST /api/sync                    │       
│    │  {records: [...]}                │       
│    │       │                              │       
│    │       │     ┌──────────────┐      │       
│    │       │◀────│ Batch        │      │       
│    │       │     │ Process     │      │       
│    │       │     └──────┬──────┘      │       
│    │       │            │               │       
│    │       │     ┌──────┴──────┐      │       
│    │       │     │ Resolve    │      │       
│    │       │     │ Conflicts  │      │       
│    │       │     └──────┬──────┘      │       
│    │       │            │               │       
│    │  ◀───────────────┘               │       
│    │       │                              │       
│    ▼       │                              │       
│  Conflict  │                              │       
│  Resolution                               │       
│    │       │                              │       
│    ▼       ▼                              │       
│  Local DB  │                              │       
│  Update    │                              │       
│         [Retry Queue active]              │       
└─────────────────────────────────────────────────────────────┘
```

### 6.2 Conflict Resolution

```javascript
// Öncelik kuralları
const conflictRules = {
  'gifts': 'latest_wins',           // En son kayıt kazanır
  'wedding_guests': 'latest_wins',
  'weddings': 'server_wins',
  '.invitations': 'latest_wins'
};
```

---

## 7. API Endpoint'leri

### 7.1 Authentication
- `POST /api/auth/request-otp` - OTP iste
- `POST /api/auth/verify-otp` - OTP doğrula
- `GET /api/auth/me` - Profil bilgisi

### 7.2 Weddings
- `GET /api/weddings` - Düğün listesi
- `POST /api/weddings` - Yeni düğün
- `GET /api/weddings/:id` - Düğün detay
- `PUT /api/weddings/:id` - Düğün güncelle
- `DELETE /api/weddings/:id` - Düğün sil

### 7.3 Guests
- `GET /api/weddings/:id/guests` - Konuk listesi
- `POST /api/weddings/:id/guests` - Konuk ekle
- `PUT /api/guests/:id` - Konuk güncelle

### 7.4 Gifts
- `GET /api/weddings/:id/gifts` - Takı listesi
- `POST /api/weddings/:id/gifts` - Takı ekle
- `PUT /api/gifts/:id` - Takı güncelle

### 7.5 Return Visits
- `GET /api/return-visits` - Geri dönüş listesi
- `POST /api/return-visits` - Geri dönüş ekle

### 7.6 Ads
- `GET /api/ads/placements` - Reklam yerleşimleri
- `POST /api/ads/request` - Reklam iste (render için)
- `POST /api/ads/click` - Tıklama kaydet
- `POST /api/ads/impression` - Gösterim kaydet

### 7.7 Sync
- `POST /api/sync` - Senkronizasyon
- `GET /api/sync/status` - Son senkron durumu

---

## 8. Push Bildirim Stratejisi

### 8.1 Bildirim Türleri

| Bildirim | Tetikleyici | İçerik |
|---------|------------|--------|
| Düğün hatırlatma | 1 gün önce | "Yarın Ahmet & Ayşe'nin düğünü var!" |
| Konuk onayı | Yeni onay | "Ahmet Yılmaz katılacağını onayladı" |
| Konum bazlı | Mağaza yakını | "Yol üzerinde X Kuyumcusu'nda %20 indirim!" |
| Takı hatırlatma | Düğün günü | "Bugün düğün! Kimlere takı verdik?" |
| Geri dönüş önerisi | Kullanıcı düğünüблиз | "25 kişiyi düğününüze davet edebilirsiniz" |

---

## 9. Teknoloji Stack Özeti

| Katman | Teknoloji |
|-------|----------|
| Mobile | Flutter (Dart) |
| State Management | Riverpod / Bloc |
| Local Storage | Hive / Drift (SQLite) |
| Backend | Next.js (API Routes) |
| Database | PostgreSQL (Supabase) |
| Auth | Supabase Auth (Phone OTP) |
| Push | FCM (Firebase Cloud Messaging) |
| Analytics | Custom + PostHog |
| Ads Server | Custom Next.js API |
| Hosting | Vercel / Supabase |

---

## 10. Sonraki Adımlar

1. [ ] Flutter proje yapısı oluşturma
2. [ ] Supabase schema deployment
3. [ ] API endpoints geliştirme
4. [ ] Mobile app temel ekranlar
5. [ ] Offline sync implementasyonu
6. [ ] Ad server geliştirme
7. [ ] Esnaf dashboard
8. [ ] Beta testing

---

*Bu dokümantasyon DüğünDefteri için temel mimari referansıdır.*