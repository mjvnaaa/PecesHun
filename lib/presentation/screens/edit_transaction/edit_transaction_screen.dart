import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:apkpribadi/core/constants.dart';
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

class EditTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  late TransactionType _selectedType;
  late String _selectedCategory;
  late DateTime _selectedDate;

  File? _newFile;
  String? _existingAttachmentPath;
  bool _attachmentWasRemoved = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _amountController.text = tx.amount.toStringAsFixed(0);
    _notesController.text = tx.notes ?? '';
    _selectedType = tx.type;
    _selectedCategory = tx.category;
    _selectedDate = tx.date;
    _existingAttachmentPath = tx.attachmentPath;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<String?> _saveFileToAppDirectory(File file) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final localPath = '${appDir.path}/attachments';
      final localDir = Directory(localPath);
      if (!await localDir.exists()) {
        await localDir.create(recursive: true);
      }
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
      final newPath = '$localPath/$fileName';
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

  Future<void> _pickFromCamera() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _newFile = File(image.path);
        _attachmentWasRemoved = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newFile = File(image.path);
        _attachmentWasRemoved = false;
      });
    }
  }

  Future<void> _pickFromFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _newFile = File(result.files.single.path!);
        _attachmentWasRemoved = false;
      });
    }
  }

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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      String? finalAttachmentPath = _existingAttachmentPath;

      if (_newFile != null) {
        finalAttachmentPath = await _saveFileToAppDirectory(_newFile!);
      } else if (_attachmentWasRemoved) {
        finalAttachmentPath = null;
      }

      final updatedTransaction = TransactionModel(
        id: widget.transaction.id,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: _selectedDate,
        type: _selectedType,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        attachmentPath: finalAttachmentPath,
      );

      try {
        await ref
            .read(transactionListProvider.notifier)
            .updateTransaction(updatedTransaction);

        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaksi berhasil diperbarui!'),
              backgroundColor: AppColors.income,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _selectedType == TransactionType.income
        ? kIncomeCategories
        : kExpenseCategories;
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    String attachmentText = 'Tambah Bukti Transaksi';
    bool hasAttachment = false;
    if (_newFile != null) {
      attachmentText = p.basename(_newFile!.path);
      hasAttachment = true;
    } else if (_existingAttachmentPath != null && !_attachmentWasRemoved) {
      attachmentText = p.basename(_existingAttachmentPath!);
      hasAttachment = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transaksi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              Card(
                elevation: 0,
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.5),
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
                    attachmentText,
                    style: TextStyle(
                      fontStyle:
                          hasAttachment ? FontStyle.normal : FontStyle.italic,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: hasAttachment
                      ? IconButton(
                          icon: const Icon(Iconsax.close_circle,
                              color: AppColors.expense),
                          onPressed: () {
                            setState(() {
                              _newFile = null;
                              _existingAttachmentPath = null;
                              _attachmentWasRemoved = true;
                            });
                          },
                        )
                      : const Icon(Iconsax.arrow_right_3),
                  onTap: _showAttachmentPicker,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Iconsax.save_2),
                label: const Text('Simpan Perubahan'),
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