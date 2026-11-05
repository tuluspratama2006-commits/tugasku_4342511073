import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/task_model.dart';
import 'task_form_screen.dart';

/// Halaman 6: Detail Item Tugas Lengkap dengan Status, Countdown Tenggat & Aksi
class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  void _showDeleteDialog(BuildContext context, TaskItem task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Hapus Tugas?'),
          ],
        ),
        content: Text('Apakah Anda yakin ingin menghapus "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.readState.deleteTask(task.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tugas "${task.title}" telah dihapus'),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context); // Kembali ke halaman sebelumnya
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchState;
    final isDark = state.isDarkMode;
    final task = state.getTaskById(taskId);

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tugas')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 54, color: Colors.red),
              const SizedBox(height: 12),
              const Text('Data tugas tidak ditemukan atau telah dihapus.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Edit Tugas',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TaskFormScreen(taskId: task.id),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Hapus Tugas',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _showDeleteDialog(context, task),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= STATUS HERO CARD =================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
                    : (isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFEFF6FF)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: task.isCompleted ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    task.isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded,
                    size: 32,
                    color: task.isCompleted ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.isCompleted ? 'Status: Selesai Dikerjakan' : 'Status: Menunggu Penyelesaian',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: task.isCompleted ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                          ),
                        ),
                        Text(
                          task.isCompleted
                              ? 'Tugas ini telah ditandai tuntas'
                              : 'Segera selesaikan sebelum batas tenggat waktu',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Judul Tugas
            Text(
              task.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 12),

            // Badges Bar
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Kategori
                Chip(
                  avatar: Icon(task.category.icon, size: 16, color: const Color(0xFF2563EB)),
                  label: Text(task.category.label),
                  backgroundColor: const Color(0xFFDBEAFE),
                  side: BorderSide.none,
                ),
                // Prioritas
                Chip(
                  avatar: Icon(Icons.flag_rounded, size: 16, color: task.priority.color),
                  label: Text('Prioritas ${task.priority.label}'),
                  backgroundColor: task.priority.backgroundColor,
                  side: BorderSide.none,
                ),
                // Sisa Tenggat
                Chip(
                  avatar: Icon(Icons.access_time_rounded, size: 16, color: task.deadlineColor),
                  label: Text(task.deadlineStatus),
                  backgroundColor: const Color(0xFFF1F5F9),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Informasi Waktu Tenggat
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 20, color: Color(0xFF2563EB)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Batas Akhir (Deadline)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text(
                              formatTanggalLengkap(task.deadline),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.history_rounded, size: 20, color: Colors.grey),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Dibuat pada', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text(
                              formatTanggalLengkap(task.createdAt),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Deskripsi / Catatan Tugas
            const Text(
              'Catatan & Keterangan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                task.note.isEmpty ? 'Tidak ada catatan atau instruksi tambahan untuk tugas ini.' : task.note,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: task.note.isEmpty ? Colors.grey : null,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Toggle Selesai
            FilledButton.icon(
              onPressed: () {
                state.toggleTaskCompletion(task.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      task.isCompleted
                          ? 'Tugas "${task.title}" ditandai selesai! 🎉'
                          : 'Tugas "${task.title}" ditandai belum selesai.',
                    ),
                    backgroundColor: task.isCompleted ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: Icon(task.isCompleted ? Icons.undo_rounded : Icons.check_circle_outline_rounded),
              label: Text(
                task.isCompleted ? 'Tandai Belum Selesai' : 'Tandai Selesai Sekarang',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: task.isCompleted ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),

            // Tombol Edit
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => TaskFormScreen(taskId: task.id)),
                );
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Informasi Tugas'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF2563EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

