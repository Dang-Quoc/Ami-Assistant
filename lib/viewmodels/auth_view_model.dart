import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  User? _user;
  bool isLoading = false;
  String? error;

  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user;

  //Version
  String _versionName = " ";
  String get versionName => _versionName;

  //Remaining tokens
  int? _remainingTokens;
  int? get remainingTokens => _remainingTokens;
  set remainingTokens(int? value) {
    _remainingTokens = value;
    notifyListeners();
  }

  //Max tokens
  int? _maxTokens;
  int? get maxTokens => _maxTokens;
  set maxTokens(int? value) {
    _maxTokens = value;
    notifyListeners();
  }

  final int unlimited = 99999;
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final user = User(
        username: username,
        email: email,
        password: password,
      );

      final response = await _authService.register(user);

      if (response.success && response.data['user'] != null) {
        // Chỉ lưu thông tin user
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('user', jsonEncode(response.data['user']));

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        error = response.message ?? 'Đăng ký thất bại';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Register error: $e');
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);

      if (response.success && response.data != null) {
        final prefs = await SharedPreferences.getInstance();
        // Lưu access token
        if (response.data['token']?['accessToken'] != null) {
          await prefs.setString(
              'accessToken', response.data['token']['accessToken']);
        }
        // Lưu refresh token
        if (response.data['token']?['refreshToken'] != null) {
          await prefs.setString(
              'refreshToken', response.data['token']['refreshToken']);
        }

        // Lấy accestoken knowledge base server
        final responseKB = await _authService
            .loginFromExternalClient(response.data['token']?['accessToken']);

        if (responseKB.success && responseKB.data != null) {
          // Lưu access token knowledgebase server
          if (responseKB.data['token']?['accessToken'] != null) {
            await prefs.setString(
                'kbAccessToken', responseKB.data['token']['accessToken']);
          }
          // Lưu refresh token knowledgebase server
          if (responseKB.data['token']?['refreshToken'] != null) {
            await prefs.setString(
                'kbRefreshToken', responseKB.data['token']['refreshToken']);
          }
        } else {
          error = response.message ?? 'Đăng nhập thất bại';
          isLoading = false;
          notifyListeners();
          return false;
        }

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        error = response.message ?? 'Đăng nhập thất bại';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadIsLoggedInFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');

    // await prefs.setString('refreshToken', "deleteRefreshToken");

    _isLoggedIn = accessToken != null && refreshToken != null;
    notifyListeners();
  }

  Future<void> fetchUserInfo() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final response = await _authService.getCurrentUser(accessToken!);

    if (response.success && response.data != null) {
      _user = User.fromJson(response.data);
      isLoading = false;
      _isLoggedIn = true;
      notifyListeners();
    } else {
      isLoading = false;
      error = response.message;
      logout();
      throw response;
    }
  }

  Future<void> logout() async {
    final response = await _authService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }

  Future<void> loadSubscriptionDetails() async {
    try {
      final subscriptionDetails = await _authService.fetchSubscriptionDetails();
      _versionName = subscriptionDetails.name;
      notifyListeners();
    } catch (e) {
      print('Lỗi khi lấy thông tin subscription: $e');
    }
  }

  Future<void> fetchTokens() async {
    try {
      final tokenUsageResponse = await _authService.fetchTokenUsage();
      if (tokenUsageResponse.unlimited) {
        maxTokens = unlimited;
        return;
      } else {
        maxTokens = tokenUsageResponse.totalTokens;
        _remainingTokens = tokenUsageResponse.availableTokens;
      }
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching token usage: $e');
    }
  }
}
