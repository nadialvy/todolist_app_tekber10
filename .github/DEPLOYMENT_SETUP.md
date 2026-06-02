# Deployment Pipeline Setup (Person 3)

Dokumentasi setup untuk dev & production deployment pipelines, rollback mechanism, dan email notifications.

---

## Workflows

| File | Trigger | Fungsi |
|------|---------|--------|
| `deploy-dev.yml` | push ke `dev` | Build + deploy ke GCS dev bucket |
| `deploy-prod.yml` | push ke `main` | Build + deploy ke GCS prod bucket |
| `rollback.yml` | manual (`workflow_dispatch`) | Restore deployment ke versi sebelumnya |

---

## Required GitHub Secrets

Tambahkan di **Settings → Secrets and variables → Actions → Repository secrets**.

### GCP (koordinasi dengan Person 1)

| Secret | Contoh | Keterangan |
|--------|--------|------------|
| `GCP_WIF_PROVIDER` | `projects/123.../providers/...` | Workload Identity Federation provider |
| `GCP_SA_EMAIL` | `sa@project.iam.gserviceaccount.com` | Service account email |
| `GCP_DEV_BUCKET` | `todolist-tekber-dev` | Nama GCS bucket untuk dev |
| `GCP_PROD_BUCKET` | `todolist-tekber-prod` | Nama GCS bucket untuk production |

### App env vars (per environment)

| Secret | Keterangan |
|--------|------------|
| `DEV_OPENAI_API_KEY` | OpenAI API key untuk environment dev |
| `PROD_OPENAI_API_KEY` | OpenAI API key untuk environment production |

### Email notifications (Gmail SMTP)

| Secret | Contoh | Keterangan |
|--------|--------|------------|
| `SMTP_USERNAME` | `team@gmail.com` | Gmail address pengirim |
| `SMTP_PASSWORD` | `xxxx xxxx xxxx xxxx` | **Gmail App Password** (bukan password biasa) |
| `NOTIFY_EMAILS` | `a@mail.com,b@mail.com` | Penerima notifikasi, pisah koma |

### Cara buat Gmail App Password

1. Buka [Google Account → Security](https://myaccount.google.com/security)
2. Aktifkan **2-Step Verification** jika belum
3. Cari **App passwords** → buat baru (pilih "Mail" + "Other")
4. Salin 16-karakter password yang muncul → masukkan ke secret `SMTP_PASSWORD`

---

## Struktur bucket GCS

Setiap bucket (dev & prod) menggunakan layout berikut:

```
gs://BUCKET_NAME/
├── current/          ← Deployment aktif (yang di-serve CDN)
└── releases/
    ├── 20260601120000/
    │   ├── index.html
    │   ├── ...
    │   └── manifest.json   ← {sha, ref, actor, timestamp, run_id}
    └── 20260602080000/
        └── ...
```

Setiap deployment otomatis mem-backup versi `current/` ke `releases/TIMESTAMP/` sebelum deploy baru.

---

## Cara rollback

1. Buka **Actions** → **Rollback Deployment** → **Run workflow**
2. Pilih environment (`dev` atau `production`)
3. Isi `release_timestamp` — jika dikosongkan, workflow akan **list available releases**
4. Klik **Run workflow**

Rollback juga akan mem-backup state saat ini (ke `releases/pre-rollback-TIMESTAMP`) sebelum restore, sebagai safety net.

---

## Email notification

Dikirim otomatis via Gmail SMTP bila deployment **gagal**. Isi email mencantumkan:
- Environment yang gagal (dev / production)
- Commit SHA & branch
- GitHub username yang men-trigger
- GitHub username assignee PR yang di-merge (jika ada)
- Link langsung ke failed run

Rollback yang berhasil dieksekusi juga dikirimkan notifikasinya ke `NOTIFY_EMAILS`.
