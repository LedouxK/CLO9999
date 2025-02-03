<?php

namespace App\Http\Controllers;

use App\Models\Counter;
use Illuminate\Http\Request;

class CounterController extends Controller
{
    /**
     * Affiche la page HTML (UI) : /home
     */
    public function home()
    {
        return view('counter.index');
    }

    /**
     * Renvoie la valeur actuelle du compteur (API GET /api/click).
     */
    public function getCount()
    {
        $counter = Counter::first();
        if (!$counter) {
            $counter = Counter::create(['count' => 0]);
        }

        return response()->json([
            'count' => $counter->count,
        ]);
    }

    /**
     * Incrémente la valeur du compteur (API POST /api/click).
     */
    public function incrementCount(Request $request)
    {
        $counter = Counter::first();
        if (!$counter) {
            $counter = Counter::create(['count' => 0]);
        }

        $counter->count += 1;
        $counter->save();

        return response()->json([
            'message' => 'Compteur incrémenté',
            'count'   => $counter->count,
        ]);
    }
}
