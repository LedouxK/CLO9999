<?php
use App\Http\Controllers\CounterController;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;

Route::get('/', [CounterController::class, 'home'])->name('counter.index');
Route::get('/home', [CounterController::class, 'home']); // route alternative

Route::get('/db-test', function () {
    try {
        DB::connection()->getPdo();
        $tables = DB::select('SHOW TABLES');
        
        return response()->json([
            'status' => 'success',
            'message' => 'Connexion à la base de données réussie !',
            'tables' => $tables
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => 'Erreur de connexion : ' . $e->getMessage()
        ], 500);
    }
});

