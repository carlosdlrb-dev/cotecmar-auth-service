<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        $token = Auth::attempt($credentials);

        if (! $token) {
            return response()->json([
                'message' => 'Invalid credentials.',
            ], 401);
        }

        $ttl = (int) config('jwt.ttl');

        return response()->json([
            'token' => $token,
            'token_type' => 'Bearer',
            'expires_in' => $ttl * 60,
            'user' => Auth::user(),
        ]);
    }

    public function me()
    {
        return response()->json([
            'user' => Auth::user(),
        ]);
    }

    public function logout()
    {
        Auth::logout();

        return response()->json([
            'message' => 'Logged out successfully.',
        ]);
    }
}
