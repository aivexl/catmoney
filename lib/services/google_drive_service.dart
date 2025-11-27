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
      '561002972285-38015va7rnue6cn4bp43679e429eb0ff.apps.googleusercontent.com';
  static const String _scope = 'https://www.googleapis.com/auth/drive.file';
  static const String _tokenKey = 'google_drive_access_token';
  static const String _refreshTokenKey = 'google_drive_refresh_token';

  static GoogleSignIn? _googleSignIn;

  /// Initialize Google Sign In
  static GoogleSignIn _getGoogleSignIn() {
    if (kIsWeb) {
      _googleSignIn ??= GoogleSignIn(scopes: [_scope], clientId: _clientId);
    } else {
      // On Android/iOS without Firebase, we need to specify serverClientId
      // This is the Web Client ID from Google Cloud Console
      _googleSignIn ??= GoogleSignIn(
        scopes: [_scope],
        serverClientId: _clientId, // Use Web Client ID as server client ID
      );
    }
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
      if (!kIsWeb) {
        if (errorMessage.contains(
          'PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null)',
        )) {
          return AuthResult.error(
            'Configuration Error (Error 10):\n\n'
            'This usually means the SHA-1 fingerprint is missing or incorrect in the Firebase/Google Cloud Console.\n'
            'Please ensure you have added the correct SHA-1 from your keystore.',
          );
        }

        if (errorMessage.contains(
          'PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 12500: , null, null)',
        )) {
          return AuthResult.error(
            'Configuration Error (Error 12500):\n\n'
            'This usually means the support email is not selected in the Firebase Console project settings.',
          );
        }

        if (errorMessage.contains('PlatformException') ||
            errorMessage.contains('DEVELOPER_ERROR') ||
            errorMessage.contains('sign_in_failed')) {
          return AuthResult.error(
            'Mobile Configuration Error:\n\n'
            'Authentication failed. Please check:\n'
            '1. google-services.json is present in android/app/\n'
            '2. SHA-1 fingerprint is correctly configured in Firebase Console\n'
            '3. The package name matches exactly (com.machineloops.catmoneymanager)\n\n'
            'Error details: $errorMessage',
          );
        }
      }

      if (errorMessage.contains('popup_closed_by_user') ||
          errorMessage.contains('user_cancelled')) {
        return AuthResult.cancelled();
      } else if (errorMessage.contains('redirect_uri_mismatch')) {
        return AuthResult.error(
          'OAuth Configuration Error:\n\n'
          'Redirect URI does not match. Ensure in Google Cloud Console:\n'
          '1. Authorized JavaScript origins contains: http://localhost\n'
          '2. Authorized redirect URIs contains: http://localhost\n\n'
          'See GOOGLE_DRIVE_SETUP.md for details.',
        );
      } else if (errorMessage.contains('invalid_client')) {
        return AuthResult.error(
          'OAuth Configuration Error:\n\n'
          'Client ID is invalid. Ensure:\n'
          '1. Client ID is correct in google_drive_service.dart\n'
          '2. OAuth Client ID is created in Google Cloud Console\n\n'
          'See GOOGLE_DRIVE_SETUP.md for details.',
        );
      } else if (errorMessage.contains('access_denied')) {
        return AuthResult.error(
          'Access denied.\n\n'
          'You need to grant Google Drive access permission.',
        );
      }

      return AuthResult.error(
        'Authentication failed:\n$errorMessage\n\n'
        'See console for error details.',
      );
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
          'Not authenticated. Please sign in to Google Drive first.',
        );
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
        utf8.encode('Content-Type: application/json; charset=UTF-8\r\n\r\n'),
      );
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

  /// List all backup files from Google Drive
  static Future<ListBackupsResult> listBackupFiles() async {
    try {
      // Get access token
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return ListBackupsResult.error(
          'Not authenticated. Please sign in to Google Drive first.',
        );
      }

      // List files with our prefix
      const listUrl = 'https://www.googleapis.com/drive/v3/files?'
          'q=name contains \'catmoneymanager_auto_backup_\' and trashed=false&'
          'orderBy=createdTime desc&'
          'fields=files(id,name,createdTime,size)';

      final response = await http.get(
        Uri.parse(listUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final files = data['files'] as List;

        if (files.isEmpty) {
          return ListBackupsResult.error(
              'No backup files found in Google Drive');
        }

        final backupFiles = files.map((file) {
          return BackupFileInfo(
            id: file['id'] as String,
            name: file['name'] as String,
            createdTime: DateTime.parse(file['createdTime'] as String),
            size: file['size'] != null ? int.parse(file['size'] as String) : 0,
          );
        }).toList();

        return ListBackupsResult.success(backupFiles);
      } else {
        debugPrint('List error: ${response.statusCode} - ${response.body}');
        return ListBackupsResult.error(
          'Failed to list backups: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('List backups error: $e\n$stackTrace');
      return ListBackupsResult.error('Failed to list backups: ${e.toString()}');
    }
  }

  /// Restore transactions from a Google Drive backup file
  static Future<RestoreFromDriveResult> restoreFromBackup(String fileId) async {
    try {
      // Get access token
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return RestoreFromDriveResult.error(
          'Not authenticated. Please sign in to Google Drive first.',
        );
      }

      // Download file content
      final downloadUrl =
          'https://www.googleapis.com/drive/v3/files/$fileId?alt=media';

      final response = await http.get(
        Uri.parse(downloadUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        // Parse JSON
        final jsonString = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonData = jsonDecode(jsonString);

        if (!jsonData.containsKey('transactions')) {
          return RestoreFromDriveResult.error('Invalid backup file format');
        }

        final List<dynamic> transactionsJson = jsonData['transactions'];
        final transactions = transactionsJson
            .map((map) => Transaction.fromMap(map as Map<String, dynamic>))
            .toList();

        if (transactions.isEmpty) {
          return RestoreFromDriveResult.error(
            'Backup file contains no transactions',
          );
        }

        return RestoreFromDriveResult.success(
          transactions,
          message:
              'Restored ${transactions.length} transactions from Google Drive',
        );
      } else {
        debugPrint('Download error: ${response.statusCode} - ${response.body}');
        return RestoreFromDriveResult.error(
          'Failed to download backup: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Restore error: $e\n$stackTrace');
      return RestoreFromDriveResult.error('Restore failed: ${e.toString()}');
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

/// Backup file information from Google Drive
class BackupFileInfo {
  final String id;
  final String name;
  final DateTime createdTime;
  final int size;

  BackupFileInfo({
    required this.id,
    required this.name,
    required this.createdTime,
    required this.size,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(createdTime);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes} minutes ago';
      }
      return '${diff.inHours} hours ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${createdTime.day}/${createdTime.month}/${createdTime.year}';
    }
  }
}

/// Result class for listing backups
class ListBackupsResult {
  final bool success;
  final String? error;
  final List<BackupFileInfo>? files;

  ListBackupsResult.success(this.files)
      : success = true,
        error = null;

  ListBackupsResult.error(this.error)
      : success = false,
        files = null;
}

/// Result class for restore from Google Drive
class RestoreFromDriveResult {
  final bool success;
  final String? message;
  final String? error;
  final List<Transaction>? transactions;

  RestoreFromDriveResult.success(this.transactions, {this.message})
      : success = true,
        error = null;

  RestoreFromDriveResult.error(this.error)
      : success = false,
        message = null,
        transactions = null;
}
