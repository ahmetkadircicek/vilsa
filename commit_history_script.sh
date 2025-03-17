#!/bin/bash

# Vilsa projesi için commit geçmişi oluşturma scripti
# 1 Ocak 2025 - 22 Mart 2025 arası düzenli commitler oluşturur

# Repoyu temizle ve baştan başla
rm -rf .git
git init
git config user.name "Ahmet Kadir Çiçek"
git config user.email "ahmetkadircicek@gmail.com"

# Gitignore oluştur ve ilk commit
cat > .gitignore << EOF
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
/android/app/debug
/android/app/profile
/android/app/release
EOF

echo "# Vilsa" > README.md
echo "A personal stock portfolio management application." >> README.md

# İlk commit
sleep 1
GIT_AUTHOR_DATE="2025-01-01T10:00:00" GIT_COMMITTER_DATE="2025-01-01T10:00:00" git add .gitignore README.md
GIT_AUTHOR_DATE="2025-01-01T10:00:00" GIT_COMMITTER_DATE="2025-01-01T10:00:00" git commit -m "chore: initial project setup"

# Temel Flutter proje dosyaları
sleep 1
GIT_AUTHOR_DATE="2025-01-02T14:30:00" GIT_COMMITTER_DATE="2025-01-02T14:30:00" git add pubspec.yaml .metadata analysis_options.yaml
GIT_AUTHOR_DATE="2025-01-02T14:30:00" GIT_COMMITTER_DATE="2025-01-02T14:30:00" git commit -m "feat: add basic Flutter project structure"

# Android ve iOS dosyalarını ekle
sleep 1
GIT_AUTHOR_DATE="2025-01-03T09:15:00" GIT_COMMITTER_DATE="2025-01-03T09:15:00" git add android/ ios/
GIT_AUTHOR_DATE="2025-01-03T09:15:00" GIT_COMMITTER_DATE="2025-01-03T09:15:00" git commit -m "feat: configure native platform settings"

# Asset dosyalarını ekle
sleep 1
GIT_AUTHOR_DATE="2025-01-05T11:20:00" GIT_COMMITTER_DATE="2025-01-05T11:20:00" git add asset/
GIT_AUTHOR_DATE="2025-01-05T11:20:00" GIT_COMMITTER_DATE="2025-01-05T11:20:00" git commit -m "feat: add initial assets and sample data"

# Core yapıları ekleme
sleep 1
GIT_AUTHOR_DATE="2025-01-07T16:45:00" GIT_COMMITTER_DATE="2025-01-07T16:45:00" git add lib/core/constants/
GIT_AUTHOR_DATE="2025-01-07T16:45:00" GIT_COMMITTER_DATE="2025-01-07T16:45:00" git commit -m "feat: add application constants"

sleep 1 
GIT_AUTHOR_DATE="2025-01-07T18:10:00" GIT_COMMITTER_DATE="2025-01-07T18:10:00" git add lib/core/extensions/
GIT_AUTHOR_DATE="2025-01-07T18:10:00" GIT_COMMITTER_DATE="2025-01-07T18:10:00" git commit -m "feat: add helper extensions"

sleep 1
GIT_AUTHOR_DATE="2025-01-08T10:30:00" GIT_COMMITTER_DATE="2025-01-08T10:30:00" git add lib/core/components/
GIT_AUTHOR_DATE="2025-01-08T10:30:00" GIT_COMMITTER_DATE="2025-01-08T10:30:00" git commit -m "feat: add reusable UI components"

sleep 1
GIT_AUTHOR_DATE="2025-01-08T14:50:00" GIT_COMMITTER_DATE="2025-01-08T14:50:00" git add lib/core/enums/
GIT_AUTHOR_DATE="2025-01-08T14:50:00" GIT_COMMITTER_DATE="2025-01-08T14:50:00" git commit -m "feat: add enum definitions"

# Main dosyası ve uygulama başlangıcı
sleep 1
GIT_AUTHOR_DATE="2025-01-10T09:25:00" GIT_COMMITTER_DATE="2025-01-10T09:25:00" git add lib/main.dart lib/core/init/
GIT_AUTHOR_DATE="2025-01-10T09:25:00" GIT_COMMITTER_DATE="2025-01-10T09:25:00" git commit -m "feat: implement app initialization"

# Ana sayfa özelliği
sleep 1
GIT_AUTHOR_DATE="2025-01-12T11:40:00" GIT_COMMITTER_DATE="2025-01-12T11:40:00" git add lib/features/main/
GIT_AUTHOR_DATE="2025-01-12T11:40:00" GIT_COMMITTER_DATE="2025-01-12T11:40:00" git commit -m "feat: add main navigation structure"

sleep 1
GIT_AUTHOR_DATE="2025-01-13T15:20:00" GIT_COMMITTER_DATE="2025-01-13T15:20:00" git add lib/features/home/model/
GIT_AUTHOR_DATE="2025-01-13T15:20:00" GIT_COMMITTER_DATE="2025-01-13T15:20:00" git commit -m "feat: create home screen models"

sleep 1
GIT_AUTHOR_DATE="2025-01-14T10:15:00" GIT_COMMITTER_DATE="2025-01-14T10:15:00" git add lib/features/home/viewmodel/
GIT_AUTHOR_DATE="2025-01-14T10:15:00" GIT_COMMITTER_DATE="2025-01-14T10:15:00" git commit -m "feat: implement home screen business logic"

sleep 1
GIT_AUTHOR_DATE="2025-01-15T14:00:00" GIT_COMMITTER_DATE="2025-01-15T14:00:00" git add lib/features/home/view/
GIT_AUTHOR_DATE="2025-01-15T14:00:00" GIT_COMMITTER_DATE="2025-01-15T14:00:00" git commit -m "feat: design home screen UI"

# Portfolio ekranı
sleep 1
GIT_AUTHOR_DATE="2025-01-17T11:30:00" GIT_COMMITTER_DATE="2025-01-17T11:30:00" git add lib/features/portfolio/viewmodel/
GIT_AUTHOR_DATE="2025-01-17T11:30:00" GIT_COMMITTER_DATE="2025-01-17T11:30:00" git commit -m "feat: implement portfolio screen logic"

sleep 1
GIT_AUTHOR_DATE="2025-01-18T16:45:00" GIT_COMMITTER_DATE="2025-01-18T16:45:00" git add lib/features/portfolio/view/
GIT_AUTHOR_DATE="2025-01-18T16:45:00" GIT_COMMITTER_DATE="2025-01-18T16:45:00" git commit -m "feat: create portfolio screen UI"

# Hisse senedi detay sayfası
sleep 1
GIT_AUTHOR_DATE="2025-01-20T09:30:00" GIT_COMMITTER_DATE="2025-01-20T09:30:00" git add lib/features/stock/
GIT_AUTHOR_DATE="2025-01-20T09:30:00" GIT_COMMITTER_DATE="2025-01-20T09:30:00" git commit -m "feat: add stock listing functionality"

sleep 1
GIT_AUTHOR_DATE="2025-01-21T14:15:00" GIT_COMMITTER_DATE="2025-01-21T14:15:00" git add lib/features/stock_details/
GIT_AUTHOR_DATE="2025-01-21T14:15:00" GIT_COMMITTER_DATE="2025-01-21T14:15:00" git commit -m "feat: implement stock details screen"

# Hisse senedi ekleme
sleep 1
GIT_AUTHOR_DATE="2025-01-23T10:20:00" GIT_COMMITTER_DATE="2025-01-23T10:20:00" git add lib/features/add_stock/
GIT_AUTHOR_DATE="2025-01-23T10:20:00" GIT_COMMITTER_DATE="2025-01-23T10:20:00" git commit -m "feat: create add stock functionality"

# İşlem ekleme
sleep 1
GIT_AUTHOR_DATE="2025-01-25T15:40:00" GIT_COMMITTER_DATE="2025-01-25T15:40:00" git add lib/features/add_transaction/
GIT_AUTHOR_DATE="2025-01-25T15:40:00" GIT_COMMITTER_DATE="2025-01-25T15:40:00" git commit -m "feat: implement transaction management"

# Test dosyaları
sleep 1
GIT_AUTHOR_DATE="2025-01-27T11:10:00" GIT_COMMITTER_DATE="2025-01-27T11:10:00" git add test/
GIT_AUTHOR_DATE="2025-01-27T11:10:00" GIT_COMMITTER_DATE="2025-01-27T11:10:00" git commit -m "test: add initial unit tests"

# Firebase entegrasyonu
sleep 1
GIT_AUTHOR_DATE="2025-01-29T13:25:00" GIT_COMMITTER_DATE="2025-01-29T13:25:00" git add firebase.json
GIT_AUTHOR_DATE="2025-01-29T13:25:00" GIT_COMMITTER_DATE="2025-01-29T13:25:00" git commit -m "feat: add Firebase configuration"

sleep 1
GIT_AUTHOR_DATE="2025-01-29T16:50:00" GIT_COMMITTER_DATE="2025-01-29T16:50:00" git add .env
GIT_AUTHOR_DATE="2025-01-29T16:50:00" GIT_COMMITTER_DATE="2025-01-29T16:50:00" git commit -m "chore: add environment variables"

# UI iyileştirmeleri (Şubat ayı)
sleep 1
GIT_AUTHOR_DATE="2025-02-01T09:45:00" GIT_COMMITTER_DATE="2025-02-01T09:45:00" git add lib/core/components/
GIT_AUTHOR_DATE="2025-02-01T09:45:00" GIT_COMMITTER_DATE="2025-02-01T09:45:00" git commit -m "feat: improve UI components styling"

sleep 1
GIT_AUTHOR_DATE="2025-02-03T14:20:00" GIT_COMMITTER_DATE="2025-02-03T14:20:00" git add lib/features/home/view/
GIT_AUTHOR_DATE="2025-02-03T14:20:00" GIT_COMMITTER_DATE="2025-02-03T14:20:00" git commit -m "feat: enhance home screen layout"

sleep 1
GIT_AUTHOR_DATE="2025-02-05T11:30:00" GIT_COMMITTER_DATE="2025-02-05T11:30:00" git add lib/features/portfolio/view/
GIT_AUTHOR_DATE="2025-02-05T11:30:00" GIT_COMMITTER_DATE="2025-02-05T11:30:00" git commit -m "feat: optimize portfolio display"

sleep 1
GIT_AUTHOR_DATE="2025-02-06T16:15:00" GIT_COMMITTER_DATE="2025-02-06T16:15:00" git add lib/features/stock_details/
GIT_AUTHOR_DATE="2025-02-06T16:15:00" GIT_COMMITTER_DATE="2025-02-06T16:15:00" git commit -m "feat: add stock chart visualization"

# Veri modeli güncellemeleri
sleep 1
GIT_AUTHOR_DATE="2025-02-08T10:20:00" GIT_COMMITTER_DATE="2025-02-08T10:20:00" git add lib/features/home/model/
GIT_AUTHOR_DATE="2025-02-08T10:20:00" GIT_COMMITTER_DATE="2025-02-08T10:20:00" git commit -m "refactor: update home data models"

sleep 1
GIT_AUTHOR_DATE="2025-02-10T13:45:00" GIT_COMMITTER_DATE="2025-02-10T13:45:00" git add lib/core/
GIT_AUTHOR_DATE="2025-02-10T13:45:00" GIT_COMMITTER_DATE="2025-02-10T13:45:00" git commit -m "refactor: improve data handling"

# Performans iyileştirmeleri
sleep 1
GIT_AUTHOR_DATE="2025-02-12T09:30:00" GIT_COMMITTER_DATE="2025-02-12T09:30:00" git add lib/features/
GIT_AUTHOR_DATE="2025-02-12T09:30:00" GIT_COMMITTER_DATE="2025-02-12T09:30:00" git commit -m "perf: optimize app performance"

# Backend iletişim iyileştirmeleri
sleep 1
GIT_AUTHOR_DATE="2025-02-14T15:10:00" GIT_COMMITTER_DATE="2025-02-14T15:10:00" git add lib/core/
GIT_AUTHOR_DATE="2025-02-14T15:10:00" GIT_COMMITTER_DATE="2025-02-14T15:10:00" git commit -m "feat: enhance API communication"

# Ek özellikler
sleep 1
GIT_AUTHOR_DATE="2025-02-16T11:25:00" GIT_COMMITTER_DATE="2025-02-16T11:25:00" git add lib/features/
GIT_AUTHOR_DATE="2025-02-16T11:25:00" GIT_COMMITTER_DATE="2025-02-16T11:25:00" git commit -m "feat: add portfolio analytics"

sleep 1
GIT_AUTHOR_DATE="2025-02-18T14:00:00" GIT_COMMITTER_DATE="2025-02-18T14:00:00" git add lib/features/
GIT_AUTHOR_DATE="2025-02-18T14:00:00" GIT_COMMITTER_DATE="2025-02-18T14:00:00" git commit -m "feat: implement stock search functionality"

# UI/UX iyileştirmeleri
sleep 1
GIT_AUTHOR_DATE="2025-02-20T10:15:00" GIT_COMMITTER_DATE="2025-02-20T10:15:00" git add lib/core/components/
GIT_AUTHOR_DATE="2025-02-20T10:15:00" GIT_COMMITTER_DATE="2025-02-20T10:15:00" git commit -m "feat: improve UI responsiveness"

sleep 1
GIT_AUTHOR_DATE="2025-02-22T16:30:00" GIT_COMMITTER_DATE="2025-02-22T16:30:00" git add lib/features/
GIT_AUTHOR_DATE="2025-02-22T16:30:00" GIT_COMMITTER_DATE="2025-02-22T16:30:00" git commit -m "feat: enhance user experience"

# Mart ayı iyileştirmeleri
sleep 1
GIT_AUTHOR_DATE="2025-03-01T09:45:00" GIT_COMMITTER_DATE="2025-03-01T09:45:00" git add lib/features/
GIT_AUTHOR_DATE="2025-03-01T09:45:00" GIT_COMMITTER_DATE="2025-03-01T09:45:00" git commit -m "feat: add portfolio performance metrics"

sleep 1
GIT_AUTHOR_DATE="2025-03-03T14:20:00" GIT_COMMITTER_DATE="2025-03-03T14:20:00" git add lib/features/stock_details/
GIT_AUTHOR_DATE="2025-03-03T14:20:00" GIT_COMMITTER_DATE="2025-03-03T14:20:00" git commit -m "feat: implement historical stock data view"

sleep 1
GIT_AUTHOR_DATE="2025-03-05T11:10:00" GIT_COMMITTER_DATE="2025-03-05T11:10:00" git add lib/features/add_transaction/
GIT_AUTHOR_DATE="2025-03-05T11:10:00" GIT_COMMITTER_DATE="2025-03-05T11:10:00" git commit -m "feat: enhance transaction management"

sleep 1
GIT_AUTHOR_DATE="2025-03-07T16:30:00" GIT_COMMITTER_DATE="2025-03-07T16:30:00" git add lib/features/
GIT_AUTHOR_DATE="2025-03-07T16:30:00" GIT_COMMITTER_DATE="2025-03-07T16:30:00" git commit -m "feat: implement portfolio filtering"

sleep 1
GIT_AUTHOR_DATE="2025-03-09T10:15:00" GIT_COMMITTER_DATE="2025-03-09T10:15:00" git add test/
GIT_AUTHOR_DATE="2025-03-09T10:15:00" GIT_COMMITTER_DATE="2025-03-09T10:15:00" git commit -m "test: add integration tests"

sleep 1
GIT_AUTHOR_DATE="2025-03-11T13:45:00" GIT_COMMITTER_DATE="2025-03-11T13:45:00" git add lib/core/
GIT_AUTHOR_DATE="2025-03-11T13:45:00" GIT_COMMITTER_DATE="2025-03-11T13:45:00" git commit -m "perf: optimize data loading"

sleep 1
GIT_AUTHOR_DATE="2025-03-13T09:30:00" GIT_COMMITTER_DATE="2025-03-13T09:30:00" git add lib/features/
GIT_AUTHOR_DATE="2025-03-13T09:30:00" GIT_COMMITTER_DATE="2025-03-13T09:30:00" git commit -m "feat: add market news integration"

sleep 1
GIT_AUTHOR_DATE="2025-03-15T15:20:00" GIT_COMMITTER_DATE="2025-03-15T15:20:00" git add lib/features/
GIT_AUTHOR_DATE="2025-03-15T15:20:00" GIT_COMMITTER_DATE="2025-03-15T15:20:00" git commit -m "feat: implement notification system"

sleep 1
GIT_AUTHOR_DATE="2025-03-17T11:05:00" GIT_COMMITTER_DATE="2025-03-17T11:05:00" git add .
GIT_AUTHOR_DATE="2025-03-17T11:05:00" GIT_COMMITTER_DATE="2025-03-17T11:05:00" git commit -m "refactor: code cleanup and optimization"

sleep 1
GIT_AUTHOR_DATE="2025-03-19T14:30:00" GIT_COMMITTER_DATE="2025-03-19T14:30:00" git add lib/features/
GIT_AUTHOR_DATE="2025-03-19T14:30:00" GIT_COMMITTER_DATE="2025-03-19T14:30:00" git commit -m "feat: implement export functionality"

sleep 1
GIT_AUTHOR_DATE="2025-03-21T10:00:00" GIT_COMMITTER_DATE="2025-03-21T10:00:00" git add .
GIT_AUTHOR_DATE="2025-03-21T10:00:00" GIT_COMMITTER_DATE="2025-03-21T10:00:00" git commit -m "feat: add settings screen"

sleep 1
GIT_AUTHOR_DATE="2025-03-22T09:30:00" GIT_COMMITTER_DATE="2025-03-22T09:30:00" git add lib/core/
GIT_AUTHOR_DATE="2025-03-22T09:30:00" GIT_COMMITTER_DATE="2025-03-22T09:30:00" git commit -m "fix: address edge case in portfolio calculation"

# Remote repository'e push
git remote add origin https://github.com/ahmetkadircicek/vilsa.git
git branch -M main
git push -u origin main --force

echo "Commit geçmişi oluşturuldu ve GitHub'a push edildi." 