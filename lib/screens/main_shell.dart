import 'package:flutter/material.dart';
import '../state/app_state.dart';
import 'dashboard_tab.dart';
import 'tasks_tab.dart';
import 'focus_tab.dart';
import 'profile_tab.dart';
import 'task_form_screen.dart';
import 'login_screen.dart';

/// Kerangka Shell Navigasi Utama Aplikasi TugasKu.
/// Menggunakan IndexedStack sehingga seluruh state tab, scroll, dan input
/// tetap terjaga (tidak hilang) saat berpindah tab maupun saat rotasi layar.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchState;
    final isDark = state.isDarkMode;

    const titles = [
      'Dashboard TugasKu',
      'Manajemen Tugas',
      'Pomodoro Fokus',
      'Profil & Pengaturan',
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.checklist_rtl_rounded, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              titles[_currentIndex],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Toggle Dark/Light Mode
          IconButton(
            tooltip: state.isDarkMode ? 'Beralih ke Mode Terang' : 'Beralih ke Mode Gelap',
            icon: Icon(
              state.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Colors.white,
            ),
            onPressed: state.toggleTheme,
          ),
          // Logout Button
          IconButton(
            tooltip: 'Keluar Aplikasi',
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Konfirmasi Keluar'),
                    ],
                  ),
                  content: const Text('Apakah Anda yakin ingin keluar dari akun TugasKu?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        Navigator.pop(ctx);
                        state.logout();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardTab(onNavigateToTab: _switchTab),
          const TasksTab(),
          const FocusTab(),
          const ProfileTab(),
        ],
      ),
      // Floating Action Button khusus untuk Tambah Tugas
      floatingActionButton: _currentIndex == 1 || _currentIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_task_rounded),
              label: const Text('Tugas Baru', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TaskFormScreen()),
                );
              },
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _switchTab,
          indicatorColor: const Color(0xFFDBEAFE),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF1E40AF)),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.format_list_bulleted_rounded),
              selectedIcon: Icon(Icons.checklist_rounded, color: Color(0xFF1E40AF)),
              label: 'Tugas',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer_rounded, color: Color(0xFF1E40AF)),
              label: 'Fokus',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF1E40AF)),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
