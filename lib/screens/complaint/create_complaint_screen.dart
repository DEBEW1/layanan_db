import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/complaint_model.dart';
import '../../services/complaint_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_text_field.dart';

class CreateComplaintScreen extends StatefulWidget {
  const CreateComplaintScreen({super.key});

  @override
  State<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends State<CreateComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ComplaintService _complaintService = ComplaintService();

  ComplaintCategory _selectedCategory = ComplaintCategory.infrastruktur;
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Kompresi gambar agar tidak terlalu besar
      );
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      _showSnackBar('Gagal memilih gambar.');
    }
  }

  Future<void> _submitComplaint() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _complaintService.submitComplaint(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        evidencePath: _selectedImage?.path,
      );

      if (!mounted) return;

      if (success) {
        _showSnackBar('Pengaduan berhasil dikirim!', isError: false);
        Navigator.of(context).pop(true); // Kirim 'true' untuk refresh
      } else {
        _showSnackBar('Gagal mengirim pengaduan.');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.secondaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Pengaduan Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Judul Pengaduan',
                controller: _titleController,
                validator: (val) => (val?.isEmpty ?? true) ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              const Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<ComplaintCategory>(
                value: _selectedCategory,
                onChanged: (val) => setState(() => _selectedCategory = val!),
                items: ComplaintCategory.values.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat.displayName));
                }).toList(),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Deskripsi Lengkap',
                controller: _descriptionController,
                maxLines: 5,
                validator: (val) => (val?.isEmpty ?? true) ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              _buildImagePicker(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitComplaint,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Kirim Pengaduan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bukti Foto (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_selectedImage != null)
          Stack(
            alignment: Alignment.topRight,
            children: [
              Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity, height: 200),
              IconButton(
                icon: const CircleAvatar(backgroundColor: Colors.black54, child: Icon(Icons.close, color: Colors.white)),
                onPressed: () => setState(() => _selectedImage = null),
              ),
            ],
          )
        else
          OutlinedButton.icon(
            icon: const Icon(Icons.attach_file),
            label: const Text('Pilih Gambar'),
            onPressed: _pickImage,
          ),
      ],
    );
  }
}