import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/task_model.dart';

// Warna statis Royal Blue
const _kPrimary = Color(0xFF2563EB);

/// Halaman 7: Pomodoro Focus Timer Super Dinamis (Fitur Dinamis 2)
/// Waktu bebas diatur sesuka pengguna, tidak terpatok pada menit tertentu
class FocusTab extends StatelessWidget {
  const FocusTab({super.key});

  void _showCustomDurationDialog(BuildContext context, AppState state) {
    final textCtrl = TextEditingController(text: '${state.focusDurationMinutes}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.tune_rounded, color: _kPrimary),
            SizedBox(width: 8),
            Text('Atur Durasi Bebas'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan durasi fokus yang Anda inginkan (dalam menit, bebas dari 1 s/d 180 menit):',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: textCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Durasi (Menit)',
                hintText: 'Contoh: 7, 20, 35, 75',
                suffixText: 'Menit',
                prefixIcon: Icon(Icons.timer_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _kPrimary),
            onPressed: () {
              final val = int.tryParse(textCtrl.text.trim());
              if (val != null && val >= 1 && val <= 180) {
                state.setFocusDurationMinutes(val);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Durasi fokus berhasil diatur menjadi $val menit! ⏱️'),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Harap masukkan angka menit antara 1 sampai 180!'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchState;
    final isDark = state.isDarkMode;

    // Notifikasi saat sesi selesai
    if (state.sessionJustCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state.acknowledgeCompletedSession();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            title: const Row(
              children: [
                Icon(Icons.celebration_rounded, color: Color(0xFFF59E0B), size: 28),
                SizedBox(width: 8),
                Text('Sesi Fokus Selesai! 🎉'),
              ],
            ),
            content: const Text(
              'Kerja luar biasa! Anda telah menuntaskan 1 sesi fokus belajar. Luangkan waktu sejenak untuk istirahat sebelum memulai sesi berikutnya.',
            ),
            actions: [
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _kPrimary),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Siap, Terima Kasih!'),
              ),
            ],
          ),
        );
      });
    }

    final progress = state.timerProgress;
    final isRunning = state.isTimerRunning;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Judul & Status Sesi
              Text(
                isRunning ? 'Sesi Fokus Sedang Berjalan 🔥' : 'Ruang Fokus Belajar 🎯',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                isRunning
                    ? 'Konsentrasi penuh pada materi dan tugasmu sekarang.'
                    : 'Atur durasi sesuka hatimu lalu mulai saat kamu siap.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),

              // ================= CIRCULAR PROGRESS TIMER DISPLAY =================
              SizedBox(
                width: 230,
                height: 230,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Ring
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 14,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    // Animated Running Ring
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 14,
                        strokeCap: StrokeCap.round,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isRunning ? _kPrimary : const Color(0xFF60A5FA),
                        ),
                      ),
                    ),
                    // Tampilan Waktu (Menit : Detik)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatMenitDetik(state.timerSecondsRemaining),
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isRunning
                                ? const Color(0xFF10B981).withAlpha(35)
                                : _kPrimary.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isRunning ? '• FOKUS AKTIF •' : 'SIAP DIMULAI',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isRunning ? const Color(0xFF10B981) : _kPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // ================= TOMBOL CEPAT TAMBAH / KURANG WAKTU =================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => state.subtractMinutes(5),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: const Size(40, 32),
                    ),
                    child: const Text('-5m'),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton(
                    onPressed: () => state.subtractMinutes(1),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: const Size(40, 32),
                    ),
                    child: const Text('-1m'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: () => _showCustomDurationDialog(context, state),
                    icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                    label: Text('${state.focusDurationMinutes}m', style: const TextStyle(fontWeight: FontWeight.bold)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => state.addMinutes(1),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: const Size(40, 32),
                    ),
                    child: const Text('+1m'),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton(
                    onPressed: () => state.addMinutes(5),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: const Size(40, 32),
                    ),
                    child: const Text('+5m'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ================= TOMBOL UTAMA KONTROL TIMER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tombol Mulai
                  FilledButton.icon(
                    onPressed: isRunning ? null : () => state.startFocusTimer(),
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: const Text('Mulai', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    style: FilledButton.styleFrom(
                      backgroundColor: _kPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Tombol Jeda
                  FilledButton.tonalIcon(
                    onPressed: isRunning ? () => state.pauseFocusTimer() : null,
                    icon: const Icon(Icons.pause_rounded, size: 22),
                    label: const Text('Jeda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Tombol Reset
                  OutlinedButton.icon(
                    onPressed: () => state.resetFocusTimer(),
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ================= SLIDER KONTINU & PRESET POPULER =================
              Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.linear_scale_rounded, size: 18, color: _kPrimary),
                              SizedBox(width: 6),
                              Text('Geser Durasi Waktu:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => _showCustomDurationDialog(context, state),
                            icon: const Icon(Icons.edit_note_rounded, size: 16),
                            label: const Text('Ketik Bebas', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      Slider(
                        value: state.focusDurationMinutes.toDouble().clamp(1.0, 180.0),
                        min: 1,
                        max: 180,
                        activeColor: _kPrimary,
                        label: '${state.focusDurationMinutes} menit',
                        onChanged: (val) => state.setFocusDurationMinutes(val.round()),
                      ),
                      // Preset Pilihan Populer
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: [5, 15, 25, 45, 60, 90, 120, 180].map((mins) {
                          final isSelected = state.focusDurationMinutes == mins;
                          return ChoiceChip(
                            label: Text('$mins m', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            selected: isSelected,
                            selectedColor: _kPrimary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : null,
                            ),
                            onSelected: (_) => state.setFocusDurationMinutes(mins),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ================= COUNTER PENCAPAIAN SESI =================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withAlpha(isDark ? 40 : 25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF59E0B).withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: Color(0xFFD97706), size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Akumulasi Sesi Fokus',
                            style: TextStyle(fontSize: 11, color: Color(0xFFB45309), fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${state.completedSessionsCount} Sesi Fokus Berhasil Dituntaskan! 🏆',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
