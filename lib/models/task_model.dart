import 'package:flutter/material.dart';

/// Prioritas tugas
enum TaskPriority { rendah, sedang, tinggi }

extension TaskPriorityX on TaskPriority {
  String get label => switch (this) {
        TaskPriority.rendah => 'Rendah',
        TaskPriority.sedang => 'Sedang',
        TaskPriority.tinggi => 'Tinggi',
      };

  Color get color => switch (this) {
        TaskPriority.rendah => const Color(0xFF10B981), // Emerald green
        TaskPriority.sedang => const Color(0xFFF59E0B), // Amber orange
        TaskPriority.tinggi => const Color(0xFFEF4444), // Crimson red
      };

  Color get backgroundColor => switch (this) {
        TaskPriority.rendah => const Color(0xFFE8F5E9),
        TaskPriority.sedang => const Color(0xFFFEF3C7),
        TaskPriority.tinggi => const Color(0xFFFEE2E2),
      };
}

/// Kategori tugas
enum TaskCategory { kuliah, praktikum, organisasi, pribadi }

extension TaskCategoryX on TaskCategory {
  String get label => switch (this) {
        TaskCategory.kuliah => 'Kuliah',
        TaskCategory.praktikum => 'Praktikum',
        TaskCategory.organisasi => 'Organisasi',
        TaskCategory.pribadi => 'Pribadi',
      };

  IconData get icon => switch (this) {
        TaskCategory.kuliah => Icons.school_outlined,
        TaskCategory.praktikum => Icons.code_rounded,
        TaskCategory.organisasi => Icons.groups_outlined,
        TaskCategory.pribadi => Icons.person_outline,
      };
}

/// Model data Tugas
class TaskItem {
  final String id;
  String title;
  String note;
  DateTime deadline;
  TaskPriority priority;
  TaskCategory category;
  bool isCompleted;
  DateTime createdAt;

  TaskItem({
    required this.id,
    required this.title,
    this.note = '',
    required this.deadline,
    this.priority = TaskPriority.sedang,
    this.category = TaskCategory.kuliah,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Hitung sisa hari menuju tenggat
  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(deadline.year, deadline.month, deadline.day);
    return target.difference(today).inDays;
  }

  /// Status tenggat (terlambat, hari ini, atau tersisa)
  String get deadlineStatus {
    final d = daysLeft;
    if (isCompleted) return 'Selesai';
    if (d < 0) return 'Terlambat ${-d} hari';
    if (d == 0) return 'Tenggat hari ini!';
    if (d == 1) return 'Besok';
    return '$d hari lagi';
  }

  Color get deadlineColor {
    if (isCompleted) return Colors.green;
    final d = daysLeft;
    if (d < 0) return Colors.red;
    if (d == 0) return Colors.orange;
    return const Color(0xFF2563EB); // Royal Blue
  }
}

/// Model data Tautan Cepat (Quick Links)
class QuickLinkItem {
  final String id;
  String name;
  String url;
  IconData icon;

  QuickLinkItem({
    required this.id,
    required this.name,
    required this.url,
    this.icon = Icons.link_rounded,
  });
}

// ================= HELPER FORMAT WAKTU (TANPA INTL) =================
const List<String> _namaHari = [
  'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
];

const List<String> _namaBulan = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
];

String formatTanggalLengkap(DateTime dt) {
  final hari = _namaHari[dt.weekday - 1];
  final tgl = dt.day;
  final bln = _namaBulan[dt.month - 1];
  final thn = dt.year;
  return '$hari, $tgl $bln $thn';
}

String formatTanggalPendek(DateTime dt) {
  final tgl = dt.day.toString().padLeft(2, '0');
  final bln = _namaBulan[dt.month - 1].substring(0, 3);
  final thn = dt.year;
  return '$tgl $bln $thn';
}

String formatWaktuJam(DateTime dt) {
  final jam = dt.hour.toString().padLeft(2, '0');
  final menit = dt.minute.toString().padLeft(2, '0');
  final detik = dt.second.toString().padLeft(2, '0');
  return '$jam:$menit:$detik';
}

String formatMenitDetik(int totalDetik) {
  final m = (totalDetik ~/ 60).toString().padLeft(2, '0');
  final s = (totalDetik % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

String sapaanBerdasarkanWaktu(DateTime dt) {
  final hour = dt.hour;
  if (hour >= 4 && hour < 11) return 'Selamat Pagi';
  if (hour >= 11 && hour < 15) return 'Selamat Siang';
  if (hour >= 15 && hour < 18) return 'Selamat Sore';
  return 'Selamat Malam';
}
