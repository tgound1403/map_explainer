# Hướng Dẫn Gitignore

## Các File Nên Commit

### 1. Configuration Files
- ✅ `.fvmrc` - FVM version config (quan trọng cho team)
- ✅ `devtools_options.yaml` - DevTools config (nếu team muốn share)
- ✅ `l10n.yaml` - Localization config
- ✅ `pubspec.yaml` - Dependencies

### 2. Source Code
- ✅ `lib/**/*.dart` - Tất cả source code
- ✅ `assets/**` - Assets files
- ✅ `test/**` - Test files (nếu có)

### 3. Documentation
- ✅ `*.md` - Documentation files
- ✅ `BUILD_INSTRUCTIONS.md`
- ✅ `CHANGELOG.md`
- ✅ `COMMIT_GUIDE.md`
- ✅ `QUICK_COMMIT.md`

### 4. Scripts
- ✅ `*.sh` - Shell scripts
- ✅ `commit_by_feature.sh`
- ✅ `commit_features.sh`

### 5. Localization Files
- ✅ `lib/l10n/app_*.arb` - ARB translation files
- ⚠️ `lib/l10n/app_localizations*.dart` - Generated files (có thể commit hoặc ignore)

## Các File Nên Ignore (Đã thêm vào .gitignore)

### 1. Build Artifacts
- ❌ `android/app/.cxx/` - Android build cache
- ❌ `ios/build/` - iOS build artifacts
- ❌ `**/build/` - Tất cả build folders

### 2. Generated Files
- ❌ `*.g.dart` - JSON serialization (đã có)
- ❌ `*.freezed.dart` - Freezed code generation (đã có)
- ⚠️ `lib/l10n/app_localizations*.dart` - Generated localization (có thể ignore)

### 3. IDE Settings (Personal)
- ❌ `.vscode/settings.json` - VS Code personal settings
- ✅ `.vscode/launch.json` - Launch configs (có thể commit nếu team muốn)

### 4. Environment Files
- ❌ `.env` - Environment variables (đã có)

## Quyết Định Cho Generated Localization Files

Có 2 cách:

### Cách 1: Commit Generated Files (Khuyến nghị cho team nhỏ)
- ✅ Dễ setup cho developer mới
- ✅ Không cần chạy `flutter gen-l10n` để build
- ❌ Có thể conflict khi merge

**Cách làm:**
```bash
git add lib/l10n/app_localizations*.dart
git commit -m "chore: add generated localization files"
```

### Cách 2: Ignore Generated Files (Khuyến nghị cho team lớn)
- ✅ Tránh conflict
- ✅ Đảm bảo mọi người chạy gen-l10n
- ❌ Developer mới cần setup thêm

**Cách làm:**
Thêm vào `.gitignore`:
```
lib/l10n/app_localizations*.dart
```

## Lệnh Để Commit Các File Còn Lại

```bash
# 1. Configuration files
git add .fvmrc
git add devtools_options.yaml
git commit -m "chore: add FVM and DevTools configuration"

# 2. Test files (nếu có)
git add test/
git commit -m "test: add test files"

# 3. Documentation và scripts
git add *.md *.sh
git commit -m "docs: add documentation and commit scripts"

# 4. Generated localization files (nếu muốn commit)
git add lib/l10n/app_localizations*.dart
git commit -m "chore: add generated localization files"
```

## Kiểm Tra File Nào Sẽ Được Commit

```bash
# Xem tất cả file untracked
git status

# Xem file nào sẽ được add (sau khi update .gitignore)
git status --short

# Test xem file có bị ignore không
git check-ignore -v <file_path>
```
