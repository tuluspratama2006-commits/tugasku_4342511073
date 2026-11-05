import 'dart:async';
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/task_model.dart';
import 'task_detail_screen.dart';

// Warna statis Royal Blue
const _kPrimary = Color(0xFF2563EB);
const _kAccent = Color(0xFFDBEAFE);

/// Halaman 3: Dashboard / Beranda Produktivitas Mahasiswa
/// Tampilan bersih, sederhana, menyenangkan, dan mudah dibaca sesuai prinsip IMK
class DashboardTab extends StatefulWidget {
  final void Function(int) onNavigateToTab;

  const DashboardTab({super.key, required this.onNavigateToTab});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  late DateTime _currentTime;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  /// Gradient header berdasarkan waktu (pagi / siang / sore / malam)
  List<Color> _headerGradient(DateTime dt) {
    final hour = dt.hour;
    if (hour >= 4 && hour < 11) {
      // Pagi — biru cerah
      return const [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF38BDF8)];
    } else if (hour >= 11 && hour < 15) {
      // Siang — biru laut terang
      return const [Color(0xFF0369A1), Color(0xFF0EA5E9), Color(0xFF38BDF8)];
    } else if (hour >= 15 && hour < 18) {
      // Sore — biru ungu
      return const [Color(0xFF1E3A8A), Color(0xFF4F46E5), Color(0xFF818CF8)];
    } else {
      // Malam — navy dalam
      return const [Color(0xFF0B1329), Color(0xFF1E3A8A), Color(0xFF2563EB)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchState;
    final isDark = state.isDarkMode;

    final total = state.totalTasksCount;
    final completed = state.completedTasksCount;
    final active = state.activeTasksCount;
    final overdue = state.overdueTasksCount;
    final percent = state.completionPercentage;

    final upcomingTasks = state.allTasks
        .where((t) => !t.isCompleted)
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return RefreshIndicator(
      color: _kPrimary,
      onRefresh: () async {
        setState(() => _currentTime = DateTime.now());
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // ================= 1. HEADER RINGKAS & MENARIK =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _headerGradient(_currentTime),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: _kPrimary.withAlpha(isDark ? 60 : 70),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Jam & Tanggal Digital
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatWaktuJam(_currentTime),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          formatTanggalLengkap(_currentTime),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFFF1F5F9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // Badge Icon Checklist
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withAlpha(70)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.checklist_rtl_rounded, size: 16, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'TugasKu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 12),

                // Sapaan Ramah Mahasiswa
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${sapaanBerdasarkanWaktu(_currentTime)}, ${state.userName}!',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.userBio,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ================= 2. RINGKASAN STATISTIK 4 KARTU BERSIH =================
          Row(
            children: [
              _SimpleStat(
                label: 'Total',
                count: '$total',
                icon: Icons.assignment_rounded,
                color: _kPrimary,
                isDark: isDark,
                onTap: () => widget.onNavigateToTab(1),
              ),
              const SizedBox(width: 8),
              _SimpleStat(
                label: 'Selesai',
                count: '$completed',
                icon: Icons.task_alt_rounded,
                color: const Color(0xFF10B981),
                isDark: isDark,
                onTap: () => widget.onNavigateToTab(1),
              ),
              const SizedBox(width: 8),
              _SimpleStat(
                label: 'Aktif',
                count: '$active',
                icon: Icons.hourglass_top_rounded,
                color: const Color(0xFFF59E0B),
                isDark: isDark,
                onTap: () => widget.onNavigateToTab(1),
              ),
              const SizedBox(width: 8),
              _SimpleStat(
                label: 'Terlambat',
                count: '$overdue',
                icon: Icons.alarm_on_rounded,
                color: const Color(0xFFEF4444),
                isDark: isDark,
                onTap: () => widget.onNavigateToTab(1),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ================= 3. PROGRES PENYELESAIAN TUGAS =================
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progres Belajar Hari Ini',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kPrimary.withAlpha(isDark ? 50 : 25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(percent * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _kPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0.0 : percent,
                      minHeight: 10,
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percent >= 0.7 ? const Color(0xFF10B981) : _kPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    total == 0
                        ? 'Belum ada tugas tercatat'
                        : '$completed dari $total tugas tuntas diselesaikan',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ================= 4. KARTU FOCUS TIMER RINGKAS & LANGSUNG AKTIF =================
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: state.isTimerRunning
                    ? _kPrimary
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                width: state.isTimerRunning ? 1.5 : 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (state.isTimerRunning ? const Color(0xFF10B981) : _kPrimary).withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  state.isTimerRunning ? Icons.hourglass_bottom_rounded : Icons.timer_rounded,
                  color: state.isTimerRunning ? const Color(0xFF10B981) : _kPrimary,
                  size: 22,
                ),
              ),
              title: Text(
                'Fokus: ${formatMenitDetik(state.timerSecondsRemaining)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                state.isTimerRunning
                    ? 'Timer sedang berjalan aktif…'
                    : 'Target ${state.focusDurationMinutes} menit • ${state.completedSessionsCount} sesi selesai',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: state.isTimerRunning ? const Color(0xFFF59E0B) : _kPrimary,
                    ),
                    icon: Icon(state.isTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 20),
                    tooltip: state.isTimerRunning ? 'Jeda' : 'Mulai',
                    onPressed: () => state.toggleTimer(),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onPressed: () => widget.onNavigateToTab(2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ================= 5. TAUTAN WEB CEPAT =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tautan Web Cepat',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => widget.onNavigateToTab(3),
                child: const Text('Kelola', style: TextStyle(fontSize: 12, color: _kPrimary)),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: state.quickLinks.map((link) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: Icon(link.icon, size: 16, color: _kPrimary),
                    label: Text(link.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    backgroundColor: isDark ? const Color(0xFF1E293B) : _kAccent.withAlpha(40),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF334155) : _kPrimary.withAlpha(50),
                    ),
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Membuka ${link.name}...'),
                          backgroundColor: _kPrimary,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      await launchExternalUrl(link.url);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // ================= 6. TUGAS TERDEKAT =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tugas Prioritas Terdekat',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => widget.onNavigateToTab(1),
                child: const Text('Lihat Semua', style: TextStyle(fontSize: 12, color: _kPrimary)),
              ),
            ],
          ),

          if (upcomingTasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(22),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFBBF7D0),
                ),
              ),
              child: const Column(
                children: [
                  Text('🎉', style: TextStyle(fontSize: 30)),
                  SizedBox(height: 6),
                  Text(
                    'Semua tugas telah diselesaikan!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            ...upcomingTasks.take(3).map((task) {
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  leading: Checkbox(
                    value: task.isCompleted,
                    activeColor: _kPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    onChanged: (_) => state.toggleTaskCompletion(task.id),
                  ),
                  title: Text(
                    task.title,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                      const SizedBox(width: 8),
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
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TaskDetailScreen(taskId: task.id),
                      ),
                    );
                  },
                ),
              );
            }),
          const SizedBox(height: 70),
        ],
      ),
    );
  }
}

class _SimpleStat extends StatelessWidget {
  final String label;
  final String count;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _SimpleStat({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              Text(
                count,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
