import 'dart:async';
import 'dart:io' show Platform, Process;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/task_model.dart';

enum TaskStatusFilter { semua, aktif, selesai }
enum TaskSortOption { tenggat, prioritas, judul }

/// Helper universal untuk membuka URL langsung ke peramban (browser) pengguna
Future<bool> launchExternalUrl(String rawUrl) async {
  var url = rawUrl.trim();
  if (url.isEmpty) return false;
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'https://$url';
  }

  try {
    if (!kIsWeb) {
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', url]);
        return true;
      } else if (Platform.isMacOS) {
        await Process.run('open', [url]);
        return true;
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [url]);
        return true;
      }
    }
  } catch (e) {
    debugPrint('Gagal membuka tautan secara langsung: $e');
  }
  return false;
}

/// State Management Utama Aplikasi TugasKu (ChangeNotifier).
/// Mengelola seluruh state data agar persisten dan tidak hilang
/// saat terjadi pergantian halaman maupun rotasi layar (lifecycle-safe).
class AppState extends ChangeNotifier {
  // ================= 1. AUTHENTICATION & PROFIL MAHASISWA =================
  static const String defaultEmail = 'tulus.pratama@polibatam.ac.id';
  static const String defaultPassword = '123456';

  bool _isLoggedIn = false;
  String _userName = 'Tulus Pratama';
  String _userNim = '4342511073';
  String _userKelas = 'TRPL 3A';
  String _userEmail = defaultEmail;
  String _userBio = 'Fokus belajar, konsisten menuntaskan tugas, dan terus bertumbuh!';
  Color _avatarColor = const Color(0xFF2563EB); // Royal Blue
  String _userAvatarUrl = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userNim => _userNim;
  String get userKelas => _userKelas;
  String get userEmail => _userEmail;
  String get userBio => _userBio;
  Color get avatarColor => _avatarColor;
  String get userAvatarUrl => _userAvatarUrl;

  /// Fitur Edit Profil Mahasiswa Dinamis (Mendukung Foto Profil & Warna Avatar)
  String? updateProfile({
    required String name,
    required String nim,
    required String kelas,
    required String email,
    required String bio,
    String? avatarUrl,
    Color? avatarColor,
  }) {
    final cleanName = name.trim();
    final cleanNim = nim.trim();
    final cleanKelas = kelas.trim();
    final cleanEmail = email.trim();

    if (cleanName.isEmpty) return 'Nama mahasiswa tidak boleh kosong!';
    if (cleanNim.isEmpty) return 'NIM tidak boleh kosong!';
    if (cleanKelas.isEmpty) return 'Kelas tidak boleh kosong!';
    if (cleanEmail.isEmpty) return 'Email tidak boleh kosong!';

    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      return 'Format email tidak valid!';
    }

    _userName = cleanName;
    _userNim = cleanNim;
    _userKelas = cleanKelas;
    _userEmail = cleanEmail;
    _userBio = bio.trim().isEmpty ? 'Mahasiswa TRPL Politeknik Negeri Batam' : bio.trim();
    if (avatarUrl != null) _userAvatarUrl = avatarUrl.trim();
    if (avatarColor != null) _avatarColor = avatarColor;

    notifyListeners();
    return null;
  }

  /// Validasi dan penanganan login dengan Exception Handling
  String? login({
    required String name,
    required String email,
    required String password,
  }) {
    final cleanName = name.trim();
    final cleanEmail = email.trim();

    if (cleanName.isEmpty) return 'Nama pengguna tidak boleh kosong!';
    if (cleanEmail.isEmpty) return 'Alamat email tidak boleh kosong!';
    if (password.isEmpty) return 'Kata sandi tidak boleh kosong!';

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(cleanEmail)) {
      return 'Format email tidak valid (contoh: user@domain.com)';
    }

    if (password.length < 6) {
      return 'Kata sandi minimal terdiri dari 6 karakter';
    }

    _userName = cleanName;
    _userEmail = cleanEmail;
    _isLoggedIn = true;
    notifyListeners();
    return null;
  }

  void logout() {
    pauseFocusTimer();
    _isLoggedIn = false;
    notifyListeners();
  }

  // ================= 2. MODE GELAP / TERANG IMK =================
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // ================= 3. FITUR DINAMIS 1: MANAJEMEN TUGAS =================
  static DateTime _relativeDate(int daysFromNow) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(Duration(days: daysFromNow));
  }

  final List<TaskItem> _tasks = [
    TaskItem(
      id: 't-101',
      title: 'Laporan ATS Pemrograman Bergerak',
      category: TaskCategory.praktikum,
      note: 'Menyusun laporan langkah pengerjaan ATS, link video vlog, dan tautan GitHub.',
      deadline: _relativeDate(1),
      priority: TaskPriority.tinggi,
      isCompleted: false,
    ),
    TaskItem(
      id: 't-102',
      title: 'Desain Wireframe UI/UX Mobile App',
      category: TaskCategory.kuliah,
      note: 'Merancang layout antarmuka aplikasi dengan palet biru modern di Figma.',
      deadline: _relativeDate(3),
      priority: TaskPriority.sedang,
      isCompleted: false,
    ),
    TaskItem(
      id: 't-103',
      title: 'Persiapan Rapat Himpunan Mahasiswa',
      category: TaskCategory.organisasi,
      note: 'Koordinasi materi kepanitiaan dan timeline program kerja jurusan.',
      deadline: _relativeDate(4),
      priority: TaskPriority.rendah,
      isCompleted: false,
    ),
    TaskItem(
      id: 't-104',
      title: 'Implementasi State Management Flutter',
      category: TaskCategory.praktikum,
      note: 'Menguji ketahanan state saat terjadi perubahan orientasi layar (screen rotation).',
      deadline: _relativeDate(-1),
      priority: TaskPriority.tinggi,
      isCompleted: false,
    ),
    TaskItem(
      id: 't-105',
      title: 'Setup Environment Flutter & Android Studio',
      category: TaskCategory.kuliah,
      note: 'Instalasi SDK Flutter, Dart, dan konfigurasi emulator Android.',
      deadline: _relativeDate(-3),
      priority: TaskPriority.sedang,
      isCompleted: true,
    ),
  ];

  int _taskSequence = 200;

  String _searchQuery = '';
  TaskStatusFilter _statusFilter = TaskStatusFilter.semua;
  TaskCategory? _categoryFilter;
  TaskSortOption _sortOption = TaskSortOption.tenggat;

  List<TaskItem> get allTasks => List.unmodifiable(_tasks);
  String get searchQuery => _searchQuery;
  TaskStatusFilter get statusFilter => _statusFilter;
  TaskCategory? get categoryFilter => _categoryFilter;
  TaskSortOption get sortOption => _sortOption;

  List<TaskItem> get filteredTasks {
    final query = _searchQuery.trim().toLowerCase();

    final result = _tasks.where((task) {
      final matchQuery = query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.note.toLowerCase().contains(query);

      final matchStatus = switch (_statusFilter) {
        TaskStatusFilter.semua => true,
        TaskStatusFilter.aktif => !task.isCompleted,
        TaskStatusFilter.selesai => task.isCompleted,
      };

      final matchCategory = _categoryFilter == null || task.category == _categoryFilter;

      return matchQuery && matchStatus && matchCategory;
    }).toList();

    result.sort((a, b) {
      switch (_sortOption) {
        case TaskSortOption.tenggat:
          return a.deadline.compareTo(b.deadline);
        case TaskSortOption.prioritas:
          return b.priority.index.compareTo(a.priority.index);
        case TaskSortOption.judul:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });

    return result;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(TaskStatusFilter filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setCategoryFilter(TaskCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setSortOption(TaskSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  TaskItem? getTaskById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  String? _validateTaskInput(String title, DateTime? deadline, {String? excludeTaskId}) {
    final clean = title.trim();
    if (clean.isEmpty) return 'Judul tugas wajib diisi!';
    if (clean.length < 3) return 'Judul tugas minimal terdiri dari 3 karakter';
    if (clean.length > 80) return 'Judul tugas maksimal 80 karakter';
    if (deadline == null) return 'Tanggal tenggat wajib dipilih!';

    final duplicate = _tasks.any(
      (t) => t.id != excludeTaskId && t.title.trim().toLowerCase() == clean.toLowerCase(),
    );
    if (duplicate) return 'Tugas dengan judul ini sudah ada di daftar!';

    return null;
  }

  String? addTask({
    required String title,
    String note = '',
    required DateTime deadline,
    TaskPriority priority = TaskPriority.sedang,
    TaskCategory category = TaskCategory.kuliah,
  }) {
    final error = _validateTaskInput(title, deadline);
    if (error != null) return error;

    final newTask = TaskItem(
      id: 'task-${_taskSequence++}',
      title: title.trim(),
      note: note.trim(),
      deadline: deadline,
      priority: priority,
      category: category,
      isCompleted: false,
    );

    _tasks.add(newTask);
    notifyListeners();
    return null;
  }

  String? updateTask({
    required String id,
    required String title,
    String note = '',
    required DateTime deadline,
    required TaskPriority priority,
    required TaskCategory category,
  }) {
    final task = getTaskById(id);
    if (task == null) return 'Data tugas tidak ditemukan!';

    final error = _validateTaskInput(title, deadline, excludeTaskId: id);
    if (error != null) return error;

    task.title = title.trim();
    task.note = note.trim();
    task.deadline = deadline;
    task.priority = priority;
    task.category = category;

    notifyListeners();
    return null;
  }

  void toggleTaskCompletion(String id) {
    final task = getTaskById(id);
    if (task == null) return;
    task.isCompleted = !task.isCompleted;
    notifyListeners();
  }

  bool deleteTask(String id) {
    final initialLength = _tasks.length;
    _tasks.removeWhere((t) => t.id == id);
    final isRemoved = _tasks.length < initialLength;
    if (isRemoved) notifyListeners();
    return isRemoved;
  }

  // ================= 4. FITUR DINAMIS 2: SUPER DYNAMIC FOCUS TIMER =================
  int _focusDurationMinutes = 25;
  int _timerSecondsRemaining = 25 * 60;
  bool _isTimerRunning = false;
  int _completedSessionsCount = 0;
  bool _sessionJustCompleted = false;
  Timer? _periodicTimer;

  int get focusDurationMinutes => _focusDurationMinutes;
  int get timerSecondsRemaining => _timerSecondsRemaining;
  bool get isTimerRunning => _isTimerRunning;
  int get completedSessionsCount => _completedSessionsCount;
  bool get sessionJustCompleted => _sessionJustCompleted;

  double get timerProgress {
    final total = _focusDurationMinutes * 60;
    if (total <= 0) return 0.0;
    return 1.0 - (_timerSecondsRemaining / total);
  }

  /// Mengatur durasi bebas sesuka pengguna (1 hingga 180 menit)
  void setFocusDurationMinutes(int minutes) {
    final target = minutes.clamp(1, 180);
    _focusDurationMinutes = target;
    if (!_isTimerRunning) {
      _timerSecondsRemaining = target * 60;
    }
    notifyListeners();
  }

  /// Tambah menit secara dinamis (+1, +5, +10 menit)
  void addMinutes(int minutes) {
    final target = (_focusDurationMinutes + minutes).clamp(1, 180);
    _focusDurationMinutes = target;
    _timerSecondsRemaining = (_timerSecondsRemaining + (minutes * 60)).clamp(0, 180 * 60);
    notifyListeners();
  }

  /// Kurang menit secara dinamis
  void subtractMinutes(int minutes) {
    if (_focusDurationMinutes - minutes < 1) return;
    _focusDurationMinutes -= minutes;
    _timerSecondsRemaining = (_timerSecondsRemaining - (minutes * 60)).clamp(0, 180 * 60);
    if (_timerSecondsRemaining <= 0) {
      _timerSecondsRemaining = 60;
    }
    notifyListeners();
  }

  void startFocusTimer() {
    if (_isTimerRunning) return;
    if (_timerSecondsRemaining <= 0) {
      _timerSecondsRemaining = _focusDurationMinutes * 60;
    }
    _isTimerRunning = true;
    _periodicTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSecondsRemaining > 0) {
        _timerSecondsRemaining--;
      } else {
        _stopPeriodicTimer();
        _completedSessionsCount++;
        _sessionJustCompleted = true;
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void pauseFocusTimer() {
    _stopPeriodicTimer();
    notifyListeners();
  }

  void toggleTimer() {
    if (_isTimerRunning) {
      pauseFocusTimer();
    } else {
      startFocusTimer();
    }
  }

  void resetFocusTimer() {
    _stopPeriodicTimer();
    _timerSecondsRemaining = _focusDurationMinutes * 60;
    notifyListeners();
  }

  void acknowledgeCompletedSession() {
    _sessionJustCompleted = false;
  }

  void _stopPeriodicTimer() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    _isTimerRunning = false;
  }

  // ================= 5. FITUR DINAMIS 3: QUICK LINKS & STATISTIK =================
  final List<QuickLinkItem> _quickLinks = [
    QuickLinkItem(id: 'ql-1', name: 'E-Learning Polibatam', url: 'https://learning.polibatam.ac.id', icon: Icons.school_rounded),
    QuickLinkItem(id: 'ql-2', name: 'SIAKAD Polibatam', url: 'https://siakad.polibatam.ac.id', icon: Icons.badge_rounded),
    QuickLinkItem(id: 'ql-3', name: 'GitHub Mahasiswa', url: 'https://github.com', icon: Icons.code_rounded),
    QuickLinkItem(id: 'ql-4', name: 'Google Classroom', url: 'https://classroom.google.com', icon: Icons.co_present_rounded),
  ];

  int _quickLinkSequence = 20;
  List<QuickLinkItem> get quickLinks => List.unmodifiable(_quickLinks);

  String? addQuickLink({required String name, required String url}) {
    final cleanName = name.trim();
    var cleanUrl = url.trim();

    if (cleanName.isEmpty) return 'Nama tautan tidak boleh kosong!';
    if (cleanUrl.isEmpty) return 'URL tautan tidak boleh kosong!';

    if (!RegExp(r'^https?://', caseSensitive: false).hasMatch(cleanUrl)) {
      cleanUrl = 'https://$cleanUrl';
    }

    final uri = Uri.tryParse(cleanUrl);
    if (uri == null || uri.host.isEmpty || !uri.host.contains('.')) {
      return 'Format URL tidak valid (contoh: learning.polibatam.ac.id)';
    }

    if (_quickLinks.any((l) => l.url.toLowerCase() == cleanUrl.toLowerCase())) {
      return 'Tautan dengan URL ini sudah tersedia di daftar!';
    }

    _quickLinks.add(QuickLinkItem(
      id: 'ql-${_quickLinkSequence++}',
      name: cleanName,
      url: cleanUrl,
      icon: Icons.open_in_new_rounded,
    ));
    notifyListeners();
    return null;
  }

  bool removeQuickLink(String id) {
    final initial = _quickLinks.length;
    _quickLinks.removeWhere((l) => l.id == id);
    final removed = _quickLinks.length < initial;
    if (removed) notifyListeners();
    return removed;
  }

  // ================= STATISTIK DINAMIS PRODUKTIVITAS =================
  int get totalTasksCount => _tasks.length;
  int get completedTasksCount => _tasks.where((t) => t.isCompleted).length;
  int get activeTasksCount => _tasks.where((t) => !t.isCompleted).length;
  int get overdueTasksCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _tasks.where((t) => !t.isCompleted && t.deadline.isBefore(today)).length;
  }

  double get completionPercentage {
    if (_tasks.isEmpty) return 0.0;
    return completedTasksCount / _tasks.length;
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    super.dispose();
  }
}

// ================= INHERITED NOTIFIER SCOPE (BUILT-IN FLUTTER) =================
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope tidak ditemukan di Widget Tree');
    return scope!.notifier!;
  }

  static AppState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope tidak ditemukan di Widget Tree');
    return scope!.notifier!;
  }
}

extension AppStateBuildContext on BuildContext {
  AppState get watchState => AppStateScope.of(this);
  AppState get readState => AppStateScope.read(this);
}
