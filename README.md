# PecesHun (Manajer Keuangan Pribadi)

## Deskripsi Proyek

PecesHun adalah aplikasi seluler cross-platform yang dibangun
menggunakan Flutter, dirancang sebagai solusi manajer keuangan pribadi
(personal finance manager) yang berfokus pada privasi dan fungsionalitas
offline.

Aplikasi ini memungkinkan pengguna untuk mencatat, melacak, dan
menganalisis setiap transaksi (pemasukan dan pengeluaran) dengan
antarmuka yang bersih dan modern. Seluruh data, termasuk lampiran bukti
transaksi, disimpan secara aman di penyimpanan internal perangkat
pengguna menggunakan database Hive. Aplikasi ini dirancang untuk
berfungsi 100% secara offline, memberikan pengguna kontrol penuh atas
data finansial mereka tanpa ketergantungan pada server eksternal.

## Informasi Build APK

-   Versi Aplikasi: 1.0.0
-   Build Mode: release (Kompilasi AOT untuk performa maksimal)
-   Tanggal Build: 03 November 2025
-   Catatan: Rilis stabil pertama yang mencakup fungsionalitas CRUD
    penuh dan analisis data.

## Panduan Instalasi APK

Untuk menginstal file .apk ini di perangkat Android Anda, ikuti
langkah-langkah berikut:

1.  Prasyarat: Pastikan perangkat Anda menjalankan Android 6.0
    (Marshmallow) atau versi yang lebih baru.
2.  Unduh File: Salin atau unduh file PecesHun-v1.0.0.apk ke penyimpanan
    internal ponsel Anda.
3.  Izinkan Sumber Tidak Dikenal:
    -   Buka Pengaturan \> Keamanan (atau Settings \> Security) di
        ponsel Anda.
    -   Aktifkan opsi "Instal aplikasi dari sumber tidak dikenal" (atau
        Install unknown apps / Unknown Sources).
    -   Langkah ini wajib karena APK tidak diinstal melalui Google Play
        Store.
4.  Instal Aplikasi: Buka File Manager Anda, temukan file APK yang telah
    diunduh, dan ketuk file tersebut untuk memulai proses instalasi.
5.  Jalankan Aplikasi: Setelah instalasi selesai, Anda dapat menemukan
    ikon aplikasi "PecesHun" di laci aplikasi (app drawer) Anda.

## Fitur Unggulan dan Fungsionalitas

Aplikasi ini dilengkapi dengan serangkaian fitur untuk manajemen
keuangan yang komprehensif:

### 1. Manajemen Transaksi (CRUD Penuh)

-   Create (Tambah): Pengguna dapat menambahkan transaksi baru
    (Pemasukan atau Pengeluaran) melalui formulir khusus
    (add_transaction_screen.dart).
-   Read (Lihat): Menampilkan semua transaksi dalam daftar yang terurut
    berdasarkan tanggal terbaru di Dashboard (dashboard_screen.dart).
-   Update (Edit): Pengguna dapat mengedit transaksi yang sudah ada
    melalui halaman detail (edit_transaction_screen.dart).
-   Delete (Hapus): Pengguna dapat menghapus transaksi dengan cepat
    menggunakan gestur swipe-to-delete pada Dashboard
    (transaction_list_tile.dart).

### 2. Manajemen Lampiran (Attachment)

-   Saat menambah atau mengedit transaksi, pengguna dapat melampirkan
    file sebagai bukti (nota, struk, dll) dari Kamera, Galeri, atau
    Manajer File.
-   File yang dipilih akan disalin ke direktori internal aplikasi untuk
    penyimpanan yang aman.
-   Pratinjau gambar ditampilkan langsung di halaman detail, dan file
    non-gambar (PDF, dll.) dapat dibuka menggunakan aplikasi eksternal
    (open_filex).

### 3. Dashboard & Analisis Visual

-   Metrik Utama: Halaman Dashboard menampilkan tiga kartu metrik utama
    yang dihitung secara real-time: Saldo Saat Ini, Total Pemasukan, dan
    Total Pengeluaran.
-   Ringkasan Kategori (Pie Chart): Menampilkan visualisasi data
    pengeluaran berdasarkan kategori menggunakan Pie Chart
    (summary_pie_chart.dart dengan fl_chart).
-   Wawasan Cerdas (Insights): Sebuah kartu analisis
    (expense_insights_card.dart) memberikan wawasan cepat seperti
    kategori pengeluaran terbesar dan tren pengeluaran mingguan.

## Panduan Penggunaan Aplikasi

Berikut adalah alur penggunaan dasar (user flow) aplikasi PecesHun:

### 1. Halaman Utama (Dashboard)

Saat pertama kali membuka aplikasi, Anda akan disambut oleh Dashboard.
Di sinilah ringkasan keuangan Anda ditampilkan: - Lihat Saldo: Cek cepat
"Saldo Saat Ini", "Total Pemasukan", dan "Total Pengeluaran". - Analisis
Pengeluaran: Lihat grafik "Ringkasan Pengeluaran" (Pie Chart) untuk
memahami ke mana uang Anda pergi. - Dapatkan Wawasan: Baca kartu
"Analisis Pengeluaran" untuk mengetahui kategori pengeluaran terbesar
dan tren Anda (apakah pengeluaran Anda naik atau turun). - Lihat
Riwayat: Gulir ke bawah untuk melihat "Transaksi Terakhir" Anda.

### 2. Menambah Transaksi Baru

Ini adalah alur utama untuk mencatat aktivitas keuangan: 1. Tekan tombol
(+) besar (Floating Action Button) di bagian bawah tengah layar. 2. Anda
akan diarahkan ke halaman "Tambah Transaksi Baru". 3. Pilih Tipe:
Tentukan apakah ini "Pengeluaran" atau "Pemasukan". 4. Isi Formulir:
Masukkan Jumlah (Rp), pilih Kategori yang sesuai, dan atur Tanggal
transaksi. 5. (Opsional) Tambah Catatan: Tulis detail tambahan di kolom
"Catatan" (misal: "Makan siang di Warung A"). 6. (Opsional) Tambah
Bukti: Ketuk "Tambah Bukti Transaksi" untuk melampirkan foto struk (via
Kamera/Galeri) atau file PDF tagihan. 7. Tekan tombol "Simpan Transaksi"
untuk menyimpan.

### 3. Melihat Detail & Mengedit Transaksi

Jika Anda perlu memeriksa atau memperbaiki data yang salah: 1. Di
Dashboard, ketuk (tap) pada salah satu item transaksi yang ada di
daftar. 2. Anda akan masuk ke halaman "Detail Transaksi". 3. Di sini,
Anda dapat melihat semua informasi, termasuk pratinjau gambar atau nama
file dokumen yang Anda lampirkan. 4. Untuk mengedit, tekan ikon pensil
(Edit) di kanan atas layar. 5. Ubah data yang diinginkan (jumlah,
kategori, tanggal, catatan, atau lampiran). 6. Tekan "Simpan Perubahan"
untuk memperbarui.

### 4. Menghapus Transaksi

Cara tercepat untuk menghapus transaksi adalah melalui Dashboard: 1.
Temukan transaksi yang ingin Anda hapus di daftar "Transaksi Terakhir".
2. Geser (swipe) item transaksi tersebut ke kiri hingga muncul ikon
tempat sampah. 3. Lepaskan geseran, dan transaksi akan langsung
terhapus. 4. Penting: Tindakan ini juga akan secara otomatis menghapus
file lampiran (foto/dokumen) yang terkait dengan transaksi tersebut dari
penyimpanan ponsel Anda untuk menghemat ruang.

## Spesifikasi Teknis & Dependensi

-   Framework: Flutter
-   Arsitektur & State Management: Riverpod (flutter_riverpod)
    -   Menggunakan pendekatan StateNotifierProvider untuk mengelola
        daftar transaksi (transaction_provider.dart).
    -   Menggunakan Provider turunan untuk menghitung data yang
        bergantung pada state utama (cth: dashboardMetricsProvider,
        pieChartDataProvider, advancedAnalysisProvider).
-   Database (Lokal/Offline): Hive (hive, hive_flutter)
    -   Seluruh data transaksi (termasuk Enum TransactionType) disimpan
        sebagai object Hive (TransactionModel).
    -   Aplikasi 100% fungsional tanpa koneksi internet.
-   Dependensi Utama (Pub.dev):
    -   flutter_riverpod: State management reaktif.
    -   hive / hive_flutter / hive_generator: Database NoSQL lokal
        berbasis Dart.
    -   fl_chart: Visualisasi data untuk Pie Chart.
    -   image_picker: Mengambil gambar dari kamera & galeri.
    -   file_picker: Mengambil file dokumen dari penyimpanan.
    -   open_filex: Membuka file non-gambar (PDF, DOCX) dari aplikasi.
    -   intl: Format mata uang (Rp) dan tanggal (format Indonesia,
        id_ID).
    -   path / path_provider: Manajemen path direktori file untuk
        menyimpan lampiran.
    -   iconsax_flutter: Paket ikon kustom untuk UI.