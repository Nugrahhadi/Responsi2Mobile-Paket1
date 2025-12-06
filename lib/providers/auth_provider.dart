import 'package:flutter/material.dart';
import '../helpers/api.dart';
import '../helpers/api_url.dart';
import '../helpers/user_info.dart';
import '../helpers/app_exception.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _username;
  int? _userId;
  String? _errorMessage;
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  int? get userId => _userId;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> checkLoginStatus() async {
    final token = await UserInfo().getToken();
    final userId = await UserInfo().getUserID();
    final username = await UserInfo().getUsername();
    
    _isLoggedIn = token != null;
    _username = username;
    _userId = userId;
    notifyListeners();
  }

  Future<bool> register(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Api().post(
        ApiUrl.registrasi,
        {'username': username, 'password': password},
      );

      if (response['success'] == true) {
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Register gagal';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on BadRequestException catch (e) {
      _errorMessage = 'Data tidak valid: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    } on UnprocessableEntityException catch (e) {
      _errorMessage = 'Username sudah terdaftar: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Api().post(
        ApiUrl.login,
        {'username': username, 'password': password},
      );

      if (response['success'] == true) {
        final user = response['data'] ?? {};
        await UserInfo().setToken(user['token'] ?? '');
        await UserInfo().setUserID(int.tryParse(user['id']?.toString() ?? '0') ?? 0);
        await UserInfo().setUsername(user['username'] ?? '');

        _isLoggedIn = true;
        _username = user['username'];
        _userId = int.tryParse(user['id']?.toString() ?? '0') ?? 0;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Login gagal';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on UnauthorisedException catch (e) {
      _errorMessage = 'Username atau password salah: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await UserInfo().logout();

    _isLoggedIn = false;
    _username = null;
    _userId = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
