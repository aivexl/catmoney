// Wishlist Provider - State management untuk wishlist
//
// Enterprise-level implementation dengan:
// - CRUD operations
// - Progress tracking
// - Notification triggers
// - Local storage integration
//
// @author Cat Money Manager Team
// @version 1.0.0
// @since 2025

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/wishlist.dart';

class WishlistProvider extends ChangeNotifier {
  List<Wishlist> _wishlists = [];
  bool _isLoading = false;

  List<Wishlist> get wishlists => _wishlists;
  bool get isLoading => _isLoading;

  /// Load wishlists from storage
  Future<void> loadWishlists() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final String? wishlistsJson = prefs.getString('wishlists');

      if (wishlistsJson != null) {
        final List<dynamic> decoded = json.decode(wishlistsJson);
        _wishlists = decoded.map((item) => Wishlist.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error loading wishlists: $e');
      _wishlists = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save wishlists to storage
  Future<void> _saveWishlists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(
        _wishlists.map((w) => w.toJson()).toList(),
      );
      await prefs.setString('wishlists', encoded);
    } catch (e) {
      debugPrint('Error saving wishlists: $e');
    }
  }

  /// Add new wishlist
  Future<void> addWishlist(Wishlist wishlist) async {
    _wishlists.add(wishlist);
    await _saveWishlists();
    notifyListeners();
  }

  /// Update wishlist
  Future<void> updateWishlist(Wishlist wishlist) async {
    final index = _wishlists.indexWhere((w) => w.id == wishlist.id);
    if (index != -1) {
      _wishlists[index] = wishlist;
      await _saveWishlists();
      notifyListeners();
    }
  }

  /// Delete wishlist
  Future<void> deleteWishlist(String id) async {
    _wishlists.removeWhere((w) => w.id == id);
    await _saveWishlists();
    notifyListeners();
  }

  /// Add amount to wishlist (from transaction)
  Future<Map<String, dynamic>> addToWishlist(String id, double amount) async {
    final index = _wishlists.indexWhere((w) => w.id == id);
    if (index == -1) {
      return {'success': false, 'message': 'Wishlist not found'};
    }

    final wishlist = _wishlists[index];
    final oldProgress = wishlist.progress;
    final newAmount = wishlist.currentAmount + amount;
    final updatedWishlist = wishlist.copyWith(currentAmount: newAmount);

    // Check for notification triggers
    final notifications = <String>[];
    final newProgress = updatedWishlist.progress;

    // Check 50% milestone
    if (oldProgress < 50 &&
        newProgress >= 50 &&
        wishlist.notifyAt50 &&
        !wishlist.hasNotified50) {
      notifications.add('50% achieved! 🎉');
      _wishlists[index] = updatedWishlist.copyWith(hasNotified50: true);
    }
    // Check 75% milestone
    else if (oldProgress < 75 &&
        newProgress >= 75 &&
        wishlist.notifyAt75 &&
        !wishlist.hasNotified75) {
      notifications.add('75% achieved! Almost there! 🚀');
      _wishlists[index] = updatedWishlist.copyWith(hasNotified75: true);
    }
    // Check 100% milestone
    else if (oldProgress < 100 &&
        newProgress >= 100 &&
        wishlist.notifyAt100 &&
        !wishlist.hasNotified100) {
      notifications.add('Target achieved! Congratulations! 🎊');
      _wishlists[index] = updatedWishlist.copyWith(hasNotified100: true);
    } else {
      _wishlists[index] = updatedWishlist;
    }

    await _saveWishlists();
    notifyListeners();

    return {
      'success': true,
      'notifications': notifications,
      'progress': newProgress,
    };
  }

  /// Get wishlist by ID
  Wishlist? getWishlistById(String id) {
    try {
      return _wishlists.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get active wishlists (not completed)
  List<Wishlist> get activeWishlists {
    return _wishlists.where((w) => !w.isCompleted).toList();
  }

  /// Get completed wishlists
  List<Wishlist> get completedWishlists {
    return _wishlists.where((w) => w.isCompleted).toList();
  }
}
