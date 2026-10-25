<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Employee;
use Illuminate\Http\Request;

class EmployeeController extends Controller
{
    // GET /api/employees (Untuk Master Employee di Next.js)
    public function index()
    {
        return response()->json(Employee::latest()->get());
    }

    // POST /api/employees
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'     => 'required|string|max:100',
            'email'    => 'required|email|unique:employees,email',
            'position' => 'required|string|max:100',
            'role'     => 'in:hr,employee',
        ]);

        $employee = Employee::create($validated);
        return response()->json($employee, 201);
    }

    // PUT/PATCH /api/employees/{id}
    public function update(Request $request, $id)
    {
        $employee = Employee::findOrFail($id);

        $validated = $request->validate([
            'name'     => 'required|string|max:100',
            'email'    => 'required|email|unique:employees,email,' . $id,
            'position' => 'required|string|max:100',
            'role'     => 'required|in:hr,employee',
        ]);

        $employee->update($validated);
        return response()->json($employee);
    }

    // DELETE /api/employees/{id}
    public function destroy($id)
    {
        $employee = Employee::findOrFail($id);
        $employee->delete();

        return response()->json(['message' => 'Karyawan berhasil dihapus']);
    }
}
