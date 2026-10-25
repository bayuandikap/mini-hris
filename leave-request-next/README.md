```markdown
# 👥 Apique Mini-HRIS & Leave Management System

> A multi-platform employee leave management ecosystem featuring an employee self-service mobile app (Flutter), an HR administrative portal (Next.js), and a centralized backend API (Laravel).

---

## 🏗️ System Architecture Flow

```text
               ┌─────────────────────────────────────┐
               │         Laravel REST API            │
               │         + MySQL Database            │
               └──────────────────┬──────────────────┘
                                  │ JSON API (RESTful)
                 ┌────────────────┴────────────────┐
                 ▼                                 ▼
   ┌───────────────────────────┐     ┌───────────────────────────┐
   │    Next.js (App Router)   │     │      Flutter Mobile       │
   │      [Portal Admin/HR]    │     │    [Aplikasi Karyawan]    │
   │  - Master Karyawan        │     │  - Presensi Masuk/Pulang  │
   │  - Approval Cuti/Izin     │     │  - Pengajuan Cuti Mandiri │
   │  - Rekap Absensi          │     │  - Riwayat Kehadiran      │
   └───────────────────────────┘     └───────────────────────────┘

✨ Key Features
Employee Self-Service (Mobile): Built with Flutter to let employees submit leave requests and track approval statuses in real-time.

HR Administrative Dashboard: Built with Next.js App Router for managing employee master data and reviewing pending leave requests.

Instant Decision Actions: One-click Approve or Reject actions with automated backend state revalidation (revalidatePath).

Data Integrity & ACID Safety: Strict foreign key constraints and transactional wrappers to prevent race conditions during leave quotas.

🛠️ Tech Stack
Backend: Laravel 11 REST API, MySQL

Web Admin Frontend: Next.js 14 (App Router, Tailwind CSS)

Mobile Frontend: Flutter (Dart, HTTP Client)

🚀 Quick Setup Guide
1. Backend Setup (Laravel):
git clone [https://github.com/your-username/mini-hris-backend.git](https://github.com/your-username/mini-hris-backend.git)
cd mini-hris-backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
2. Web Frontend Setup (Next.js):
cd hris-next
npm install
npm run dev
3. cd leave-request-mobile
flutter pub get
flutter run
