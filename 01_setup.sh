#!/bin/bash
# =========================================================
# Skrip untuk Mengatur Environment Variable SIEM
# 1. Mengekspor variabel ke environment sesi ini.
# 2. Membuat file template kosong (.template) untuk cron.
# 3. Mendaftarkan cron job dengan deteksi Python 3.
# 4. MENGHAPUS dirinya sendiri setelah selesai.
# =========================================================

echo "[INFO] Mengekspor kredensial ke environment..."

export GITHUB_TOKEN="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"
export GITHUB_REPO="narendrasaktip/siem-event-name-repository"
export GITHUB_BRANCH="main"
export ES_HOST="http://opensearch:9200"
export ES_PASSWD_FILE="/root/.passwd/es_passwd"
export ES_USER_LOOKUP="systemadm"
export EMAIL_SMTP_SERVER="smtp.gmail.com"
export EMAIL_SMTP_PORT="587"
export EMAIL_SENDER="narendra.prabawa@defenxor.com"
export EMAIL_APP_PASSWORD="okmx ulyc ynym vfln"
export EMAIL_RECIPIENTS="narendra.prabawa@defenxor.com,jose.alnevo@defenxor.com,muhammad.madani@defenxor.com,andi.wahyudi@defenxor.com,dims.ssa@defenxor.com,soc@defenxor.com"

# --- MEMBUAT FILE TEMPLATE ---
TEMPLATE_FILE="${0}.template"
echo "[INFO] Membuat file template kosong di ${TEMPLATE_FILE}..."
grep "^export" "$0" | sed 's/=\".*\"/=\"\"/' > "$TEMPLATE_FILE"
# -----------------------------------------

echo "[INFO] Semua variabel berhasil diekspor."

# --- BAGIAN CRON JOB YANG SUDAH DIPERBAIKI (FINAL) ---
echo "[INFO] Memeriksa dan mendaftarkan cron job untuk master_coordinator.py..."

# --- PATCH: Deteksi Python 3 secara dinamis ---
# Cari path absolut untuk python3, fallback ke python jika tidak ada
if command -v python3 &> /dev/null; then
    PYTHON_EXEC=$(command -v python3)
else
    echo "[WARN] python3 tidak ditemukan, mencoba menggunakan python."
    PYTHON_EXEC=$(command -v python)
fi
echo "[INFO] Python executable yang akan digunakan oleh cron: ${PYTHON_EXEC}"
# --- AKHIR DARI PATCH ---

# Dapatkan path absolut dari direktori proyek saat ini
PROJECT_DIR=$(pwd)
# Tentukan path absolut ke file template yang akan di-source oleh cron
TEMPLATE_FILE_FOR_CRON="${PROJECT_DIR}/01_setup.sh.template"

# Perintah cron: 1. Source file template, 2. Pindah direktori, 3. Jalankan skrip
CRON_JOB_COMMAND=". ${TEMPLATE_FILE_FOR_CRON} && cd ${PROJECT_DIR} && ${PYTHON_EXEC} master_coordinator.py >> ${PROJECT_DIR}/cron.log 2>&1"
CRON_JOB_SCHEDULE="*/10 * * * *"
CRON_JOB_COMMENT="#Auto Update Directive"

# Gabungkan jadwal dan perintah menjadi satu baris
CRON_JOB_FULL="${CRON_JOB_SCHEDULE} ${CRON_JOB_COMMAND}"

# Cek apakah job (khususnya bagian perintahnya) sudah ada untuk menghindari duplikat
(crontab -l 2>/dev/null | grep -Fq "$CRON_JOB_COMMAND")
if [ $? -ne 0 ]; then
  # Tambahkan komentar dan job baru menggunakan metode yang aman
  (crontab -l 2>/dev/null; echo "$CRON_JOB_COMMENT"; echo "$CRON_JOB_FULL") | crontab -
  echo "[SUCCESS] Cron job dengan komentar berhasil ditambahkan."
else
  echo "[INFO] Cron job sudah ada, tidak ada perubahan."
fi
# -----------------------------------------

echo "[DANGER] Menghapus skrip ini (\`$0\`) sekarang..."
rm -- "$0"

echo "[SUCCESS] Selesai. File template dan cron job telah disiapkan."
echo "[SUCCESS] Konfigurasi template disimpan pada file ${TEMPLATE_FILE}"
echo "[SUCCESS] Lanjutkan dengan menjalankan perintah 'python 02_pull-directive.py'"
