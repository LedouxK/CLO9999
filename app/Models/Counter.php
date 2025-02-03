<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Counter extends Model
{
    use HasFactory;

    protected $table = 'counters';

    /**
     * Les attributs que l’on peut assigner en masse.
     */
    protected $fillable = [
        'count',
    ];
}
