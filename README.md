# Aplikasi Inventaris Mobile - Responsi 2 Paket 1

## Informasi Pengembang

| Aspek          | Keterangan                        |
| -------------- | --------------------------------- |
| **Nama**       | Muhammad Nugrahhadi Al Khawarizmi |
| **NIM**        | H1D023055                         |
| **Shift Baru** | A                                 |
| **Shift Asal** | G                                 |

---

## Deskripsi Aplikasi

Aplikasi Inventaris Mobile adalah aplikasi Flutter yang digunakan untuk mengelola data inventaris barang. Aplikasi ini memungkinkan pengguna untuk:

- Registrasi dan login
- Melihat daftar inventaris barang
- Menambah barang inventaris baru
- Mengubah data barang inventaris
- Menghapus barang dari inventaris
- Melihat detail barang inventaris

---

## Demo Video
https://github.com/user-attachments/assets/075b2180-7833-48fc-bb31-9098660c331d

---

## Spesifikasi API

### Base URL

```
http://10.0.2.2:8080
```

_(Untuk physical device: ganti dengan 192.168.1.4:8080)_
_(Untuk web: ganti dengan localhost:8080)_

### Authentication Endpoints

#### 1. Register User Baru

```
POST /register

Request Body:
{
  "username": "string",
  "password": "string"
}

Response (201 Created):
{
  "success": true,
  "message": "Registrasi berhasil",
  "data": {
    "id": "integer",
    "username": "string",
    "token": "string"
  }
}
```

#### 2. Login User

```
POST /login

Request Body:
{
  "username": "string",
  "password": "string"
}

Response (200 OK):
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "id": "string",
    "username": "string",
    "token": "string"
  }
}
```

---

## Inventaris Endpoints

_Memerlukan Bearer Token dalam header Authorization_

#### Header Untuk Semua Request (kecuali Register & Login):

```
Authorization: Bearer {token}
Host: Responsi_2_Mobile.test
Content-Type: application/x-www-form-urlencoded
```

### 1. Get List Inventaris

```
GET /inventaris

Response (200 OK):
{
  "success": true,
  "message": "Data inventaris berhasil diambil",
  "data": [
    {
      "id": "integer",
      "nama": "string",
      "harga": "string/integer",
      "jumlah": "string/integer",
      "tanggal_masuk": "YYYY-MM-DD",
      "created_at": "timestamp",
      "updated_at": "timestamp"
    }
  ]
}
```

### 2. Create Inventaris (Tambah Barang Baru)

```
POST /inventaris

Request Body:
{
  "nama": "string",
  "harga": "integer",
  "jumlah": "integer",
  "tanggal_masuk": "YYYY-MM-DD"
}

Response (201 Created):
{
  "success": true,
  "message": "Data inventaris berhasil dibuat",
  "data": {
    "id": "integer",
    "nama": "string",
    "harga": "integer",
    "jumlah": "integer",
    "tanggal_masuk": "YYYY-MM-DD"
  }
}
```

### 3. Update Inventaris (Ubah Data Barang)

```
PUT /inventaris/{id}

Path Parameter:
- id: integer (ID barang yang akan diubah)

Request Body:
{
  "nama": "string",
  "harga": "integer",
  "jumlah": "integer",
  "tanggal_masuk": "YYYY-MM-DD"
}

Response (200 OK):
{
  "success": true,
  "message": "Data inventaris berhasil diperbarui"
}
```

### 4. Delete Inventaris (Hapus Barang)

```
DELETE /inventaris/{id}

Path Parameter:
- id: integer (ID barang yang akan dihapus)

Response (200 OK):
{
  "success": true,
  "message": "Data inventaris berhasil dihapus"
}
```

### 5. Get Detail Inventaris

```
GET /inventaris/{id}

Path Parameter:
- id: integer (ID barang)

Response (200 OK):
{
  "success": true,
  "data": {
    "id": "integer",
    "nama": "string",
    "harga": "string/integer",
    "jumlah": "string/integer",
    "tanggal_masuk": "YYYY-MM-DD",
    "created_at": "timestamp",
    "updated_at": "timestamp"
  }
}
```

---

## Penjelasan Kode

### lib/main.dart

#### `main()`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
```

**Penjelasan:**

- Entry point aplikasi Flutter
- `WidgetsFlutterBinding.ensureInitialized()` memastikan binding Flutter siap sebelum aplikasi dimulai
- Mejalankan aplikasi dengan `MyApp()` sebagai root widget

#### `MyApp`

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventaris App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}
```

**Penjelasan:**

- Konfigurasi MaterialApp untuk tema dan styling aplikasi
- Menetapkan `AuthWrapper` sebagai home widget untuk pengecekan login otomatis
- `debugShowCheckedModeBanner: false` menghilangkan banner debug

#### `AuthWrapper`

```dart
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return authProvider.isLoggedIn
          ? const HomeScreen()
          : const LoginScreen();
      },
    );
  }
}
```

**Penjelasan:**

- Widget yang menentukan navigasi berdasarkan status login
- `initState()` memanggil `checkLoginStatus()` untuk mengecek apakah user sudah login
- `Consumer<AuthProvider>` mendengarkan perubahan state dari AuthProvider
- Jika login, tampilkan `HomeScreen`, jika belum, tampilkan `LoginScreen`

---

### lib/providers/auth_provider.dart

#### `checkLoginStatus()`

```dart
Future<void> checkLoginStatus() async {
  final token = await UserInfo().getToken();
  final userId = await UserInfo().getUserID();
  final username = await UserInfo().getUsername();

  _isLoggedIn = token != null;
  _username = username;
  _userId = userId;
  notifyListeners();
}
```

**Penjelasan:**

- Mengecek apakah token tersimpan di SharedPreferences
- Jika token ada, user dianggap sudah login
- Mengambil user ID dan username dari penyimpanan lokal
- `notifyListeners()` memberitahu consumer untuk rebuild

#### `login(String username, String password)`

```dart
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
  } catch (e) {
    _errorMessage = 'Error: $e';
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
```

**Penjelasan:**

- POST request ke endpoint `/login` dengan username dan password
- Jika berhasil, simpan token, user ID, dan username ke SharedPreferences
- Update state `_isLoggedIn` menjadi true
- Return true jika login sukses, false jika gagal
- Menangani error dengan try-catch

#### `register(String username, String password)`

```dart
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
  } catch (e) {
    _errorMessage = 'Error: $e';
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
```

**Penjelasan:**

- POST request ke endpoint `/register` dengan username dan password baru
- Jika registrasi berhasil, user dapat langsung login
- Return true jika registrasi sukses

#### `logout()`

```dart
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
```

**Penjelasan:**

- Menghapus semua data login dari SharedPreferences
- Reset semua state variable
- `notifyListeners()` memberitahu untuk redirect ke login screen

---

### lib/helpers/api.dart

#### `post(url, data)`

```dart
Future<dynamic> post(dynamic url, dynamic data) async {
  var token = await UserInfo().getToken();

  print("POST Request ke: $url");
  print("Data: $data");

  try {
    final response = await http.post(
      Uri.parse(url),
      body: data,
      headers: {
        'Host': 'Responsi_2_Mobile.test',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return _returnResponse(response);
  } catch (e) {
    print("ERROR POST: $e");
    rethrow;
  }
}
```

**Penjelasan:**

- Membuat HTTP POST request dengan body dan headers
- Menambahkan Authorization header jika token tersedia
- Memanggil `_returnResponse()` untuk parse dan validasi response
- Jika error, throw exception

#### `get(url)`

```dart
Future<dynamic> get(String url) async {
  var token = await UserInfo().getToken();

  print("GET Request ke: $url");

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Host': 'Responsi_2_Mobile.test',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return _returnResponse(response);
  } catch (e) {
    print("ERROR GET: $e");
    rethrow;
  }
}
```

**Penjelasan:**

- Membuat HTTP GET request dengan headers
- Menambahkan token di header jika tersedia
- Parse response dan return hasilnya

#### `put(url, data)`

```dart
Future<dynamic> put(String url, dynamic data) async {
  var token = await UserInfo().getToken();

  print("PUT Request ke: $url");

  try {
    final response = await http.put(
      Uri.parse(url),
      body: data,
      headers: {
        'Host': 'Responsi_2_Mobile.test',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return _returnResponse(response);
  } catch (e) {
    print("ERROR PUT: $e");
    rethrow;
  }
}
```

**Penjelasan:**

- Membuat HTTP PUT request untuk update data
- Mengirim data dan headers seperti POST
- Digunakan untuk update inventaris yang sudah ada

#### `delete(url)`

```dart
Future<dynamic> delete(String url) async {
  var token = await UserInfo().getToken();

  print("DELETE Request ke: $url");

  try {
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Host': 'Responsi_2_Mobile.test',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return _returnResponse(response);
  } catch (e) {
    print("ERROR DELETE: $e");
    rethrow;
  }
}
```

**Penjelasan:**

- Membuat HTTP DELETE request untuk menghapus data
- Menambahkan Authorization header dengan token
- Return response setelah parse

#### `_returnResponse(response)`

```dart
dynamic _returnResponse(http.Response response) {
  switch (response.statusCode) {
    case 200:
    case 201:
      try {
        var responseJson = json.decode(response.body);
        print("PARSED RESPONSE: $responseJson");
        return responseJson;
      } catch (e) {
        print("ERROR PARSING JSON: $e");
        rethrow;
      }
    case 400:
      throw BadRequestException(response.body.toString());
    case 401:
    case 403:
      throw UnauthorisedException(response.body.toString());
    case 404:
      throw NotFoundException(response.body.toString());
    default:
      throw FetchDataException('Error ${response.statusCode}');
  }
}
```

**Penjelasan:**

- Validasi HTTP status code response
- Status 200 dan 201 dianggap sukses
- Parse response JSON
- Throw exception khusus sesuai status code untuk error handling
- 400 = Bad Request
- 401/403 = Unauthorized/Forbidden
- 404 = Not Found

---

### lib/helpers/api_url.dart

```dart
class ApiUrl {
  // - Android Emulator: 10.0.2.2 (alias ke host machine)
  // - Physical Device: 192.168.1.4 (Wi-Fi IP host machine)
  // - Web: localhost:8080 (running on browser)
  static const String baseUrl = "http://10.0.2.2:8080";

  static const String registrasi = "$baseUrl/register";
  static const String login = "$baseUrl/login";
  static const String listInventaris = "$baseUrl/inventaris";
  static const String createInventaris = "$baseUrl/inventaris";

  static String updateInventaris(int id) {
    return "$baseUrl/inventaris/$id";
  }

  static String showInventaris(int id) {
    return "$baseUrl/inventaris/$id";
  }

  static String deleteInventaris(int id) {
    return "$baseUrl/inventaris/$id";
  }
}
```

**Penjelasan:**

- Centralized configuration untuk semua API endpoints
- `baseUrl` dapat disesuaikan dengan environment (emulator/physical/web)
- Setiap endpoint tersimpan sebagai constant static
- Method untuk dynamic routes (update, show, delete) menerima parameter `id`

---

### lib/helpers/user_info.dart

```dart
class UserInfo {
  static const String _tokenKey = 'token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> setUserID(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, id);
  }

  Future<int?> getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
```

**Penjelasan:**

- Helper class untuk mengelola penyimpanan data lokal (SharedPreferences)
- `setToken()` - Menyimpan JWT token setelah login
- `getToken()` - Mengambil token yang tersimpan
- `setUserID()` - Menyimpan ID user
- `getUserID()` - Mengambil ID user
- `setUsername()` - Menyimpan nama user
- `getUsername()` - Mengambil nama user
- `logout()` - Menghapus semua data termasuk token

---

### lib/screens/login_screen.dart

#### `build()`

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Login')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            child: _isLoading
              ? CircularProgressIndicator()
              : Text('Login'),
          ),
        ],
      ),
    ),
  );
}
```

**Penjelasan:**

- Build login form dengan username dan password fields
- TextFields untuk input username dan password
- ElevatedButton untuk trigger login
- Menampilkan loading indicator saat proses login

#### `_login()`

```dart
void _login() async {
  if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Username dan password tidak boleh kosong')),
    );
    return;
  }

  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final success = await authProvider.login(
    _usernameController.text,
    _passwordController.text,
  );

  if (success) {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(authProvider.errorMessage ?? 'Login gagal')),
    );
  }
}
```

**Penjelasan:**

- Validasi input username dan password tidak kosong
- Memanggil `authProvider.login()` dengan credentials
- Jika login sukses, navigate ke home screen
- Jika gagal, tampilkan error message

---

### lib/screens/register_screen.dart

#### `_register()`

```dart
void _register() async {
  if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
    _showSnackBar('Username dan password tidak boleh kosong');
    return;
  }

  if (_passwordController.text != _confirmPasswordController.text) {
    _showSnackBar('Password tidak cocok');
    return;
  }

  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final success = await authProvider.register(
    _usernameController.text,
    _passwordController.text,
  );

  if (success) {
    _showSnackBar('Registrasi berhasil, silahkan login');
    if (mounted) {
      Navigator.pop(context);
    }
  } else {
    _showSnackBar(authProvider.errorMessage ?? 'Registrasi gagal');
  }
}
```

**Penjelasan:**

- Validasi field username dan password tidak kosong
- Cek apakah password dan confirm password cocok
- Memanggil `authProvider.register()` untuk registrasi
- Jika sukses, kembali ke login screen
- Jika gagal, tampilkan error message

---

### lib/screens/home_screen.dart

#### `initState()`

```dart
@override
void initState() {
  super.initState();
  _loadUserData();
  _loadInventaris();
}

Future<void> _loadUserData() async {
  final username = await UserInfo().getUsername();
  setState(() {
    _username = username ?? 'User';
  });
}

Future<void> _loadInventaris() async {
  try {
    final inventarisData = await Api().get(ApiUrl.listInventaris);
    setState(() {
      _inventaris = List<Map<String, dynamic>>.from(
        inventarisData['data'] ?? [],
      );
    });
  } catch (e) {
    print('Error loading inventaris: $e');
    _showSnackBar('Gagal memuat data inventaris');
  }
}
```

**Penjelasan:**

- `initState()` dipanggil saat widget pertama kali dibuat
- `_loadUserData()` mengambil username dari storage untuk ditampilkan di drawer
- `_loadInventaris()` melakukan GET request ke `/inventaris` untuk mengambil data
- Update state `_inventaris` dengan data dari API

#### `_deleteInventaris(id)`

```dart
Future<void> _deleteInventaris(int id) async {
  try {
    final response = await Api().delete(ApiUrl.deleteInventaris(id));

    if (response['success'] == true) {
      _showSnackBar('Data berhasil dihapus', Colors.green);
      _loadInventaris();
    } else {
      _showSnackBar(response['message'] ?? 'Gagal menghapus', Colors.red);
    }
  } catch (e) {
    _showSnackBar('Error: $e', Colors.red);
  }
}
```

**Penjelasan:**

- Melakukan DELETE request ke `/inventaris/{id}`
- Jika sukses, reload list inventaris
- Tampilkan pesan success atau error

#### `_logout()`

```dart
void _logout() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  await authProvider.logout();

  if (mounted) {
    Navigator.pushReplacementNamed(context, '/login');
  }
}
```

**Penjelasan:**

- Memanggil `authProvider.logout()` untuk hapus token
- Navigate ke login screen dengan pushReplacement (tidak bisa back)

---

### lib/screens/add_edit_screen.dart

#### `initState()`

```dart
@override
void initState() {
  super.initState();
  _isEditMode = widget.inventaris != null;

  try {
    final nama = _safeToString(widget.inventaris?['nama']) ?? '';
    final hargaValue = _extractNumber(widget.inventaris?['harga']);
    final harga = hargaValue > 0 ? hargaValue.toString() : '';
    final jumlahValue = _extractNumber(widget.inventaris?['jumlah']);
    final jumlah = jumlahValue > 0 ? jumlahValue.toString() : '';
    final tanggalMasuk = _safeToString(widget.inventaris?['tanggal_masuk']) ?? '';

    _namaController = TextEditingController(text: nama);
    _hargaController = TextEditingController(text: harga);
    _jumlahController = TextEditingController(text: jumlah);
    _tanggalMasukController = TextEditingController(text: tanggalMasuk);
  } catch (e) {
    _namaController = TextEditingController();
    _hargaController = TextEditingController();
    _jumlahController = TextEditingController();
    _tanggalMasukController = TextEditingController();
  }
}
```

**Penjelasan:**

- `_isEditMode` true jika `widget.inventaris` tidak null (update), false jika add baru
- Initialize TextEditingControllers dengan data existing (jika edit mode)
- `_safeToString()` - konversi aman ke string dengan null handling
- `_extractNumber()` - ekstrak number dari berbagai tipe (String, int, double)

#### `_extractNumber()`

```dart
int _extractNumber(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }
  return 0;
}
```

**Penjelasan:**

- Helper untuk parse number dari berbagai tipe data
- Jika String, hapus non-numeric characters dengan regex `[^0-9]`
- Return 0 jika parsing gagal

#### `_submit()`

```dart
void _submit() async {
  if (_namaController.text.isEmpty || _hargaController.text.isEmpty ||
      _jumlahController.text.isEmpty || _tanggalMasukController.text.isEmpty) {
    _showSnackBar('Semua field harus diisi', Colors.red);
    return;
  }

  final hargaValue = int.tryParse(_hargaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  final jumlahValue = int.tryParse(_jumlahController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  if (hargaValue <= 0 || jumlahValue <= 0) {
    _showSnackBar('Harga dan jumlah harus lebih dari 0', Colors.red);
    return;
  }

  setState(() => _isLoading = true);

  try {
    dynamic result;

    if (_isEditMode) {
      final inventarisId = widget.inventaris!['id'];
      final idValue = inventarisId is int
        ? inventarisId
        : int.tryParse(inventarisId.toString()) ?? 0;

      final updateUrl = ApiUrl.updateInventaris(idValue);
      final updateData = {
        'nama': _namaController.text.trim(),
        'harga': hargaValue.toString(),
        'jumlah': jumlahValue.toString(),
        'tanggal_masuk': _tanggalMasukController.text.trim(),
      };

      result = await Api().put(updateUrl, updateData);
    } else {
      final createData = {
        'nama': _namaController.text.trim(),
        'harga': hargaValue.toString(),
        'jumlah': jumlahValue.toString(),
        'tanggal_masuk': _tanggalMasukController.text.trim(),
      };

      result = await Api().post(ApiUrl.createInventaris, createData);
    }

    setState(() => _isLoading = false);

    if (result != null && result is Map<String, dynamic>) {
      final success = result['success'] == true ||
                     result['success'] == 'true' ||
                     result['success'] == 1;

      if (success) {
        _showSnackBar(
          result['message'] ?? (_isEditMode ? 'Data berhasil diperbarui' : 'Data berhasil ditambahkan'),
          Colors.green,
        );
        widget.onSaved();
        if (mounted) Navigator.pop(context);
      } else {
        _showSnackBar(result['message'] ?? 'Gagal menyimpan data', Colors.red);
      }
    }
  } catch (e, stackTrace) {
    setState(() => _isLoading = false);
    _showSnackBar('Error: $e', Colors.red);
  }
}
```

**Penjelasan:**

- Validasi semua field tidak kosong
- Parse harga dan jumlah ke integer, hapus non-numeric characters
- Validasi harga dan jumlah > 0
- Jika edit mode: call PUT `/inventaris/{id}`
- Jika add mode: call POST `/inventaris`
- Kirim data sebagai String (sesuai format form-encoded)
- Flexible success checking (handle bool, string, int)
- Pop navigator jika sukses

#### `_selectDate()`

```dart
void _selectDate() async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime.now(),
  );

  if (picked != null) {
    _tanggalMasukController.text =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
  }
}
```

**Penjelasan:**

- Show Flutter built-in DatePicker dialog
- Batasan tanggal dari 2000 hingga hari ini
- Format hasil menjadi `YYYY-MM-DD`
- Update TextEditingController dengan tanggal terpilih

---

### lib/helpers/app_exception.dart

```dart
class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class BadRequestException extends AppException {
  BadRequestException(String message) : super(message);
}

class UnauthorisedException extends AppException {
  UnauthorisedException(String message) : super(message);
}

class NotFoundException extends AppException {
  NotFoundException(String message) : super(message);
}

class FetchDataException extends AppException {
  FetchDataException(String message) : super(message);
}
```

**Penjelasan:**

- Custom exception classes untuk error handling
- `BadRequestException` - Status 400 (input tidak valid)
- `UnauthorisedException` - Status 401/403 (token tidak valid/expired)
- `NotFoundException` - Status 404 (data tidak ditemukan)
- `FetchDataException` - Error lainnya

---

## Struktur Folder Proyek

```
lib/
├── main.dart                    # Entry point aplikasi
├── helpers/
│   ├── api.dart               # HTTP wrapper dengan logging
│   ├── api_url.dart           # Centralized API endpoints
│   ├── app_exception.dart      # Custom exceptions
│   └── user_info.dart         # SharedPreferences management
├── providers/
│   └── auth_provider.dart      # Authentication state management
├── screens/
│   ├── login_screen.dart      # Login UI
│   ├── register_screen.dart   # Register UI
│   ├── home_screen.dart       # Home/List inventaris
│   ├── add_edit_screen.dart   # Add/Edit inventaris
│   └── detail_screen.dart     # Detail inventaris
└── services/
    └── api_service.dart       # Alternative API service layer
```


