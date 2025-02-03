<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\CounterController;

Route::get('/click', [CounterController::class, 'getCount']);
Route::post('/click', [CounterController::class, 'incrementCount']);
