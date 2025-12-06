import 'package:flutter/material.dart';
import '../helpers/api.dart';
import '../helpers/api_url.dart';

class AddEditScreen extends StatefulWidget {
  final Map<String, dynamic>? inventaris;
  final VoidCallback onSaved;

  const AddEditScreen({
    super.key,
    this.inventaris,
    required this.onSaved,
  });

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  late final TextEditingController _namaController;
  late final TextEditingController _hargaController;
  late final TextEditingController _jumlahController;
  late final TextEditingController _tanggalMasukController;

  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.inventaris != null;

    print('===========================================');
    print('INIT EDIT MODE: $_isEditMode');
    if (_isEditMode) {
      print('Inventaris data: ${widget.inventaris}');
    }
    print('===========================================');

    try {
      final nama = _safeToString(widget.inventaris?['nama']) ?? '';

      final hargaValue = _extractNumber(widget.inventaris?['harga']);
      final harga = hargaValue > 0 ? hargaValue.toString() : '';

      final jumlahValue = _extractNumber(widget.inventaris?['jumlah']);
      final jumlah = jumlahValue > 0 ? jumlahValue.toString() : '';
      
      final tanggalMasuk = _safeToString(widget.inventaris?['tanggal_masuk']) ?? '';
      
      print('Parsed values: nama=$nama, harga=$harga, jumlah=$jumlah, tanggalMasuk=$tanggalMasuk');
      
      _namaController = TextEditingController(text: nama);
      _hargaController = TextEditingController(text: harga);
      _jumlahController = TextEditingController(text: jumlah);
      _tanggalMasukController = TextEditingController(text: tanggalMasuk);
      
      print('Controllers initialized successfully');
      print('===========================================');
    } catch (e) {
      print('ERROR INIT CONTROLLERS: $e');
      print('===========================================');

      _namaController = TextEditingController();
      _hargaController = TextEditingController();
      _jumlahController = TextEditingController();
      _tanggalMasukController = TextEditingController();
    }
  }

  String? _safeToString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  int _extractNumber(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.toInt();

    if (value is String) {
      return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }

    return 0;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _jumlahController.dispose();
    _tanggalMasukController.dispose();
    super.dispose();
  }

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

  void _submit() async {
    if (_namaController.text.isEmpty) {
      _showSnackBar('Nama tidak boleh kosong', Colors.red);
      return;
    }

    if (_hargaController.text.isEmpty) {
      _showSnackBar('Harga tidak boleh kosong', Colors.red);
      return;
    }

    if (_jumlahController.text.isEmpty) {
      _showSnackBar('Jumlah tidak boleh kosong', Colors.red);
      return;
    }

    if (_tanggalMasukController.text.isEmpty) {
      _showSnackBar('Tanggal masuk tidak boleh kosong', Colors.red);
      return;
    }

    final hargaValue = int.tryParse(_hargaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final jumlahValue = int.tryParse(_jumlahController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    if (hargaValue <= 0) {
      _showSnackBar('Harga harus lebih dari 0', Colors.red);
      return;
    }

    if (jumlahValue <= 0) {
      _showSnackBar('Jumlah harus lebih dari 0', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      dynamic result;

      if (_isEditMode) {
        try {

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
          
          print('===========================================');
          print('UPDATE INVENTARIS START');
          print('ID: $idValue (type: ${idValue.runtimeType})');
          print('URL: $updateUrl');
          print('Data: $updateData');
          print('===========================================');
          
          result = await Api().put(updateUrl, updateData);
          
          print('===========================================');
          print('UPDATE RESPONSE: $result');
          print('===========================================');

          setState(() {
            _isLoading = false;
          });

          if (result != null && result is Map<String, dynamic>) {
            final success = result['success'] == true || 
                           result['success'] == 'true' ||
                           result['success'] == 1;
            
            if (success) {
              _showSnackBar(
                result['message'] ?? 'Data berhasil diperbarui',
                Colors.green,
              );
              widget.onSaved();
              if (mounted) {
                Navigator.pop(context);
              }
            } else {
              _showSnackBar(
                result['message'] ?? 'Gagal memperbarui data',
                Colors.red,
              );
            }
          } else {
            _showSnackBar('Response tidak valid', Colors.red);
          }
        } catch (updateError, updateStackTrace) {
          print('===========================================');
          print('ERROR DURING UPDATE: $updateError');
          print('Stack: $updateStackTrace');
          print('===========================================');
          
          setState(() {
            _isLoading = false;
          });
          
          _showSnackBar('Error update: $updateError', Colors.red);
        }
      } else {
        try {
          final createData = {
            'nama': _namaController.text.trim(),
            'harga': hargaValue.toString(),
            'jumlah': jumlahValue.toString(),
            'tanggal_masuk': _tanggalMasukController.text.trim(),
          };
          
          print('===========================================');
          print('CREATE INVENTARIS START');
          print('URL: ${ApiUrl.createInventaris}');
          print('Data: $createData');
          print('===========================================');
          
          result = await Api().post(ApiUrl.createInventaris, createData);
          
          print('===========================================');
          print('CREATE RESPONSE: $result');
          print('===========================================');

          setState(() {
            _isLoading = false;
          });

          if (result != null && result is Map<String, dynamic>) {
            final success = result['success'] == true || 
                           result['success'] == 'true' ||
                           result['success'] == 1;
            
            if (success) {
              _showSnackBar(
                result['message'] ?? 'Data berhasil ditambahkan',
                Colors.green,
              );
              widget.onSaved();
              if (mounted) {
                Navigator.pop(context);
              }
            } else {
              _showSnackBar(
                result['message'] ?? 'Gagal menambah data',
                Colors.red,
              );
            }
          } else {
            _showSnackBar('Response tidak valid', Colors.red);
          }
        } catch (createError, createStackTrace) {
          print('===========================================');
          print('ERROR DURING CREATE: $createError');
          print('Stack: $createStackTrace');
          print('===========================================');
          
          setState(() {
            _isLoading = false;
          });
          
          _showSnackBar('Error create: $createError', Colors.red);
        }
      }
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });
      print('===========================================');
      print('UNEXPECTED ERROR: $e');
      print('Stack: $stackTrace');
      print('===========================================');
      _showSnackBar('Unexpected error: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Inventaris' : 'Tambah Inventaris'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nama Barang',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _namaController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama barang',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Harga (Rp)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _hargaController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Masukkan harga',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Jumlah',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _jumlahController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Masukkan jumlah',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tanggal Masuk',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tanggalMasukController,
                enabled: !_isLoading,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Pilih tanggal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _isLoading ? null : _selectDate,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(_isEditMode ? 'Update' : 'Tambah'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
