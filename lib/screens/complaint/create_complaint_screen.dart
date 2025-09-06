import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/complaint_model.dart';
import '../../services/complaint_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/universal_image.dart';

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
  
  // Universal image handling
  File? _selectedImageFile; // Untuk mobile
  Uint8List? _selectedImageBytes; // Untuk web
  String? _selectedImagePath; // Path untuk upload
  
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        if (kIsWeb) {
          // Untuk Web - baca sebagai bytes
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImagePath = pickedFile.path;
          });
        } else {
          // Untuk Mobile - gunakan File
          setState(() {
            _selectedImageFile = File(pickedFile.path);
            _selectedImagePath = pickedFile.path;
          });
        }
      }
    } catch (e) {
      _showSnackBar('Gagal memilih gambar: ${e.toString()}');
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
        evidencePath: _selectedImagePath,
      );

      if (!mounted) return;

      if (success) {
        _showSnackBar('Pengaduan berhasil dikirim!', isError: false);
        Navigator.of(context).pop(true);
      } else {
        _showSnackBar('Gagal mengirim pengaduan.');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: ${e.toString()}');
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
        
        // Tampilkan gambar yang dipilih
        if (_hasSelectedImage())
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: UniversalImage(
                  imageSource: kIsWeb ? _selectedImageBytes : _selectedImageFile,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedImageFile = null;
                    _selectedImageBytes = null;
                    _selectedImagePath = null;
                  }),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          )
        else
          // Tombol pilih gambar
          OutlinedButton.icon(
            icon: const Icon(Icons.attach_file),
            label: const Text(kIsWeb ? 'Pilih Gambar (Web)' : 'Pilih Gambar'),
            onPressed: _pickImage,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
      ],
    );
  }

  bool _hasSelectedImage() {
    return (kIsWeb && _selectedImageBytes != null) || 
           (!kIsWeb && _selectedImageFile != null);
  }
}