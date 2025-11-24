import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction.dart';

/// Enterprise-level Google Drive service for auto-backup
/// Supports OAuth authentication and file upload to Google Drive
class GoogleDriveService {
  static const String _clientId =
      '561002972285-38015va7rnue6cn4bp43679e429eb0ff.apps.googleusercontent.com'; // Replace with your OAuth client ID
  static const String _scope = 'https://www.googleapis.com/auth/drive.file';
  static const String _tokenKey = 'google_drive_access_token';
  static const String _refreshTokenKey = 'google_drive_refresh_token';

  static GoogleSignIn? _googleSignIn;

  /// Initialize Google Sign In
  static GoogleSignIn _getGoogleSignIn() {
    _googleSignIn ??= GoogleSignIn(
      scopes: [_scope],
      clientId: _clientId,
    );
    return _googleSignIn!;
  }

  /// Authenticate with Google Drive
  static Future<AuthResult> authenticate() async {
    try {
      final googleSignIn = _getGoogleSignIn();

      // Check if already signed in
      final account = await googleSignIn.signInSilently();
      if (account != null) {
        final auth = await account.authentication;
        await _saveTokens(auth.accessToken, auth.idToken);
        return AuthResult.success('Already authenticated');
      }

      // Sign in
      final GoogleSignInAccount? signInAccount = await googleSignIn.signIn();
      if (signInAccount == null) {
        return AuthResult.cancelled();
      }

      final GoogleSignInAuthentication auth =
          await signInAccount.authentication;
      await _saveTokens(auth.accessToken, auth.idToken);

      return AuthResult.success('Successfully authenticated with Google Drive');
    } catch (e, stackTrace) {
      debugPrint('Google Drive auth error: $e\n$stackTrace');

      // Parse common errors
      final errorMessage = e.toString();

      // Add mobile-specific error handling
      if (!kIsWeb && errorMessage.contains('PlatformException')) {
        return AuthResult.error('Mobile Configuration Error:\n\n'
            'Google Drive authentication requires additional setup for mobile:\n'
            '1. Add OAuth client ID for Android/iOS in Google Cloud Console\n'
            '2. Configure SHA-1 fingerprint (Android)\n'
            '3. Add URL scheme (iOS)\n\n'
            'See GOOGLE_DRIVE_SETUP.md for mobile configuration.');
      }

      if (errorMessage.contains('popup_closed_by_user') ||
          errorMessage.contains('user_cancelled')) {
        return AuthResult.cancelled();
      } else if (errorMessage.contains('redirect_uri_mismatch')) {
        return AuthResult.error('OAuth Configuration Error:\n\n'
            'Redirect URI tidak cocok. Pastikan di Google Cloud Console:\n'
            '1. Authorized JavaScript origins berisi: http://localhost\n'
            '2. Authorized redirect URIs berisi: http://localhost\n\n'
            'Lihat GOOGLE_DRIVE_SETUP.md untuk detail.');
      } else if (errorMessage.contains('invalid_client')) {
        return AuthResult.error('OAuth Configuration Error:\n\n'
            'Client ID tidak valid. Pastikan:\n'
            '1. Client ID sudah benar di google_drive_service.dart\n'
            '2. OAuth Client ID sudah dibuat di Google Cloud Console\n\n'
            'Lihat GOOGLE_DRIVE_SETUP.md untuk detail.');
      } else if (errorMessage.contains('access_denied')) {
        return AuthResult.error('Access ditolak.\n\n'
            'Anda perlu memberikan izin akses Google Drive.');
      }

      return AuthResult.error('Authentication failed:\n$errorMessage\n\n'
          'Lihat console untuk detail error.');
    }
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final googleSignIn = _getGoogleSignIn();
      final account = await googleSignIn.signInSilently();
      if (account != null) {
        final auth = await account.authentication;
        if (auth.accessToken != null) {
          await _saveTokens(auth.accessToken, auth.idToken);
          return true;
        }
      }

      // Check stored token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('Auth check error: $e');
      return false;
    }
  }

  /// Sign out from Google Drive
  static Future<void> signOut() async {
    try {
      final googleSignIn = _getGoogleSignIn();
      await googleSignIn.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  /// Upload backup file to Google Drive
  static Future<UploadResult> uploadBackup(
    List<Transaction> transactions,
  ) async {
    try {
      if (transactions.isEmpty) {
        return UploadResult.error('No transactions to backup');
      }

      // Get access token
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return UploadResult.error(
            'Not authenticated. Please sign in to Google Drive first.');
      }

      // Prepare backup data
      final jsonData = {
        'version': '1.0.0',
        'backupDate': DateTime.now().toIso8601String(),
        'transactionCount': transactions.length,
        'transactions': transactions.map((t) => t.toMap()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      final bytes = utf8.encode(jsonString);

      // Create file metadata
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .substring(0, 19);
      final fileName = 'catmoneymanager_auto_backup_$timestamp.json';

      // Upload to Google Drive
      const uploadUrl =
          'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart';

      // Create multipart request
      final boundary =
          '----WebKitFormBoundary${DateTime.now().millisecondsSinceEpoch}';
      final metadata = {
        'name': fileName,
        'parents': [], // Upload to root, or specify folder ID
      };

      final body = <int>[];

      // Add metadata part
      body.addAll(utf8.encode('--$boundary\r\n'));
      body.addAll(
          utf8.encode('Content-Type: application/json; charset=UTF-8\r\n\r\n'));
      body.addAll(utf8.encode(jsonEncode(metadata)));
      body.addAll(utf8.encode('\r\n'));

      // Add file part
      body.addAll(utf8.encode('--$boundary\r\n'));
      body.addAll(utf8.encode('Content-Type: application/json\r\n\r\n'));
      body.addAll(bytes);
      body.addAll(utf8.encode('\r\n'));
      body.addAll(utf8.encode('--$boundary--\r\n'));

      final response = await http.post(
        Uri.parse(uploadUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'multipart/related; boundary=$boundary',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final fileId = responseData['id'] as String;
        final fileUrl = 'https://drive.google.com/file/d/$fileId/view';

        // Clean up old backups (keep last 10)
        await _cleanupOldBackups(accessToken);

        return UploadResult.success(
          'Backup uploaded to Google Drive successfully',
          fileUrl: fileUrl,
          fileId: fileId,
        );
      } else {
        debugPrint('Upload error: ${response.statusCode} - ${response.body}');
        return UploadResult.error(
          'Upload failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Upload error: $e\n$stackTrace');
      return UploadResult.error('Upload failed: ${e.toString()}');
    }
  }

  /// Get access token (with refresh if needed)
  static Future<String?> _getAccessToken() async {
    try {
      final googleSignIn = _getGoogleSignIn();
      final account = await googleSignIn.signInSilently();
      if (account != null) {
        final auth = await account.authentication;
        if (auth.accessToken != null) {
          await _saveTokens(auth.accessToken, auth.idToken);
          return auth.accessToken;
        }
      }

      // Try stored token
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('Get token error: $e');
      return null;
    }
  }

  /// Save tokens to SharedPreferences
  static Future<void> _saveTokens(String? accessToken, String? idToken) async {
    if (accessToken == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);
    if (idToken != null) {
      await prefs.setString(_refreshTokenKey, idToken);
    }
  }

  /// Clean up old backup files (keep last 10)
  static Future<void> _cleanupOldBackups(String accessToken) async {
    try {
      // List files with our prefix
      const listUrl = 'https://www.googleapis.com/drive/v3/files?'
          'q=name contains \'catmoneymanager_auto_backup_\' and trashed=false&'
          'orderBy=createdTime desc&'
          'fields=files(id,name,createdTime)';

      final response = await http.get(
        Uri.parse(listUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final files = data['files'] as List;

        if (files.length > 10) {
          // Delete old files (keep first 10)
          for (var i = 10; i < files.length; i++) {
            final fileId = files[i]['id'] as String;
            await http.delete(
              Uri.parse('https://www.googleapis.com/drive/v3/files/$fileId'),
              headers: {'Authorization': 'Bearer $accessToken'},
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Cleanup error: $e');
      // Don't fail upload if cleanup fails
    }
  }
}

/// Result class for authentication
class AuthResult {
  final bool success;
  final String? message;
  final String? error;

  AuthResult.success(this.message)
      : success = true,
        error = null;

  AuthResult.error(this.error)
      : success = false,
        message = null;

  AuthResult.cancelled()
      : success = false,
        message = null,
        error = null;
}

/// Result class for upload operations
class UploadResult {
  final bool success;
  final String? message;
  final String? error;
  final String? fileUrl;
  final String? fileId;

  UploadResult.success(this.message, {this.fileUrl, this.fileId})
      : success = true,
        error = null;

  UploadResult.error(this.error)
      : success = false,
        message = null,
        fileUrl = null,
        fileId = null;
}
