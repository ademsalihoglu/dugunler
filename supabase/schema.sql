-- =====================================================
-- DüğünDefteri - Supabase PostgreSQL Schema
-- Doğu ve Güneydoğu Anadolu Düğün Yönetim Platformu
-- =====================================================

-- =====================================================
-- ENUMS
-- =====================================================

CREATE TYPE gift_unit AS ENUM ('adet', 'gram', 'tl', 'dolar', 'euro');
CREATE TYPE wedding_status AS ENUM ('planlandi', 'aktif', 'tamamlandi', 'iptal');
CREATE TYPE invitation_status AS ENUM ('bekliyor', 'davet_edildi', 'katilacak', 'katilmayacak');
CREATE TYPE sync_status AS ENUM ('yerel_bekliyor', 'senkron_bekliyor', 'senkronize', 'hata');
CREATE TYPE ad_status AS ENUM ('bekliyor', 'aktif', 'pasif', 'reddedildi');

-- =====================================================
-- USERS (Kullanıcılar)
-- =====================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    profile_photo_url TEXT,
    birth_date DATE,
    region VARCHAR(50),
    city VARCHAR(50),
    about_me TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'
);

CREATE INDEX idx_users_region ON users(region);
CREATE INDEX idx_users_phone ON users(phone);

-- =====================================================
-- USER DEVICES (Push Bildirim için)
-- =====================================================

CREATE TABLE user_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    device_token VARCHAR(255) NOT NULL,
    device_type VARCHAR(20) NOT NULL,
    app_version VARCHAR(20),
    fcm_token VARCHAR(255),
    last_active_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_user_devices_token ON user_devices(device_token);

-- =====================================================
-- GIFT TYPES (Takı Türleri)
-- =====================================================

CREATE TABLE gift_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    unit gift_unit NOT NULL,
    icon VARCHAR(50),
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

INSERT INTO gift_types (name, code, unit, icon, display_order) VALUES
    ('Çeyrek Altın', 'QUARTER_GOLD', 'adet', '💍', 1),
    ('Yarım Altın', 'HALF_GOLD', 'adet', '💍', 2),
    ('Tam Altın', 'FULL_GOLD', 'adet', '💍', 3),
    ('Gram Altın', 'GRAM_GOLD', 'gram', '🥇', 4),
    ('Cumhuriyet Altını', 'REPUBLIC_GOLD', 'adet', '💰', 5),
    ('Beşli Altın', 'FIVE_GOLD', 'adet', '💎', 6),
    ('Dolar', 'USD', 'dolar', '💵', 7),
    ('Euro', 'EUR', 'euro', '💶', 8),
    ('Türk Lirası', 'TRY', 'tl', '₺', 9);

-- =====================================================
-- EXCHANGE RATES (Güncel Kurlar)
-- =====================================================

CREATE TABLE exchange_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    base_currency VARCHAR(10) NOT NULL,
    target_currency VARCHAR(10) NOT NULL,
    rate DECIMAL(20, 2) NOT NULL,
    fetched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_current BOOLEAN DEFAULT TRUE
);

CREATE UNIQUE INDEX idx_exchange_rates_current 
    ON exchange_rates(base_currency) 
    WHERE is_current = TRUE;

-- =====================================================
-- WEDDINGS (Düğünler)
-- =====================================================

CREATE TABLE weddings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    bride_name VARCHAR(100) NOT NULL,
    groom_name VARCHAR(100) NOT NULL,
    wedding_date DATE NOT NULL,
    wedding_time TIME NOT NULL,
    venue_name VARCHAR(200),
    venue_address TEXT,
    venue_latitude DECIMAL(10, 8),
    venue_longitude DECIMAL(11, 8),
    region VARCHAR(50),
    city VARCHAR(50),
    description TEXT,
    cover_image_url TEXT,
    status wedding_status DEFAULT 'planlandi',
    guest_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'
);

CREATE INDEX idx_weddings_owner ON weddings(owner_id);
CREATE INDEX idx_weddings_date ON weddings(wedding_date);
CREATE INDEX idx_weddings_region ON weddings(region);

-- =====================================================
-- WEDDING GUESTS (Düğün Konukları)
-- =====================================================

CREATE TABLE wedding_guests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES users(id),
    guest_name VARCHAR(100) NOT NULL,
    guest_phone VARCHAR(20),
    guest_email VARCHAR(100),
    relationship VARCHAR(50),
    relation_detail VARCHAR(100),
    invitation_status invitation_status DEFAULT 'bekliyor',
    will_attend BOOLEAN,
    party_size INTEGER DEFAULT 1,
    dietary_notes TEXT,
    address TEXT,
    note TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_wedding_guests_wedding ON wedding_guests(wedding_id);
CREATE INDEX idx_wedding_guests_user ON wedding_guests(user_id);

-- =====================================================
-- GIFTS (Takı Kayıtları)
-- =====================================================

CREATE TABLE gifts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE NOT NULL,
    guest_id UUID REFERENCES wedding_guests(id) ON DELETE SET NULL,
    gift_type_id UUID REFERENCES gift_types(id) NOT NULL,
    quantity DECIMAL(15, 3) NOT NULL,
    unit_value DECIMAL(15, 2) NOT NULL,
    total_try DECIMAL(15, 2) NOT NULL,
    current_try DECIMAL(15, 2),
    rate_id UUID REFERENCES exchange_rates(id),
    gift_date DATE NOT NULL,
    gift_time TIME NOT NULL,
    recorded_by UUID REFERENCES users(id),
    note TEXT,
    sync_status sync_status DEFAULT 'senkronize',
    local_id UUID,
    device_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_gifts_wedding ON gifts(wedding_id);
CREATE INDEX idx_gifts_guest ON gifts(guest_id);
CREATE INDEX idx_gifts_date ON gifts(gift_date);
CREATE INDEX idx_gifts_sync ON gifts(sync_status);

-- =====================================================
-- GIFT HISTORY (Takı Değer Geçmişi)
-- =====================================================

CREATE TABLE gift_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gift_id UUID REFERENCES gifts(id) ON DELETE CASCADE NOT NULL,
    previous_try DECIMAL(15, 2),
    new_try DECIMAL(15, 2),
    rate_id UUID REFERENCES exchange_rates(id),
    recalculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- INVITATIONS (Davetiyeler)
-- =====================================================

CREATE TABLE invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE NOT NULL,
    guest_id UUID REFERENCES wedding_guests(id) ON DELETE CASCADE NOT NULL,
    invitation_code VARCHAR(20) UNIQUE NOT NULL,
    sent_at TIMESTAMP WITH TIME ZONE,
    responded_at TIMESTAMP WITH TIME ZONE,
    response_message TEXT,
    is_confirmed BOOLEAN,
    party_size INTEGER DEFAULT 1,
    qr_code_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_invitations_code ON invitations(invitation_code);

-- =====================================================
-- RETURN VISITS (Geri Dönüş Takibi)
-- =====================================================

CREATE TABLE return_visits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    wedding_id UUID REFERENCES weddings(id) ON DELETE SET NULL,
    wedding_owner_id UUID REFERENCES users(id),
    gift_type_id UUID REFERENCES gift_types(id),
    gift_quantity DECIMAL(15, 3),
    gift_try DECIMAL(15, 2),
    gift_note TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_return_visits_user ON return_visits(user_id);

-- =====================================================
-- ADVERTISERS (Reklam Verenler)
-- =====================================================

CREATE TABLE advertisers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_user_id UUID REFERENCES users(id) NOT NULL,
    business_name VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL,
    sub_category VARCHAR(50),
    description TEXT,
    logo_url TEXT,
    cover_image_url TEXT,
    website_url TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    status ad_status DEFAULT 'bekliyor',
    balance DECIMAL(15, 2) DEFAULT 0.00,
    rating DECIMAL(3, 2) DEFAULT 0.00,
    review_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    verified_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}'
);

CREATE INDEX idx_advertisers_owner ON advertisers(owner_user_id);
CREATE INDEX idx_advertisers_category ON advertisers(category);

-- =====================================================
-- ADVERTISER LOCATIONS (Reklam Veren Şubeleri)
-- =====================================================

CREATE TABLE advertiser_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    advertiser_id UUID REFERENCES advertisers(id) ON DELETE CASCADE NOT NULL,
    location_name VARCHAR(200),
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    region VARCHAR(50),
    city VARCHAR(50),
    district VARCHAR(50),
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_advertiser_locations_advertiser ON advertiser_locations(advertiser_id);
CREATE INDEX idx_advertiser_locations_region ON advertiser_locations(region, city);

-- =====================================================
-- AD CAMPAIGNS (Reklam Kampanyaları)
-- =====================================================

CREATE TABLE ad_campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    advertiser_id UUID REFERENCES advertisers(id) ON DELETE CASCADE NOT NULL,
    name VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL,
    title VARCHAR(200),
    description TEXT,
    image_url TEXT,
    cta_text VARCHAR(50),
    cta_link TEXT,
    target_regions TEXT[],
    target_cities TEXT[],
    start_date DATE,
    end_date DATE,
    daily_budget DECIMAL(15, 2),
    total_budget DECIMAL(15, 2),
    cost_per_click DECIMAL(10, 4) DEFAULT 0.50,
    cost_per_view DECIMAL(10, 6) DEFAULT 0.01,
    status ad_status DEFAULT 'bekliyor',
    impressions_count INTEGER DEFAULT 0,
    clicks_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_ad_campaigns_advertiser ON ad_campaigns(advertiser_id);
CREATE INDEX idx_ad_campaigns_status ON ad_campaigns(status);

-- =====================================================
-- AD PLACEMENTS (Reklam Yerleşim Yerleri)
-- =====================================================

CREATE TABLE ad_placements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    width INTEGER DEFAULT 320,
    height INTEGER DEFAULT 100,
    format VARCHAR(20) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    min_bid DECIMAL(10, 4) DEFAULT 0.01
);

INSERT INTO ad_placements (name, description, width, height, format, min_bid) VALUES
    ('home_banner', 'Ana sayfa banner', 320, 100, 'banner', 0.10),
    ('calendar_header', 'Takvim üstü banner', 320, 50, 'banner', 0.05),
    ('calendar_interstitial', 'Takvim geçiş reklamı', 320, 480, 'interstitial', 0.25),
    ('gift_entry', 'Takı giriş reklamı', 320, 100, 'native', 0.15),
    ('guest_list', 'Davetli listesi reklamı', 320, 100, 'native', 0.15),
    ('return_list', 'Geri dönüş listesi reklamı', 320, 100, 'native', 0.15),
    ('wedding_detail', 'Düğün detay reklamı', 320, 100, 'banner', 0.10);

-- =====================================================
-- AD IMPRESSIONS (Reklam Gösterim Kayıtları)
-- =====================================================

CREATE TABLE ad_impressions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID REFERENCES ad_campaigns(id) ON DELETE SET NULL,
    placement_id UUID REFERENCES ad_placements(id) NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    wedding_id UUID REFERENCES weddings(id) ON DELETE SET NULL,
    impression_count INTEGER DEFAULT 1,
    is_clicked BOOLEAN DEFAULT FALSE,
    device_info JSONB,
    user_region VARCHAR(50),
    shown_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_ad_impressions_campaign ON ad_impressions(campaign_id);
CREATE INDEX idx_ad_impressions_shown_at ON ad_impressions(shown_at);

-- =====================================================
-- AD STATISTICS (Aggrege Rekam İstatistikleri)
-- =====================================================

CREATE TABLE ad_statistics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID REFERENCES ad_campaigns(id) ON DELETE CASCADE,
    placement_id UUID REFERENCES ad_placements(id),
    date DATE NOT NULL,
    impressions INTEGER DEFAULT 0,
    clicks INTEGER DEFAULT 0,
    views INTEGER DEFAULT 0,
    spend DECIMAL(15, 2) DEFAULT 0.00,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(campaign_id, placement_id, date)
);

-- =====================================================
-- SYNC QUEUE (Offline Senkronizasyon Kuyruğu)
-- =====================================================

CREATE TABLE sync_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id UUID NOT NULL,
    operation VARCHAR(20) NOT NULL,
    old_data JSONB,
    new_data JSONB,
    retry_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    synced_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'bekliyor'
);

CREATE INDEX idx_sync_queue_user ON sync_queue(user_id, status);
CREATE INDEX idx_sync_queue_created ON sync_queue(created_at);

-- =====================================================
-- NOTIFICATION TEMPLATES (Bildirim Şablonları)
-- =====================================================

CREATE TABLE notification_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title_template TEXT NOT NULL,
    body_template TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    action_type VARCHAR(50),
    action_data JSONB,
    is_active BOOLEAN DEFAULT TRUE
);

-- =====================================================
-- NOTIFICATIONS (Kullanıcı Bildirimleri)
-- =====================================================

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type VARCHAR(50),
    data JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id, is_read);

-- =====================================================
-- PUSH QUEUE (Push Bildirim Kuyruğu)
-- =====================================================

CREATE TABLE push_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    data JSONB,
    scheduled_at TIMESTAMP WITH TIME ZONE,
    sent_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'bekliyor',
    retry_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_push_queue_user_status ON push_queue(user_id, status);

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_gifts_updated_at
    BEFORE UPDATE ON gifts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_weddings_updated_at
    BEFORE UPDATE ON weddings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- =====================================================
-- KUR HESAPLAMA FONKSİYONU
-- =====================================================

CREATE OR REPLACE FUNCTION calculate_gift_try(
    p_gift_type_id UUID,
    p_quantity DECIMAL
)
RETURNS DECIMAL AS $$
DECLARE
    v_gift_type record;
    v_result DECIMAL(15, 2) := 0;
    v_rate record;
BEGIN
    SELECT * INTO v_gift_type FROM gift_types WHERE id = p_gift_type_id;
    IF v_gift_type IS NULL THEN RETURN 0; END IF;
    
    IF v_gift_type.code IN ('QUARTER_GOLD', 'HALF_GOLD', 'FULL_GOLD', 'REPUBLIC_GOLD', 'FIVE_GOLD') THEN
        SELECT rate INTO v_rate FROM exchange_rates WHERE base_currency = 'GOLD' AND is_current = TRUE;
        IF v_rate IS NOT NULL THEN v_result := p_quantity * v_rate.rate * 0.75; END IF;
    ELSIF v_gift_type.code = 'GRAM_GOLD' THEN
        SELECT rate INTO v_rate FROM exchange_rates WHERE base_currency = 'GOLD' AND is_current = TRUE;
        IF v_rate IS NOT NULL THEN v_result := p_quantity * v_rate.rate; END IF;
    ELSIF v_gift_type.code = 'USD' THEN
        SELECT rate INTO v_rate FROM exchange_rates WHERE base_currency = 'USD' AND is_current = TRUE;
        IF v_rate IS NOT NULL THEN v_result := p_quantity * v_rate.rate; END IF;
    ELSIF v_gift_type.code = 'EUR' THEN
        SELECT rate INTO v_rate FROM exchange_rates WHERE base_currency = 'EUR' AND is_current = TRUE;
        IF v_rate IS NOT NULL THEN v_result := p_quantity * v_rate.rate; END IF;
    ELSIF v_gift_type.code = 'TRY' THEN
        v_result := p_quantity;
    END IF;
    RETURN ROUND(v_result::numeric, 2);
END;
$$ LANGUAGE plpgsql;