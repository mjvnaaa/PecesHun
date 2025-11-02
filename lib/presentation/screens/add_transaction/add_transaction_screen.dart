// lib/presentation/screens/add_transaction/add_transaction_screen.dart
import 'dart:io';
import 'package:path/path.dart' as p; // <-- DIPERBAIKI: package:path
import 'package:apkpribadi/core/constants.dart'; // <-- DIPERBAIKI: Import konstanta
import 'package:apkpribadi/core/utils/formatters.dart';
import 'package:apkpribadi/data/models/transaction_model.dart';
import 'package:apkpribadi/providers/transaction_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

// --- DIHAPUS ---
// Daftar kategori dipindahkan ke core/constants.dart
// --- AKHIR PENGHAPUSAN ---

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers & State
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  String _selectedCategory = kExpenseCategories.first; // <-- Tetap aman
  DateTime _selectedDate = DateTime.now();
  File? _selectedFile; // File yang dipilih dari picker
  String? _savedAttachmentPath; // Path file setelah disalin ke folder app

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Fungsi utama untuk menyimpan file ke direktori aplikasi
  Future<String?> _saveFileToAppDirectory(File file) async {
    try {
      // 1. Dapatkan direktori dokumen aplikasi
      final appDir = await getApplicationDocumentsDirectory();

      // 2. Buat sub-folder 'attachments' jika belum ada
      final localPath = '${appDir.path}/attachments';
      final localDir = Directory(localPath);
      if (!await localDir.exists()) {
        await localDir.create(recursive: true);
      }

      // 3. Buat nama file unik (bisa gunakan timestamp)
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
      final newPath = '$localPath/$fileName';

      // 4. Salin file ke path baru
      final newFile = await file.copy(newPath);

      debugPrint('File disimpan di: ${newFile.path}');
      return newFile.path;
    } catch (e) {
      debugPrint('Error menyimpan file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan lampiran: $e')),
      );
      return null;
    }
  }

  // --- Opsi Pilihan File ---

  // 1. Ambil dari Kamera
  Future<void> _pickFromCamera() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
      });
    }
  }

  // 2. Ambil dari Galeri
  Future<void> _pickFromGallery() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
      });
    }
  }

  // 3. Ambil dari File Dokumen
  Future<void> _pickFromFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  // Tampilkan Modal Pilihan
  void _showAttachmentPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Iconsax.camera),
                title: const Text('Ambil Foto (Kamera)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.gallery),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.document),
                title: const Text('Pilih Dokumen File'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Logika Submit Form ---
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Tampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 1. Simpan file jika ada
      if (_selectedFile != null) {
        _savedAttachmentPath = await _saveFileToAppDirectory(_selectedFile!);
      }

      // 2. Buat Model Transaksi
      final newTransaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID Unik
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: _selectedDate,
        type: _selectedType,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        attachmentPath: _savedAttachmentPath,
      );

      // 3. Simpan ke Database via Riverpod
      try {
        await ref
            .read(transactionListProvider.notifier)
            .addTransaction(newTransaction);

        // Tutup loading & halaman
        if (mounted) {
          Navigator.pop(context); // Tutup loading
          Navigator.pop(context); // Tutup halaman AddTransaction
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaksi berhasil disimpan!'),
              backgroundColor: AppColors.income,
            ),
          );
        }
      } catch (e) {
        // Tutup loading
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update list kategori berdasarkan Tipe (Pemasukan/Pengeluaran)
    final categories = _selectedType == TransactionType.income
        ? kIncomeCategories
        : kExpenseCategories;

    // Pastikan _selectedCategory valid
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Tipe Transaksi
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Pengeluaran'),
                    icon: Icon(Iconsax.arrow_up_1),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Pemasukan'),
                    icon: Icon(Iconsax.arrow_down_2),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return _selectedType == TransactionType.expense
                            ? AppColors.expense.withOpacity(0.2)
                            : AppColors.income.withOpacity(0.2);
                      }
                      return null;
                    },
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return _selectedType == TransactionType.expense
                            ? AppColors.expense
                            : AppColors.income;
                      }
                      return Theme.of(context).colorScheme.onSurface;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Jumlah (Amount)
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Iconsax.money_3),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Format angka salah';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 3. Kategori
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Iconsax.category),
                ),
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 4. Tanggal
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tanggal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Iconsax.calendar_1),
                ),
                controller: TextEditingController(
                  text: Formatters.formatDate(_selectedDate),
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // 5. Catatan
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Iconsax.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // 6. Lampiran (Attachment)
              Card(
                elevation: 0,
                color:
                    Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.5))),
                child: ListTile(
                  leading: const Icon(Iconsax.attach_square),
                  title: Text(
                    _selectedFile == null
                        ? 'Tambah Bukti Transaksi'
                        : p.basename(_selectedFile!.path), // Tampilkan nama file
                    style: TextStyle(
                      fontStyle: _selectedFile == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: _selectedFile != null
                      ? IconButton(
                          icon: const Icon(Iconsax.close_circle,
                              color: AppColors.expense),
                          onPressed: () {
                            setState(() {
                              _selectedFile = null;
                              _savedAttachmentPath = null;
                            });
                          },
                        )
                      : const Icon(Iconsax.arrow_right_3),
                  onTap: _showAttachmentPicker,
                ),
              ),

              const SizedBox(height: 24),

              // 7. Tombol Simpan
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Iconsax.save_2),
                label: const Text('Simpan Transaksi'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}