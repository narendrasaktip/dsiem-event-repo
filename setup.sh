#!/bin/bash

# Dapatkan path absolut dari direktori proyek saat ini
PROJECT_DIR=$(pwd)
# Tentukan nama file environment yang BERBEDA dari skrip ini
CRON_ENV_FILE="${PROJECT_DIR}/config.sh"

# --- 1. Buat File Konfigurasi untuk Cron ---
echo "Membuat file environment di ${CRON_ENV_FILE}..."
cat <<EOF > "${CRON_ENV_FILE}"
#!/bin/bash
# File ini berisi environment variable untuk cron job SIEM
# Dibuat secara otomatis oleh skrip setup.

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
EOF

# Deteksi path Python 3 secara dinamis
if command -v python3 &> /dev/null; then
    PYTHON_EXEC=$(command -v python3)
else
    PYTHON_EXEC=$(command -v python)
fi

# Perintah cron: 1. Source file config, 2. Pindah direktori, 3. Jalankan skrip Python
CRON_JOB_COMMAND=". ${CRON_ENV_FILE} && cd ${PROJECT_DIR} && ${PYTHON_EXEC} master_coordinator.py >> ${PROJECT_DIR}/cron.log 2>&1"
CRON_JOB_SCHEDULE="*/10 * * * *"
CRON_JOB_COMMENT="#Auto Update Directive SIEM"

# Gabungkan jadwal dan perintah menjadi satu baris
CRON_JOB_FULL="${CRON_JOB_SCHEDULE} ${CRON_JOB_COMMAND}"

# Cek apakah job (berdasarkan perintahnya) sudah ada untuk menghindari duplikat
if ! crontab -l 2>/dev/null | grep -Fq "$CRON_JOB_COMMAND"; then
    echo "Pekerjaan cron belum ada. Menambahkan..."
    # [PERBAIKAN] Tambahkan 'echo ""' untuk membuat baris kosong
    (crontab -l 2>/dev/null; echo ""; echo "$CRON_JOB_COMMENT"; echo "$CRON_JOB_FULL") | crontab -
    echo "Pekerjaan cron berhasil ditambahkan."
else
    echo "Pekerjaan cron sudah ada. Melewati penambahan."
fi