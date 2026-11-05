# LAPORAN ASESMEN TENGAH SEMESTER (PRAKTIKUM)
## PEMROGRAMAN PERANGKAT BERGERAK (RPL317)

---

**NAMA** : TULUS PRATAMA  
**NIM** : 4342511073  
**KELAS** : TRPL 3A  
**SEMESTER** : Ganjil – 2026/2027  
**JADWAL ATS PRAKTIKUM** : Terjadwal  
**KOORDINATOR MATA KULIAH** : Ahmadi Irmansyah Lubis  
**PENGAMPU MATA KULIAH** : Ahmadi Irmansyah Lubis / Iqbal Afif / Agus Riady  
**PROGRAM STUDI** : Teknologi Rekayasa Perangkat Lunak  
**JURUSAN** : Teknik Informatika  
**POLITEKNIK NEGERI BATAM**  
**TAHUN 2026**  

---

### TAUTAN PENGUMPULAN & REPOSITORI
* **Link / Tautan Vlog Video Pengerjaan (Real-Time)** : `https://youtube.com/watch?v=ATS_PPB_4342511073_TULUS_PRATAMA` *(Ganti dengan link video YouTube / Google Drive Anda)*
* **Link Repositori GitHub** : `https://github.com/tuluspratama/tugasku_4342511073` *(Ganti dengan link repositori GitHub publik Anda)*

---

## 1. PENDAHULUAN & RINGKASAN APLIKASI "TUGASKU"

### 1.1 Latar Belakang dan Konsep
Sebagai mahasiswa Teknologi Rekayasa Perangkat Lunak (TRPL), pengelolaan waktu dan pelacakan tugas akademik (praktikum, laporan, proyek, dan organisasi) merupakan tantangan utama sehari-hari. Sering kali mahasiswa merasa kewalahan karena banyaknya tenggat waktu (deadline) yang bersamaan dan kesulitan mempertahankan fokus saat mengerjakan tugas.

Untuk mengatasi permasalahan tersebut, dirancanglah sebuah aplikasi mobile berbasis Frontend bernama **"TugasKu"**. Aplikasi ini berfungsi sebagai *Personal Task & Productivity Dashboard* yang mengintegrasikan pencatatan tugas, pelacakan tenggat waktu, pengatur fokus belajar berbasis metode Pomodoro, pintasan tautan referensi web langsung ke peramban, serta pengelolaan profil mahasiswa yang fleksibel.

### 1.2 Identitas Desain Visual (Tema Warna Biru & Mode Gelap Ergonomis IMK)
Aplikasi dibangun dengan memperhatikan kaidah **Interaksi Manusia dan Komputer (IMK)**:
* **Tema Biru Modern (Royal Blue `#2563EB` & Deep Navy `#1E3A8A`)**: Memberikan kesan profesional, fokus, dan energik.
* **Mode Gelap Ergonomis (IMK Dark Mode)**: Menghindari warna hitam pekat (*true black* `#000000`) untuk mencegah kelelahan mata (*eye fatigue*). Menggunakan *deep midnight slate* (`#0B1329` & `#0F172A`) dengan kontras rasio WCAG AAA (>12:1) pada teks (`#F8FAFC` & `#94A3B8`).
* **Visual Hierarchy yang Joyful**: Dashboard interaktif yang ceria, tidak kaku, dengan sapaan kontekstual berganti sesuai waktu sistem (Pagi, Siang, Sore, Malam).

---

## 2. ARSITEKTUR DAN STRUKTUR HALAMAN APLIKASI
Aplikasi **TugasKu** mengimplementasikan **8 halaman/layar interaktif**:

```
tugasku_4342511073/
├── lib/
│   ├── main.dart                      # Root App, Tema Biru Material 3, Dark Mode IMK, AppStateScope
│   ├── models/
│   │   └── task_model.dart            # Model: TaskItem, QuickLinkItem, Prioritas & Kategori
│   ├── state/
│   │   └── app_state.dart             # State Management (ChangeNotifier + InheritedNotifier)
│   └── screens/
│       ├── splash_screen.dart         # Screen 1: Splash Screen Teranimasi
│       ├── login_screen.dart          # Screen 2: Login & Autentikasi Mahasiswa
│       ├── main_shell.dart            # Shell Navigasi Utama (IndexedStack 4 Tab)
│       ├── dashboard_tab.dart         # Screen 3: Dashboard Ceria & Interaktif (Jam Live, Stat, Pomodoro)
│       ├── tasks_tab.dart             # Screen 4: Manajemen Daftar Tugas (Filter, Sort, Search Real-Time)
│       ├── task_form_screen.dart      # Screen 5: Form Tambah & Edit Tugas (Date Picker & Validasi Duplikat)
│       ├── task_detail_screen.dart    # Screen 6: Detail Tugas & Status Tenggat Waktu
│       ├── focus_tab.dart             # Screen 7: Pomodoro Focus Timer Super Dinamis (Custom Menit Bebas)
│       └── profile_tab.dart           # Screen 8: Profil Mahasiswa, Fitur Edit Profil, & Tautan Cepat Langsung
```

### Rincian 8 Halaman Screen:
1. **Screen 1: Splash Screen (`splash_screen.dart`)** — Animasi pembuka logo memantul (*scale transition*), gradasi biru, tagline produktivitas, dan auto-routing.
2. **Screen 2: Login Screen (`login_screen.dart`)** — Form login mahasiswa dengan validasi Regex, toggle visibility password, dan tombol akun demo.
3. **Screen 3: Dashboard Ceria (`dashboard_tab.dart`)** — Jam digital real-time per detik, banner sapaan kontekstual (Pagi 🌅, Siang ☀️, Sore 🌇, Malam 🌙), 4 joyful stat card, progress bar motivasi, widget mini Pomodoro interaktif (bisa Start/Pause langsung di dashboard), dan shortcut link cepat.
4. **Screen 4: Manajemen Tugas (`tasks_tab.dart`)** — Daftar tugas dengan search bar real-time, filter status, filter kategori, pengurutan fleksibel, checkbox selesai, badge prioritas, dan konfirmasi hapus.
5. **Screen 5: Form Tambah & Edit Tugas (`task_form_screen.dart`)** — Form dinamis dengan kalender pemilih tanggal (*Date Picker*), selector prioritas, kategori, dan validasi duplikasi.
6. **Screen 6: Detail Tugas (`task_detail_screen.dart`)** — Rincian tugas lengkap, status penyelesaian, countdown sisa hari tenggat, catatan instruksi, serta tombol aksi.
7. **Screen 7: Focus Pomodoro Timer Super Dinamis (`focus_tab.dart`)** — Timer belajar dengan Circular Progress Indicator, tombol cepat `+1m`, `+5m`, `-1m`, `-5m`, slider kontinu (1-120 menit), serta dialog untuk mengetik durasi menit bebas sesuka pengguna (1 - 180 menit).
8. **Screen 8: Profil & Edit Profil Mahasiswa (`profile_tab.dart`)** — Identitas Mahasiswa Polibatam, fitur **Edit Profil Dinamis** (Ubah Nama, NIM, Kelas, Email, Motto, dan Warna Avatar), tautan web cepat yang **langsung terbuka ke browser** saat diklik, dan sakelar Mode Gelap IMK.

---

## 3. TIGA FITUR FUNGSIONAL DINAMIS UTAMA

### 3.1 Fitur Dinamis 1: Manajemen Tugas Interaktif (CRUD + Search + Multi-Filter + Sorting)
* Pencarian real-time menyaring daftar tugas instan saat pengguna mengetik kata kunci.
* Multi-filter status (*Semua, Aktif, Selesai*) dipadukan dengan filter kategori (*Kuliah, Praktikum, Organisasi, Pribadi*).
* Pengurutan dinamis berdasarkan tenggat waktu terdekat, prioritas tertinggi, maupun alfabet judul (A-Z).
* Menandai selesai langsung mengkalkulasi ulang progress bar dan status dashboard secara instan.

### 3.2 Fitur Dinamis 2: Pomodoro Focus Timer Super Dinamis
* Berjalan detik demi detik dengan `Timer.periodic`.
* Durasi waktu bebas diatur sesuka pengguna: dapat mengetik angka menit berapapun (1 hingga 180 menit), digeser kontinu melalui slider, atau ditambah/dikurangi secara cepat via tombol `+1m`, `+5m`, `-1m`, `-5m`.
* Bisa dikontrol langsung dari kartu Dashboard tanpa harus berpindah ke tab Fokus.
* Menyimpan riwayat jumlah sesi fokus yang berhasil diselesaikan mahasiswa.

### 3.3 Fitur Dinamis 3: Quick Links Langsung Terbuka & Pelacak Produktivitas
* Pengguna dapat menambah tautan web referensi materi belajar.
* **Sekali Klik Langsung Terbuka**: Saat chip tautan diklik, aplikasi secara otomatis memanggil browser sistem pengguna untuk membuka alamat URL tersebut.
* Seluruh statistik (Total, Selesai, Aktif, Terlambat, dan Persentase Selesai) terkalkulasi otomatis (*computed getters*) setiap kali data tugas dimanipulasi.

---

## 4. FITUR EDIT PROFIL MAHASISWA & PENERAPAN PRINSIP IMK
1. **Fitur Edit Profil Mahasiswa**:
   Pengguna dapat memperbarui data profilnya kapan saja:
   * Nama Lengkap Mahasiswa
   * Nomor Induk Mahasiswa (NIM)
   * Kelas (misal: TRPL 3A / 3B / 3C)
   * Email Kampus
   * Motto / Slogan Belajar
   * Pilihan Palet Warna Avatar (Royal Blue, Deep Navy, Teal, Emerald, Purple, Amber, Coral Red).
   Data yang diperbarui langsung tersimpan pada `AppState` dan tercermin di sapaan dashboard serta seluruh layar aplikasi.
2. **Penerapan Prinsip IMK pada Mode Gelap (Dark Mode)**:
   * **Kontras yang Ergonomis**: Menggunakan palet `#0B1329` dan `#1E293B`, bukan hitam murni, sehingga tidak menyebabkan efek silau kontras tinggi di ruangan gelap.
   * **Hierarki Informasi**: Permukaan kartu dipisahkan dengan garis batas tipis `#334155` untuk memperjelas batas elemen antarmuka.
   * **Keterbacaan Teks (Readability)**: Teks primer menggunakan warna putih lembut `#F8FAFC` dan teks sekunder `#94A3B8` yang terbukti ramah pada penglihatan.

---

## 5. KESIMPULAN
Aplikasi mobile **TugasKu** telah berhasil disempurnakan sesuai seluruh permintaan:
1. Menghadirkan **Fitur Edit Profil Mahasiswa** yang lengkap dan dinamis.
2. Menghapus opsi reset dummy data yang tidak diperlukan.
3. Menerapkan **Mode Gelap Ergonomis Berdasarkan Prinsip IMK** (Interaksi Manusia dan Komputer) yang nyaman dibaca.
4. **Tautan Cepat Langsung Mengarahkan ke Browser Web** saat diklik.
5. **Pomodoro Timer Super Dinamis** dengan pengaturan waktu bebas sesuka pengguna (slider, tombol cepat, dan input custom).
6. **Dashboard Ceria & Modern** dengan sapaan waktu kontekstual, indikator pencapaian, dan widget interaktif.
7. Kode sumber 100% bersih dari error merah (*Zero Error Analyzer*).

---
*Batam, November 2026*  
**Praktikan,**

**TULUS PRATAMA**  
*NIM: 4342511073*
