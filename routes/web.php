<?php
use App\Http\Controllers\CounterController;
use Illuminate\Support\Facades\Route;

Route::get('/', [CounterController::class, 'home'])->name('counter.index');
Route::get('/home', [CounterController::class, 'home']); // route alternative

