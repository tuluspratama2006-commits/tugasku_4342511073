import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/task_model.dart';
import 'task_form_screen.dart';
import 'task_detail_screen.dart';

/// Halaman 4: Manajemen Tugas (CRUD, Search Real-time, Filter & Sort Dinamis)
class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context, TaskItem task) {
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
        content: Text('Apakah Anda yakin ingin menghapus tugas "${task.title}"? Data ini tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              final deleted = context.readState.deleteTask(task.id);
              if (deleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tugas "${task.title}" berhasil dihapus'),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
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
    final tasks = state.filteredTasks;

    return Column(
      children: [
        // ================= SEARCH BAR & SORT BUTTON =================
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => state.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Cari tugas atau catatan…',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2563EB)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              state.setSearchQuery('');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFDBFE)),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Menu Pengurutan Dinamis
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFBFDBFE),
                  ),
                ),
                child: PopupMenuButton<TaskSortOption>(
                  tooltip: 'Urutkan Tugas',
                  icon: const Icon(Icons.sort_rounded, color: Color(0xFF2563EB)),
                  initialValue: state.sortOption,
                  onSelected: (option) => state.setSortOption(option),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: TaskSortOption.tenggat,
                      child: Row(
                        children: [
                          Icon(Icons.event_rounded, size: 18, color: Color(0xFF2563EB)),
                          SizedBox(width: 8),
                          Text('Urutkan: Tenggat Waktu'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: TaskSortOption.prioritas,
                      child: Row(
                        children: [
                          Icon(Icons.flag_rounded, size: 18, color: Color(0xFFEF4444)),
                          SizedBox(width: 8),
                          Text('Urutkan: Prioritas Tertinggi'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: TaskSortOption.judul,
                      child: Row(
                        children: [
                          Icon(Icons.sort_by_alpha_rounded, size: 18, color: Color(0xFF10B981)),
                          SizedBox(width: 8),
                          Text('Urutkan: Judul (A-Z)'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ================= FILTER STATUS CHIPS =================
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              for (final filter in TaskStatusFilter.values) ...[
                ChoiceChip(
                  label: Text(
                    filter.name[0].toUpperCase() + filter.name.substring(1),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: state.statusFilter == filter ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: state.statusFilter == filter,
                  selectedColor: const Color(0xFFDBEAFE),
                  side: BorderSide(
                    color: state.statusFilter == filter
                        ? const Color(0xFF2563EB)
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                  ),
                  onSelected: (_) => state.setStatusFilter(filter),
                ),
                const SizedBox(width: 6),
              ],
              const VerticalDivider(width: 12, thickness: 1),
              // Filter Kategori
              FilterChip(
                label: Text(
                  state.categoryFilter == null ? 'Semua Kategori' : state.categoryFilter!.label,
                  style: const TextStyle(fontSize: 12),
                ),
                selected: state.categoryFilter != null,
                selectedColor: const Color(0xFFE0E7FF),
                onSelected: (_) {
                  _showCategoryFilterDialog(context, state);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // ================= LISTVIEW DAFTAR TUGAS =================
        Expanded(
          child: tasks.isEmpty
              ? Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Tidak ada tugas yang cocok',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Coba ganti kata kunci pencarian atau ubah opsi filter.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: task.isCompleted
                              ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                              : const Color(0xFF93C5FD).withOpacity(0.5),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TaskDetailScreen(taskId: task.id),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Checkbox Selesai
                                  Checkbox(
                                    value: task.isCompleted,
                                    activeColor: const Color(0xFF2563EB),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                    onChanged: (_) => state.toggleTaskCompletion(task.id),
                                  ),
                                  // Judul & Catatan
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                            color: task.isCompleted
                                                ? (isDark ? Colors.grey[500] : Colors.grey[500])
                                                : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                          ),
                                        ),
                                        if (task.note.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            task.note,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Menu Aksi Cepat (Edit / Hapus)
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                                    onSelected: (val) {
                                      if (val == 'edit') {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => TaskFormScreen(taskId: task.id),
                                          ),
                                        );
                                      } else if (val == 'delete') {
                                        _showDeleteConfirmation(context, task);
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_outlined, size: 18),
                                            SizedBox(width: 8),
                                            Text('Edit Tugas'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Hapus Tugas', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 12),
                              // Baris Kategori, Prioritas, & Deadline
                              Row(
                                children: [
                                  // Kategori Chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2563EB).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(task.category.icon, size: 12, color: const Color(0xFF2563EB)),
                                        const SizedBox(width: 4),
                                        Text(
                                          task.category.label,
                                          style: const TextStyle(fontSize: 10, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Prioritas Chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: task.priority.backgroundColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      task.priority.label,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: task.priority.color,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  // Status Tenggat
                                  Icon(Icons.event_note_rounded, size: 14, color: task.deadlineColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.deadlineStatus,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: task.deadlineColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showCategoryFilterDialog(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Kategori Tugas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 24),
              ListTile(
                leading: Icon(Icons.all_inclusive_rounded, color: Color(0xFF2563EB)),
                title: const Text('Semua Kategori'),
                trailing: state.categoryFilter == null ? Icon(Icons.check, color: Color(0xFF2563EB)) : null,
                onTap: () {
                  state.setCategoryFilter(null);
                  Navigator.pop(ctx);
                },
              ),
              for (final cat in TaskCategory.values)
                ListTile(
                  leading: Icon(cat.icon, color: const Color(0xFF2563EB)),
                  title: Text(cat.label),
                  trailing: state.categoryFilter == cat ? Icon(Icons.check, color: Color(0xFF2563EB)) : null,
                  onTap: () {
                    state.setCategoryFilter(cat);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
