> The centralized RESTful API service, relational database management, and business logic core for the Mini-HRIS ecosystem, built on Laravel 11.

---

## 🏗️ Architecture & Tech Stack

- **Framework:** Laravel 11 (PHP 8.2+)
- **Database Persistence:** MySQL 8.0 (Normalized Relational Schema)
- **API Governance:** RESTful JSON Endpoints, CORS Protection, Form Request Validation
- **Deployment Platform:** Railway (Cloud PaaS with automated migrations)

---

## 📂 Project Directory Structure

```text
leave-request-backend/
├── app/
│   ├── Http/
│   │   ├── Controllers/Api/     # REST Controllers (EmployeeController, LeaveRequestController)
│   │   └── Middleware/          # CORS & Request verification middleware
│   └── Models/                  # Eloquent models (Employee, LeaveRequest)
├── database/
│   ├── migrations/              # Relational DDL schemas (employees, leave_requests)
│   └── seeders/                 # Initial mock data for development
└── routes/
    └── api.php                  # Public REST API routes (/api/employees, /api/leaves)

📊 Relational Database SchemaThe core database uses strict referential integrity and foreign key constraints:employees: Stores internal staff directory data, contact details, and role assignments (hr, employee).leave_requests: Tracks employee leave perms, start/end periods, operational status (pending, approved, rejected), and rejection audit reasons (rejection_reason).🔌 API Endpoints DocumentationEndpointMethodTarget ClientDescription/api/employeesGETNext.js (HR Portal)Retrieves full employee master directory/api/employeesPOSTNext.js (HR Portal)Registers a new employee profile/api/leavesGETNext.js (HR Portal)Fetches all submitted leave applications/api/leavesPOSTFlutter (Mobile App)Submits a new leave request payload/api/leaves/{id}/statusPATCHNext.js (HR Portal)Updates approval status (approved / rejected) with optional notes🚀 Local Setup & Installation GuideNavigate to the backend directory:Bashcd leave-request-backend
Install PHP dependencies via Composer:Bashcomposer install
Configure Environment Variables:Bashcp .env.example .env
php artisan key:generate
Update your local database settings inside .env:Code snippetDB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=mini_hris
DB_USERNAME=root
DB_PASSWORD=
Run Migrations & Seeders:Bashphp artisan migrate --seed
Run Local Development Server:Bashphp artisan serve
Access API endpoints at: http://127.0.0.1:8000/api/...
