import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../helpers/api.dart';
import '../helpers/api_url.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _inventarisList;

  @override
  void initState() {
    super.initState();
    _loadInventaris();
  }

  void _loadInventaris() {
    setState(() {
      _inventarisList = _fetchInventaris();
    });
  }

  Future<List<dynamic>> _fetchInventaris() async {
    try {
      final response = await Api().get(ApiUrl.listInventaris);
      if (response['success'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching inventaris: $e');
      return [];
    }
  }

  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _refreshData() {
    _loadInventaris();
  }

  void _deleteInventaris(dynamic id) async {
    try {
      final result = await Api().delete(ApiUrl.deleteInventaris(int.parse(id.toString())));
      if (result['success'] == true) {
        _refreshData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal menghapus data'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDelete(dynamic id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteInventaris(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['nama'] ?? 'Detail Inventaris'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${item['id'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Nama: ${item['nama'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Harga: Rp${item['harga'] ?? 0}'),
              const SizedBox(height: 8),
              Text('Jumlah: ${item['jumlah'] ?? 0}'),
              const SizedBox(height: 8),
              Text('Tanggal Masuk: ${item['tanggal_masuk'] ?? 'N/A'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditScreen(
                    inventaris: item,
                    onSaved: _refreshData,
                  ),
                ),
              );
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Inventaris Komputer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _inventarisList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tidak ada data inventaris'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          final inventaris = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              _refreshData();
            },
            child: ListView.builder(
              itemCount: inventaris.length,
              itemBuilder: (context, index) {
                final item = inventaris[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListTile(
                    onTap: () {
                      _showDetailDialog(item);
                    },
                    title: Text(
                      item['nama'] ?? 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Harga: Rp${item['harga'] ?? 0}'),
                        Text('Jumlah: ${item['jumlah'] ?? 0}'),
                        Text(
                          'Tanggal Masuk: ${item['tanggal_masuk'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text('Edit'),
                          onTap: () {
                            print('===========================================');
                            print('EDIT BUTTON CLICKED');
                            print('Item: $item');
                            print('Item types: id=${item['id'].runtimeType}, harga=${item['harga'].runtimeType}, jumlah=${item['jumlah'].runtimeType}');
                            print('===========================================');
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddEditScreen(
                                  inventaris: item,
                                  onSaved: _refreshData,
                                ),
                              ),
                            );
                          },
                        ),
                        PopupMenuItem(
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () {
                            _confirmDelete(item['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditScreen(
                onSaved: _refreshData,
              ),
            ),
          );
        },
        tooltip: 'Tambah Inventaris',
        child: const Icon(Icons.add),
      ),
    );
  }
}
