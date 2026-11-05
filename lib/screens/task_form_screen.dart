import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/task_model.dart';

/// Halaman 5: Form Tambah & Edit Tugas dengan validasi input dan exception handling
class TaskFormScreen extends StatefulWidget {
  final String? taskId; // null = Tambah Baru, non-null = Edit

  const TaskFormScreen({super.key, this.taskId});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _selectedDeadline;
  TaskPriority _selectedPriority = TaskPriority.sedang;
  TaskCategory _selectedCategory = TaskCategory.kuliah;
  String? _errorMessage;

  bool get _isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final task = context.readState.getTaskById(widget.taskId!);
      if (task != null) {
        _titleController.text = task.title;
        _noteController.text = task.note;
        _selectedDeadline = task.deadline;
        _selectedPriority = task.priority;
        _selectedCategory = task.category;
      }
    } else {
      // Default tenggat waktu 2 hari ke depan
      final now = DateTime.now();
      _selectedDeadline = DateTime(now.year, now.month, now.day).add(const Duration(days: 2));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadlineDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
        _errorMessage = null;
      });
    }
  }

  void _saveTask() {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      setState(() => _errorMessage = 'Harap periksa kolom input yang bertanda merah!');
      return;
    }

    if (_selectedDeadline == null) {
      setState(() => _errorMessage = 'Tanggal tenggat wajib ditentukan!');
      return;
    }

    final state = context.readState;
    String? error;

    if (_isEditing) {
      error = state.updateTask(
        id: widget.taskId!,
        title: _titleController.text,
        note: _noteController.text,
        deadline: _selectedDeadline!,
        priority: _selectedPriority,
        category: _selectedCategory,
      );
    } else {
      error = state.addTask(
        title: _titleController.text,
        note: _noteController.text,
        deadline: _selectedDeadline!,
        priority: _selectedPriority,
        category: _selectedCategory,
      );
    }

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text(_isEditing ? 'Tugas berhasil diperbarui!' : 'Tugas baru berhasil ditambahkan!'),
            ],
          ),
          backgroundColor: const Color(0xFF1E40AF),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Tugas' : 'Tambah Tugas Baru',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pesan Error Alert jika ada Exception / Validasi Gagal
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Input Judul Tugas
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Judul Tugas *',
                  hintText: 'Contoh: Laporan ATS Pemrograman Bergerak',
                  prefixIcon: const Icon(Icons.title_rounded, color: Color(0xFF2563EB)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                ),
                onChanged: (_) {
                  if (_errorMessage != null) setState(() => _errorMessage = null);
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Judul tugas wajib diisi!';
                  }
                  if (val.trim().length < 3) {
                    return 'Judul tugas minimal terdiri dari 3 karakter!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Pilihan Kategori Tugas
              const Text(
                'Kategori Tugas',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final cat in TaskCategory.values)
                    ChoiceChip(
                      avatar: Icon(cat.icon, size: 16),
                      label: Text(cat.label),
                      selected: _selectedCategory == cat,
                      selectedColor: const Color(0xFFDBEAFE),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Pilihan Prioritas
              const Text(
                'Tingkat Prioritas',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<TaskPriority>(
                segments: [
                  for (final p in TaskPriority.values)
                    ButtonSegment(
                      value: p,
                      label: Text(p.label),
                      icon: Icon(Icons.flag_rounded, color: p.color, size: 18),
                    ),
                ],
                selected: {_selectedPriority},
                onSelectionChanged: (set) {
                  setState(() => _selectedPriority = set.first);
                },
              ),
              const SizedBox(height: 16),

              // Pemilih Tanggal Tenggat (Deadline)
              const Text(
                'Tenggat Waktu (Deadline) *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDeadlineDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: Color(0xFF2563EB)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDeadline == null
                              ? 'Ketuk untuk memilih tanggal tenggat'
                              : formatTanggalLengkap(_selectedDeadline!),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _selectedDeadline == null
                                ? Colors.grey
                                : (isDark ? Colors.white : const Color(0xFF0F172A)),
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Color(0xFF2563EB)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Input Catatan / Detail Tugas
              TextFormField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Catatan / Instruksi Tambahan (Opsional)',
                  hintText: 'Tuliskan deskripsi detail atau catatan penting tugas di sini…',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 28),

              // Tombol Simpan
              FilledButton.icon(
                onPressed: _saveTask,
                icon: const Icon(Icons.save_rounded),
                label: Text(
                  _isEditing ? 'Perbarui Data Tugas' : 'Simpan Tugas Baru',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

