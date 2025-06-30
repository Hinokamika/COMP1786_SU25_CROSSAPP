// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  // Keys for SharedPreferences
  static const String _userDataKey = 'cached_user_data';
  static const String _lastFetchKey = 'last_fetch_time';

  // Get current user ID from Firebase Auth
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // Get current user from Firebase Auth
  User? get currentUser => FirebaseAuth.instance.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  // Listen to authentication state changes
  Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();

  // Save user data to local storage (for offline access)
  Future<void> cacheUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = json.encode(userData); // Properly encode as JSON
      await prefs.setString(_userDataKey, userDataJson);
      await prefs.setInt(_lastFetchKey, DateTime.now().millisecondsSinceEpoch);
      print('SessionService: User data cached successfully');
    } catch (e) {
      print('Error caching user data: $e');
    }
  }

  // Get cached user data
  Future<Map<String, dynamic>?> getCachedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString(_userDataKey);
      if (userDataJson != null) {
        return json.decode(userDataJson)
            as Map<String, dynamic>; // Properly decode JSON
      }
    } catch (e) {
      print('Error getting cached user data: $e');
    }
    return null;
  }

  // Get user data from Firebase (with caching)
  Future<Map<String, dynamic>?> getUserData({bool forceRefresh = false}) async {
    if (currentUserId == null) return null;

    try {
      // Check if we should use cached data
      if (!forceRefresh) {
        final prefs = await SharedPreferences.getInstance();
        final lastFetch = prefs.getInt(_lastFetchKey) ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        const cacheValidDuration = 5 * 60 * 1000; // 5 minutes

        if (now - lastFetch < cacheValidDuration) {
          final cachedData = await getCachedUserData();
          if (cachedData != null) {
            print('SessionService: Using cached user data');
            return cachedData;
          }
        }
      }

      // Fetch fresh data from Firebase Realtime Database only
      DatabaseReference userRef = FirebaseDatabase.instance.ref(
        'users/$currentUserId',
      );
      DataSnapshot snapshot = await userRef.get();

      // Only use Realtime Database data (no Firebase Auth metadata)
      Map<String, dynamic> userData = {};

      // Add Realtime Database data if it exists
      if (snapshot.exists) {
        final dbData = snapshot.value;
        if (dbData is Map) {
          // Convert dynamic keys to String
          dbData.forEach((key, value) {
            userData[key.toString()] = value;
          });
          print(
            'SessionService: Successfully fetched data from Realtime Database only',
          );
          print('SessionService: Data retrieved: $userData');
        }
      } else {
        print(
          'SessionService: No user data found in Realtime Database for user: $currentUserId',
        );
        return null; // Return null if no data found
      }

      // Cache the fresh data
      await cacheUserData(userData);
      return userData;
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }

  // Clear all session data (for logout)
  Future<void> clearSession() async {
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      await prefs.remove(_lastFetchKey);
    } catch (e) {
      print('Error clearing session: $e');
    }
  }

  // Save specific user preferences
  Future<void> saveUserPreference(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      }
    } catch (e) {
      print('Error saving user preference: $e');
    }
  }

  // Get user preference
  Future<T?> getUserPreference<T>(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.get(key) as T?;
    } catch (e) {
      print('Error getting user preference: $e');
      return null;
    }
  }
}
