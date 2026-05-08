# Development Log - Mobile App (Flutter)

## 1. Requirement Log

| Tanggal    | Permintaan                                                                               | Status  |
| :--------- | :--------------------------------------------------------------------------------------- | :------ |
| 2026-05-06 | Perbaikan error tipe data pada `enrollment_screen.dart`                                | Selesai |
| 2026-05-06 | Penanganan error "Unauthenticated" pada Home Screen setelah login                        | Selesai |
| 2026-05-06 | Perbaikan logika redirect onboarding di SplashScreen                                     | Selesai |
| 2026-05-06 | Pemisahan Controller API khusus untuk Mobile di Backend (Pilot: Dashboard & My Learning) | Selesai |
| 2026-05-06 | Fitur Pendaftaran Siswa Baru (Akun & Profil)                                             | Selesai |
| 2026-05-06 | Onboarding Quiz untuk AI Recommendation                                                  | Selesai |
| 2026-05-06 | Enrollment Kursus & Kelas (via Class Code)                                               | Selesai |
| 2026-05-06 | Pengalaman Belajar (Learning, Quiz, Submission)                                          | Selesai |
| 2026-05-08 | Perbaikan bug Enrollment (404 Course Not Found) & Update Label                           | Selesai |
| 2026-05-08 | Implementasi Simulasi Pembayaran untuk Akses Instan Kursus                               | Selesai |
| 2026-05-08 | Perbaikan Bug: ID Kuis tidak ditemukan pada Lesson Screen                                | Selesai |
| 2026-05-08 | Perbaikan Crash: NoSuchMethodError pada QuizScreen (Null Content)                        | Selesai |
| 2026-05-08 | Perbaikan Bug: Pertanyaan kuis tidak muncul (Double JSON Encoding)                      | Selesai |
| 2026-05-08 | Sinkronisasi Kuis: Penambahan `assignment_id` pada Web API untuk Mobile                  | Selesai |

## 2. Implementation Plans

### [2026-05-06] Pemisahan API Mobile & Web

**Tujuan**: Menghindari kerusakan pada platform web saat melakukan perbaikan khusus untuk mobile.
**Pendekatan**:

- Membuat namespace `App\Http\Controllers\Api\V1\Mobile` di Laravel.
- Menambahkan prefix route `api/v1/mobile`.
- Memigrasikan endpoint kunci seperti Dashboard dan Auth ke Controller khusus mobile.

## 3. Task List

- [X] Inisialisasi DEVELOPMENT_LOG.md
- [X] Implementasi namespace Mobile di Backend
- [X] Refactoring `DashboardController` untuk Mobile
- [X] Update URL di aplikasi Flutter untuk mengarah ke endpoint mobile baru
- [X] **Pendaftaran & Profil**
  - [X] Refactor `RegisterScreen` untuk mendukung alur onboarding otomatis
  - [X] Implementasi update profil dasar setelah registrasi
- [X] **AI Recommendation & Onboarding**
  - [X] Refactor `OnboardingScreen` untuk integrasi API Mobile baru
  - [X] Optimasi logic rekomendasi khusus tampilan mobile
- [X] **Enrollment & Learning**
  - [X] Fitur gabung kelas menggunakan Class Code
  - [X] Refactor `EnrollmentScreen` untuk kestabilan data
  - [X] Perbaikan alur `LessonScreen`, `QuizScreen`, dan `SubmissionScreen` melalui API Mobile baru
- [X] **Bug Fixes & UX Update (2026-05-08)**
  - [ ] Ganti label "DAFTAR SEKARANG" menjadi "AMBIL KURSUS"
  - [ ] Perbaikan navigasi enrollment menggunakan slug (Fix 404 No query results)
  - [X] Implementasi parameter `payment_simulation` pada API Checkout
  - [X] Sinkronisasi `CourseRepository` untuk mendukung parameter checkout tambahan
  - [X] Perbaikan navigasi Kuis: Menyediakan `assignment_id` pada detail Lesson (Fix "ID Kuis tidak ditemukan")
  - [X] Perbaikan Crash Kuis: Null safety pada `QuizScreen` saat memuat data kuis (Fix "NoSuchMethodError")
  - [X] Perbaikan Sinkronisasi Kuis: Support decoding JSON string pada `content` kuis (Fix "Pertanyaan tidak muncul")
  - [X] Keselarasan API: Update `LearningController` (Web) untuk mendukung kebutuhan mobile (Fix "Tombol kuis hilang")
