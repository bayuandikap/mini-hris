<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LeaveRequest extends Model
{
    protected $fillable = ['employee_id', 'reason', 'start_date', 'end_date', 'status', 'rejection_reason'];

    public function employee()
    {
        return $this->belongsTo(Employee::class);
    }
}
