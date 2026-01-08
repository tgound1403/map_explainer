# Hướng Dẫn Setup Localization

## Bước 1: Generate Localization Code

Sau khi thêm localization, bạn cần generate code:

```bash
flutter pub get
flutter gen-l10n
```

Hoặc nếu `flutter gen-l10n` không hoạt động:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

Lệnh này sẽ tạo file:
- `lib/.dart_tool/flutter_gen/gen_l10n/app_localizations.dart`
- `lib/.dart_tool/flutter_gen/gen_l10n/app_localizations_en.dart`
- `lib/.dart_tool/flutter_gen/gen_l10n/app_localizations_vi.dart`

## Bước 2: Cấu Trúc Files

```
lib/
  l10n/
    app_en.arb  # English translations
    app_vi.arb  # Vietnamese translations
```

## Bước 3: Sử Dụng Localization

Trong code, sử dụng:

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Lấy localization
final l10n = AppLocalizations.of(context);

// Sử dụng
Text(l10n?.appTitle ?? 'AI Map Explainer')
```

## Bước 4: Thay Đổi Ngôn Ngữ

Ngôn ngữ có thể được thay đổi qua:
- Language switcher trong General View (icon language ở góc trên bên phải)
- LocaleProvider sẽ tự động lưu preference

## Lưu Ý

- File ARB phải có cùng các keys
- Keys với placeholders cần có `@key` với `placeholders` definition
- Sau khi thêm/sửa ARB files, cần chạy lại `flutter gen-l10n`

## Thêm Key Mới

1. Thêm key vào `app_en.arb` (template file)
2. Thêm translation tương ứng vào `app_vi.arb`
3. Chạy `flutter gen-l10n`
4. Sử dụng trong code: `AppLocalizations.of(context)?.yourKey`
