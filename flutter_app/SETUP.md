# DüğünDefteri - Kurulum Talimatları

## ✅ Schema Status
Supabase database schema başarıyla çalıştırıldı!

## 📱 Flutter Kurulumu

### 1. Flutter'ı İndirin
```bash
# macOS
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
export PATH="$HOME/flutter/bin:$PATH"

# Linux
git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
export PATH="/opt/flutter/bin:$PATH"
```

### 2. Projeyi Açın
```bash
cd dugunler/flutter_app
```

### 3. Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### 4. Code Generation Çalıştırın
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Build Alın
```bash
flutter build apk --debug
# veya
flutter run
```

## 🔧 Bağımlılıklar (pubspec.yaml)

| Paket | Açıklama |
|-------|---------|
| flutter_riverpod | State management |
| supabase_flutter | Backend |
| drift | Offline SQLite |
| freezed | Data models |
| connectivity_plus | Internet kontrolü |

## 📋 Sonraki Adımlar

1. [x] Schema çalıştırıldı
2. [ ] Flutter kurulumu
3. [ ] flutter pub get
4. [ ] build_runner
5. [ ] Test etme

---

## 💻 Hızlı Başlangıç (VS Code)

1. VS Code açın
2. `flutter_app` klasörünü açın
3. Terminal: `flutter pub get`
4. `F5` ile çalıştırın