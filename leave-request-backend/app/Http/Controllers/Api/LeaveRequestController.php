<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\LeaveRequest;
use Illuminate\Http\Request;

class LeaveRequestController extends Controller
{
    // GET /api/leaves (Untuk HR di Next.js)
    public function index()
    {
        return response()->json(LeaveRequest::with('employee')->latest()->get());
    }

    // POST /api/leaves (Dari Flutter)
    public function store(Request $request)
    {
        $validated = $request->validate([
            'employee_id' => 'required|exists:employees,id',
            'reason'      => 'required|string',
            'start_date'  => 'required|date',
            'end_date'    => 'required|date|after_or_equal:start_date',
        ]);

        $leave = LeaveRequest::create($validated);
        return response()->json($leave, 201);
    }

    // PATCH /api/leaves/{id}/status (Approval dari HR di Next.js)
    public function updateStatus(Request $request, $id)
    {
        $validated = $request->validate([
            'status'           => 'required|in:approved,rejected',
            'rejection_reason' => 'nullable|string|required_if:status,rejected',
        ]);

        $leave = LeaveRequest::findOrFail($id);
        $leave->status = $validated['status'];

        if ($validated['status'] === 'rejected') {
            $leave->rejection_reason = $validated['rejection_reason'];
        } else {
            $leave->rejection_reason = null;
        }

        $leave->save();

        return response()->json($leave);
    }
}
