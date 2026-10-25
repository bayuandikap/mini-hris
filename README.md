# 🏢 Mini-HRIS Multi-Platform Ecosystem

A decoupled Human Resources and Leave Management System featuring a centralized backend API, an administrative web portal, and an employee self-service mobile application.

## 📂 Repository Structure
- **[`leave-request-backend/`](./leave-request-backend)**: Laravel 11 RESTful API core and MySQL relational database.
- **[`leave-request-next/`](./leave-request-next)**: Next.js 14 App Router administrative dashboard for HR master data and leave approvals.
- **[`leave-request-mobile/`](./leave-request-mobile)**: Flutter mobile application for employee self-service leave requests and status tracking.

## 🏗️ System Architecture
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
   └───────────────────────────┘     └───────────────────────────┘