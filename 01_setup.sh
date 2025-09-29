#!/bin/bash

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

# --- BAGIAN BARU: Mendaftarkan Cron Job ---
echo "[INFO] Memeriksa dan mendaftarkan cron job untuk master_coordinator.py..."

# Menggunakan $(pwd) untuk mendapatkan path absolut, ini sangat penting untuk cron
CRON_JOB_COMMAND="/usr/bin/python $(pwd)/master_coordinator.py >> $(pwd)/cron.log 2>&1"
CRON_JOB_SCHEDULE="*/10 * * * *"
CRON_JOB_COMMENT="#Auto Update Directive" #
CRON_JOB_FULL="${CRON_JOB_SCHEDULE} ${CRON_JOB_COMMAND}"

# Cek apakah job sudah ada untuk menghindari duplikat
(crontab -l 2>/dev/null | grep -Fq "$CRON_JOB_COMMAND")
if [ $? -ne 0 ]; then
  # Tambahkan job baru (komentar + perintah) menggunakan metode yang aman
  (crontab -l 2>/dev/null; echo "$CRON_JOB_COMMENT"; echo "$CRON_JOB_FULL") | crontab -
  echo "[SUCCESS] Cron job dengan komentar berhasil ditambahkan."
else
  echo "[INFO] Cron job sudah ada, tidak ada perubahan."
fi
# -----------------------------------------

echo "[DANGER] Menghapus skrip ini (`$0`) sekarang..."
rm -- "$0"

echo "[SUCCESS] Selesai. File template dan cron job telah disiapkan."
echo "[SUCCESS] Fungsi disimpan pada file ${TEMPLATE_FILE}"
echo "[SUCCESS] Lanjutkan dengan menjalankan perintah 'python 02_pull-directive.py'"
