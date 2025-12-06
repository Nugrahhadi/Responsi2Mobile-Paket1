import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // - Android Emulator: 10.0.2.2 (alias ke host machine)
  // - Physical Device: 192.168.1.4 (Wi-Fi IP host machine)
  // - Web: localhost:8080 (running on browser)
  static const String baseUrl = 'http://10.0.2.2:8080';
  
  static const Duration timeoutDuration = Duration(seconds: 30);

  static Future<Map<String, dynamic>> register(
      String username, String password) async {
    try {
      developer.log('Register attempt: $username');
      
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'Host': 'Responsi_2_Mobile.test',
        },
        body: {
          'username': username,
          'password': password,
        },
      ).timeout(timeoutDuration);

      developer.log('Register response: ${response.statusCode} - ${response.body}');

      if (response.body.startsWith('<html') || response.body.startsWith('<!DOCTYPE')) {
        return {
          'success': false,
          'message': 'Server error: Endpoint tidak ditemukan atau CI4 sedang error',
        };
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Registrasi berhasil',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Registrasi gagal (Status: ${response.statusCode})',
        };
      }
    } on http.ClientException catch (e) {
      developer.log('Register ClientException: $e');
      return {
        'success': false,
        'message': 'Koneksi error: $e. Pastikan backend CI4 sudah running di $baseUrl',
      };
    } on TimeoutException catch (e) {
      developer.log('Register TimeoutException: $e');
      return {
        'success': false,
        'message': 'Request timeout. Pastikan backend running.',
      };
    } catch (e) {
      developer.log('Register error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      developer.log('Login attempt: $username');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'Host': 'Responsi_2_Mobile.test',
        },
        body: {
          'username': username,
          'password': password,
        },
      ).timeout(timeoutDuration);

      developer.log('Login response: ${response.statusCode} - ${response.body}');

      if (response.body.startsWith('<html') || response.body.startsWith('<!DOCTYPE')) {
        return {
          'success': false,
          'message': 'Server error: Endpoint tidak ditemukan atau CI4 sedang error',
        };
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', data['data']['id'].toString());
        await prefs.setString('username', data['data']['username']);
        await prefs.setString('token', data['data']['token']);
        await prefs.setString('is_logged_in', 'true');

        return {
          'success': true,
          'message': data['message'] ?? 'Login berhasil',
          'user': data['data'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal (Status: ${response.statusCode})',
        };
      }
    } on http.ClientException catch (e) {
      developer.log('Login ClientException: $e');
      return {
        'success': false,
        'message': 'Koneksi error: $e. Pastikan backend CI4 sudah running di $baseUrl',
      };
    } on TimeoutException catch (e) {
      developer.log('Login TimeoutException: $e');
      return {
        'success': false,
        'message': 'Request timeout. Pastikan backend running.',
      };
    } catch (e) {
      developer.log('Login error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<List<dynamic>> getInventaris() async {
    try {
      developer.log('Get inventaris');
      
      final response = await http.get(
        Uri.parse('$baseUrl/inventaris'),
        headers: {
          'Accept': 'application/json',
          'Host': 'Responsi_2_Mobile.test',
        },
      ).timeout(timeoutDuration);

      developer.log('Get inventaris response: ${response.statusCode}');

      if (response.body.startsWith('<html') || response.body.startsWith('<!DOCTYPE')) {
        throw Exception('Server error: Endpoint tidak ditemukan');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Gagal mengambil data inventaris (${response.statusCode})');
      }
    } catch (e) {
      developer.log('Get inventaris error: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> getInventarisById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/inventaris/$id'),
        headers: {
          'Accept': 'application/json',
          'Host': 'Responsi_2_Mobile.test',
        },
      ).timeout(timeoutDuration);

      if (response.body.startsWith('<html') || response.body.startsWith('<!DOCTYPE')) {
        throw Exception('Server error');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Data tidak ditemukan');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> createInventaris({
    required String nama,
    required int harga,
    required int jumlah,
    required String tanggalMasuk,
  }) async {
    try {
      developer.log('Create inventaris: $nama');
      
      final response = await http.post(
        Uri.parse('$baseUrl/inventaris'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'Host': 'Responsi_2_Mobile.test',
        },
        body: {
          'nama': nama,
          'harga': harga.toString(),
          'jumlah': jumlah.toString(),
          'tanggal_masuk': tanggalMasuk,
        },
      ).timeout(timeoutDuration);

      developer.log('Create response: ${response.statusCode}');

      if (response.body.startsWith('<html') || response.body.startsWith('<!DOCTYPE')) {
        return {
          'success': false,
          'message': 'Server error: Endpoint tidak ditemukan',
        };
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Data berhasil ditambahkan',
          'id': data['id'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menambah data (${response.statusCode})',
        };
      }
    } catch (e) {
      developer.log('Create error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateInventaris(
    int id, {
    String? nama,
    int? harga,
    int? jumlah,
    String? tanggalMasuk,
  }) async {
    try {
      developer.log('Update inventaris: $id');
      
      final body = <String, String>{};
      if (nama != null) body['nama'] = nama;
      if (harga != null) body['harga'] = harga.toString();
      if (jumlah != null) body['jumlah'] = jumlah.toString();
      if (tanggalMasuk != null) body['tanggal_masuk'] = tanggalMasuk;

      final response = await http.put(
        Uri.parse('$baseUrl/inventaris/$id'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'Host': 'Responsi_2_Mobile.test',
        },
        body: body,
      ).timeout(timeoutDuration);

      developer.log('Update response: ${response.statusCode}');

      if (response.body.startsWith('<html') || response.body.startsWith('<!DOCTYPE')) {
        return {
          'success': false,
          'message': 'Server error: Endpoint tidak ditemukan',
        };
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Data berhasil diperbarui',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengupdate data (${response.statusCode})',
        };
      }
    } catch (e) {
      developer.log('Update error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteInventaris(int id) async {
    try {
      developer.log('Delete inventaris: $id');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/inventaris/$id'),
        headers: {
          'Accept': 'application/json',
          'Host': 'Responsi_2_Mobile.test',
        },
      ).timeout(timeoutDuration);

      developer.log('Delete response: ${response.statusCode}');

      if (response.body.startsWith('<html') || response.body.startsWith('<!DOCTYPE')) {
        return {
          'success': false,
          'message': 'Server error: Endpoint tidak ditemukan',
        };
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Data berhasil dihapus',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menghapus data (${response.statusCode})',
        };
      }
    } catch (e) {
      developer.log('Delete error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
