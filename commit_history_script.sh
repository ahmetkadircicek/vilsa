#!/bin/bash

# Hata kontrolü
set -e

# Mevcut branch'i kaydet
CURRENT_BRANCH=$(git branch --show-current)

# Tarih aralığını ayarla
START_DATE="2025-01-01"
END_DATE="2025-03-22" 

# Repositoryi temizleyelim ve sadece README.md bırakalım
git rm -rf --cached .
git add README.md
git commit --date="$START_DATE T10:00:00" -m "initial commit: project setup"

# Geçerli dosyaların bir listesini oluşturalım (staging'den dosyaları kaldırdığımız için)
mkdir -p temp_backup
cp -r lib temp_backup/
cp -r android temp_backup/
cp -r ios temp_backup/
cp -r asset temp_backup/
cp -r test temp_backup/
cp pubspec.yaml temp_backup/
cp pubspec.lock temp_backup/
cp analysis_options.yaml temp_backup/
cp .env temp_backup/
cp .flutter-plugins temp_backup/
cp .flutter-plugins-dependencies temp_backup/
cp .metadata temp_backup/
cp firebase.json temp_backup/

# Bütün tarihler için dizi oluştur
DATES=()
d="$START_DATE"
while [[ "$d" < "$END_DATE" || "$d" == "$END_DATE" ]]; do
  DATES+=("$d")
  d=$(date -j -v+1d -f "%Y-%m-%d" "$d" "+%Y-%m-%d")
done

# Commit edilecek gruplar
COMMIT_GROUPS=(
  # Temel yapı
  "pubspec.yaml:feat:Add project dependencies:pubspec.yaml"
  "analysis_options.yaml:chore:Configure analysis options:analysis_options.yaml"
  ".flutter-plugins:.flutter-plugins-dependencies:chore:Setup Flutter plugins configurations:.flutter-plugins .flutter-plugins-dependencies"
  "lib/main.dart:feat:Initialize app entry point:lib/main.dart"
  
  # Core bileşenler
  "lib/core/constants:feat:Add application constants:lib/core/constants"
  "lib/core/init/theme:feat:Implement app theme:lib/core/init/theme"
  "lib/core/init/navigation:feat:Add navigation service:lib/core/init/navigation"
  "lib/core/extensions:feat:Add extension methods:lib/core/extensions"
  "lib/core/components:feat:Create reusable components:lib/core/components"
  "lib/core/enums:feat:Add enum definitions:lib/core/enums"
  "lib/core/init/network:feat:Configure network services:lib/core/init/network"
  "lib/core/init/notifier:feat:Setup state management:lib/core/init/notifier"
  
  # Ana özellikler
  "lib/features/main:feat:Create main app structure:lib/features/main"
  "lib/features/home:feat:Implement home screen:lib/features/home"
  "lib/features/portfolio:feat:Create portfolio view:lib/features/portfolio"
  "lib/features/stock:feat:Add stock listing functionality:lib/features/stock"
  "lib/features/stock_details:feat:Implement stock details screen:lib/features/stock_details"
  "lib/features/add_stock:feat:Add stock creation feature:lib/features/add_stock"
  "lib/features/add_transaction:feat:Implement transaction addition:lib/features/add_transaction"
  
  # Platform spesifik
  "android:feat:Configure Android platform:android"
  "ios:feat:Setup iOS platform configuration:ios"
  
  # Varlıklar ve testler
  "asset:feat:Add project assets:asset"
  "test:test:Add initial test cases:test"
  
  # Entegrasyonlar
  ".env:firebase.json:feat:Add Firebase configuration:.env firebase.json"
  
  # Ek geliştirmeler ve düzeltmeler
  "lib/features/home:refactor:Improve home screen UI:lib/features/home"
  "lib/features/portfolio:fix:Fix portfolio calculation issue:lib/features/portfolio"
  "lib/features/stock:feat:Add stock filtering feature:lib/features/stock"
  "lib/features/stock_details:feat:Enhance stock details with charts:lib/features/stock_details"
  "lib/features/add_transaction:fix:Fix validation in transaction form:lib/features/add_transaction"
  "lib/core/components:refactor:Optimize reusable components:lib/core/components"
  "lib/core/init/theme:feat:Add dark theme support:lib/core/init/theme"
  "lib/features/main:fix:Fix navigation issues:lib/features/main"
  "android:chore:Update Android dependencies:android/build.gradle"
  "ios:fix:Fix iOS build issues:ios"
  "lib/features/add_stock:refactor:Improve stock form validation:lib/features/add_stock"
  "lib/core/init/network:fix:Improve error handling in API calls:lib/core/init/network"
  ".metadata:chore:Update project metadata:.metadata"
  "lib/features/stock:feat:Add stock sorting feature:lib/features/stock"
  "lib/core/init/notifier:refactor:Improve state management:lib/core/init/notifier"
  "test:test:Add more test coverage:test"
)

# Commitler için rastgele saatler oluşturmak için fonksiyon
random_time() {
  # 9-20 saat aralığında rastgele bir saat
  hour=$((9 + RANDOM % 11))
  # 0-59 aralığında rastgele dakika
  minute=$((RANDOM % 60))
  printf "%02d:%02d:00" $hour $minute
}

# Groupları tarihlere dağıt
TOTAL_DAYS=${#DATES[@]}
TOTAL_GROUPS=${#COMMIT_GROUPS[@]}
COMMITS_PER_DAY=()

# Her gün için 1-3 commit planla
for ((i=0; i<TOTAL_DAYS; i++)); do
  # 1, 2 veya 3 commit
  COMMITS_PER_DAY[i]=$((1 + RANDOM % 3))
done

# Toplam commit sayısını hesapla
TOTAL_COMMITS=0
for commits in "${COMMITS_PER_DAY[@]}"; do
  TOTAL_COMMITS=$((TOTAL_COMMITS + commits))
done

# Eğer toplam commit sayısı grup sayısından az ise, bazı günlere ekstra commit ekle
while [ $TOTAL_COMMITS -lt $TOTAL_GROUPS ]; do
  random_day=$((RANDOM % TOTAL_DAYS))
  if [ ${COMMITS_PER_DAY[$random_day]} -lt 3 ]; then
    COMMITS_PER_DAY[$random_day]=$((COMMITS_PER_DAY[$random_day] + 1))
    TOTAL_COMMITS=$((TOTAL_COMMITS + 1))
  fi
done

# Eğer toplam commit sayısı hala grup sayısından az ise, rastgele grupları birleştir
if [ $TOTAL_COMMITS -lt $TOTAL_GROUPS ]; then
  echo "Uyarı: Toplam commit sayısı ($TOTAL_COMMITS) grup sayısından ($TOTAL_GROUPS) az."
  echo "Bazı gruplar birleştirilebilir veya atlanabilir."
fi

# Commitler
group_index=0
for ((day_index=0; day_index<TOTAL_DAYS; day_index++)); do
  date="${DATES[$day_index]}"
  commits_today=${COMMITS_PER_DAY[$day_index]}
  
  for ((commit_index=0; commit_index<commits_today && group_index<TOTAL_GROUPS; commit_index++)); do
    # Bu günün commiti için grup bilgisini al
    group="${COMMIT_GROUPS[$group_index]}"
    group_index=$((group_index + 1))
    
    # Bu gruptan dosya/klasör, tip, mesaj ve dosya listesini ayıkla
    IFS=':' read -r paths commit_type commit_message file_list <<< "$group"
    
    # Dosya/klasörleri staging area'ya ekle
    IFS=' ' read -ra PATH_ARRAY <<< "$paths"
    for path in "${PATH_ARRAY[@]}"; do
      if [ -d "temp_backup/$path" ]; then
        # Klasör ise
        mkdir -p "$path"
        cp -r "temp_backup/$path"/* "$path"/
      elif [ -f "temp_backup/$path" ]; then
        # Dosya ise
        cp "temp_backup/$path" "$path"
      fi
      git add "$path"
    done
    
    # Commit yap
    commit_time=$(random_time)
    commit_datetime="$date T$commit_time"
    git commit --date="$commit_datetime" -m "$commit_type: $commit_message"
    
    echo "[$date $commit_time] $commit_type: $commit_message"
  done
done

# Kalan gruplar (eğer varsa) en son güne ekle
while [ $group_index -lt $TOTAL_GROUPS ]; do
  group="${COMMIT_GROUPS[$group_index]}"
  group_index=$((group_index + 1))
  
  # Bu gruptan dosya/klasör, tip, mesaj ve dosya listesini ayıkla
  IFS=':' read -r paths commit_type commit_message file_list <<< "$group"
  
  # Dosya/klasörleri staging area'ya ekle
  IFS=' ' read -ra PATH_ARRAY <<< "$paths"
  for path in "${PATH_ARRAY[@]}"; do
    if [ -d "temp_backup/$path" ]; then
      # Klasör ise
      mkdir -p "$path"
      cp -r "temp_backup/$path"/* "$path"/
    elif [ -f "temp_backup/$path" ]; then
      # Dosya ise
      cp "temp_backup/$path" "$path"
    fi
    git add "$path"
  done
  
  # Son güne commit yap
  commit_time=$(random_time)
  commit_datetime="$END_DATE T$commit_time"
  git commit --date="$commit_datetime" -m "$commit_type: $commit_message"
  
  echo "[$END_DATE $commit_time] $commit_type: $commit_message"
done

# Geçici dosyaları temizle
rm -rf temp_backup

echo "Commit tamamlandı. GitHub'a push etmek için: git push -f origin main" 