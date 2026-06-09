# Skenario Tes Rollback

## Tujuan
Memastikan workflow rollback berfungsi dengan benar: bisa list releases, restore ke versi sebelumnya, dan mengirim notifikasi email.

---

## Persiapan

Sebelum mulai, pastikan:
- [ ] Secrets sudah di-set di GitHub repo (lihat bagian Secrets di bawah)
- [ ] Workflow `deploy-dev.yml` pernah berhasil jalan minimal **2 kali** (agar ada 2 release untuk dibandingkan)

---

## Langkah Skenario

### Step 1 — Deploy versi awal (v1)

1. Buat perubahan kecil di UI, misalnya ubah teks judul di `lib/main.dart` atau halaman utama
2. Commit dan push ke branch `dev`
3. Tunggu workflow **Deploy to Dev** selesai dan sukses
4. Catat timestamp release dari log step **"Backup current dev deployment"** (format: `YYYYMMDDHHMMSS`)
5. Buka URL dev: `https://storage.googleapis.com/<GCP_DEV_BUCKET>/index.html`
6. Verifikasi perubahan v1 terlihat di browser

### Step 2 — Deploy versi baru yang "rusak" (v2)

1. Buat perubahan lain — simulasikan bug, misalnya ubah teks atau warna yang salah
2. Commit dan push ke branch `dev`
3. Tunggu workflow **Deploy to Dev** selesai
4. Buka URL dev dan verifikasi perubahan v2 ter-deploy

### Step 3 — List releases yang tersedia

1. Buka GitHub repo → **Actions → Rollback Deployment → Run workflow**
2. Isi:
   - `environment`: `dev`
   - `release_timestamp`: **kosongkan**
3. Klik **Run workflow**
4. Buka run tersebut dan cek output step **"List releases for dev"**
5. Pastikan ada minimal 2 timestamp tercantum, termasuk timestamp v1 dari Step 1

### Step 4 — Jalankan rollback ke v1

1. Kembali ke **Actions → Rollback Deployment → Run workflow**
2. Isi:
   - `environment`: `dev`
   - `release_timestamp`: timestamp v1 dari Step 1
3. Klik **Run workflow**
4. Tunggu semua step selesai

### Step 5 — Verifikasi hasil rollback

1. Buka URL dev: `https://storage.googleapis.com/<GCP_DEV_BUCKET>/index.html`
2. Hard refresh browser (`Cmd+Shift+R` atau `Ctrl+Shift+R`)
3. Verifikasi tampilan kembali ke **v1** (bukan v2)
4. Cek email — notifikasi rollback harus masuk ke email actor yang trigger

---

## Checklist Hasil yang Diharapkan

| # | Yang Dicek | Hasil Harapan |
|---|---|---|
| 1 | Step "Validate timestamp format" | Pass tanpa error |
| 2 | Step "Verify release exists" | Release ditemukan di bucket |
| 3 | Step "Backup current state before rollback" | Folder `pre-rollbacks/<timestamp>` terbentuk di bucket |
| 4 | Step "Restore release" | Output `✅ Rollback to <timestamp> complete.` |
| 5 | Step "Show restored manifest" | Menampilkan isi `manifest.json` dari versi v1 |
| 6 | Email notifikasi | Masuk ke inbox dengan subject `[dev] Rollback executed` |
| 7 | URL dev di browser | Tampilan kembali ke v1 |

---

## Skenario Error (Opsional)

### Test rollback ke timestamp tidak valid
- Isi `release_timestamp` dengan angka acak, misal `99999999999999`
- Harapan: workflow gagal di step **"Verify release exists"** dengan pesan "Release not found"

### Test format timestamp salah
- Isi `release_timestamp` dengan `2026-06-09` (pakai tanda hubung)
- Harapan: workflow gagal di step **"Validate timestamp format"** dengan pesan "Invalid timestamp format"

---

## Secrets yang Dibutuhkan

| Secret | Cara dapat |
|---|---|
| `GCP_WIF_PROVIDER` | GCP Console → IAM → Workload Identity Federation |
| `GCP_SA_EMAIL` | GCP Console → IAM → Service Accounts |
| `GCP_DEV_BUCKET` | Nama bucket GCS untuk environment dev |
| `GCP_PROD_BUCKET` | Nama bucket GCS untuk environment production |
| `SMTP_USERNAME` | Email Gmail pengirim notifikasi |
| `SMTP_PASSWORD` | App Password Gmail (bukan password biasa) |
| `NOTIFY_EMAILS` | Email penerima fallback jika actor tidak punya public email |
