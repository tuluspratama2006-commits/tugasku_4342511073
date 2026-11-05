import 'package:flutter/material.dart';
import '../state/app_state.dart';
import 'login_screen.dart';

// Warna statis Royal Blue
const _kPrimary = Color(0xFF2563EB);
const _kAccent = Color(0xFFDBEAFE);

/// Halaman 8: Profil Mahasiswa, Foto Profil, Edit Profil,
/// Tautan Cepat Langsung ke Browser, dan Toggle Mode Gelap/Terang
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _linkNameController = TextEditingController();
  final _linkUrlController = TextEditingController();
  String? _linkError;

  @override
  void dispose() {
    _linkNameController.dispose();
    _linkUrlController.dispose();
    super.dispose();
  }

  // ================= 1. DIALOG EDIT PROFIL DENGAN FOTO PROFIL =================
  void _showEditProfileDialog(BuildContext context, AppState state) {
    final nameCtrl = TextEditingController(text: state.userName);
    final nimCtrl = TextEditingController(text: state.userNim);
    final kelasCtrl = TextEditingController(text: state.userKelas);
    final emailCtrl = TextEditingController(text: state.userEmail);
    final bioCtrl = TextEditingController(text: state.userBio);
    final photoUrlCtrl = TextEditingController(text: state.userAvatarUrl);
    Color selectedColor = state.avatarColor;
    String? validationError;

    // Foto avatar preset jika pengguna ingin memilih langsung
    final samplePhotos = [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    ];

    final avatarColors = [
      const Color(0xFF2563EB), // Royal Blue
      const Color(0xFF8B5CF6), // Ungu
      const Color(0xFFEC4899), // Pink
      const Color(0xFFF97316), // Oren
      const Color(0xFF10B981), // Hijau
      const Color(0xFF06B6D4), // Teal
      const Color(0xFFEF4444), // Merah
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.badge_rounded, color: _kPrimary, size: 26),
                          SizedBox(width: 8),
                          Text(
                            'Edit Profil Mahasiswa',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  if (validationError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.withAlpha(80)),
                      ),
                      child: Text(
                        validationError!,
                        style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Pilihan Foto Profil Pribadi (Input URL atau Preset)
                  const Text('Foto Profil Pribadi (URL Gambar / Foto):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: photoUrlCtrl,
                    decoration: InputDecoration(
                      hintText: 'Tempel link foto Anda (https://...)',
                      prefixIcon: const Icon(Icons.add_a_photo_outlined),
                      suffixIcon: photoUrlCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setModalState(() => photoUrlCtrl.clear()),
                            )
                          : null,
                    ),
                    onChanged: (_) => setModalState(() {}),
                  ),
                  const SizedBox(height: 8),

                  // Preset Pilihan Cepat Foto Avatar Mahasiswa
                  Row(
                    children: [
                      const Text('Pilih Cepat: ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ...samplePhotos.map((url) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => setModalState(() => photoUrlCtrl.text = url),
                            borderRadius: BorderRadius.circular(20),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(url),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pilihan Warna Avatar (Bila tidak menggunakan foto)
                  const Text('Warna Tema Avatar:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: avatarColors.map((color) {
                      final isSelected = selectedColor == color;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedColor = color),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: color.withAlpha(120),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                            ],
                          ),
                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Input Data Teks
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap Mahasiswa *',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: nimCtrl,
                          decoration: const InputDecoration(
                            labelText: 'NIM *',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: kelasCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Kelas *',
                            prefixIcon: Icon(Icons.meeting_room_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Kampus *',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: bioCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Slogan / Motto Belajar',
                      prefixIcon: Icon(Icons.format_quote_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),

                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _kPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Simpan Perubahan Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: () {
                      final err = state.updateProfile(
                        name: nameCtrl.text,
                        nim: nimCtrl.text,
                        kelas: kelasCtrl.text,
                        email: emailCtrl.text,
                        bio: bioCtrl.text,
                        avatarUrl: photoUrlCtrl.text,
                        avatarColor: selectedColor,
                      );
                      if (err != null) {
                        setModalState(() => validationError = err);
                      } else {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Profil berhasil diperbarui!'),
                              ],
                            ),
                            backgroundColor: _kPrimary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= 2. DIALOG TAMBAH TAUTAN CEPAT =================
  void _showAddLinkDialog(BuildContext context) {
    setState(() => _linkError = null);
    _linkNameController.clear();
    _linkUrlController.clear();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.add_link_rounded, color: _kPrimary),
              SizedBox(width: 8),
              Text('Tambah Tautan Web'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_linkError != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _linkError!,
                    style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              TextField(
                controller: _linkNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Situs / Materi',
                  hintText: 'Contoh: Portal E-Learning',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _linkUrlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Alamat Web (URL)',
                  hintText: 'learning.polibatam.ac.id',
                  prefixIcon: Icon(Icons.link_rounded),
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
                final err = context.readState.addQuickLink(
                  name: _linkNameController.text,
                  url: _linkUrlController.text,
                );
                if (err != null) {
                  setDialogState(() => _linkError = err);
                } else {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tautan berhasil ditambahkan dan siap diklik!'),
                      backgroundColor: Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  // ================= 3. BUKA LINK LANGSUNG KE BROWSER =================
  Future<void> _handleDirectLinkClick(BuildContext context, String name, String url) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.open_in_browser_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('Membuka $name ($url)...')),
          ],
        ),
        backgroundColor: _kPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    await launchExternalUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchState;
    final isDark = state.isDarkMode;

    final initials = state.userName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        // ================= KARTU IDENTITAS MAHASISWA DENGAN FOTO =================
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : _kPrimary.withAlpha(50),
              width: 1.2,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [_kAccent.withAlpha(80), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar / Foto Profil Pribadi
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: state.avatarColor,
                      backgroundImage: state.userAvatarUrl.isNotEmpty
                          ? NetworkImage(state.userAvatarUrl)
                          : null,
                      child: state.userAvatarUrl.isEmpty
                          ? Text(
                              initials.isEmpty ? 'TP' : initials,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),

                    // Detail Nama & NIM
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.userName,
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _kPrimary.withAlpha(isDark ? 60 : 25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'NIM: ${state.userNim} • ${state.userKelas}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: _kPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.userEmail,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Motto Mahasiswa
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF162032) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.format_quote_rounded, size: 18, color: _kPrimary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.userBio,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontStyle: FontStyle.italic,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Tombol Edit Profil
                OutlinedButton.icon(
                  onPressed: () => _showEditProfileDialog(context, state),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit Profil & Foto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(42),
                    foregroundColor: _kPrimary,
                    side: const BorderSide(color: _kPrimary, width: 1.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ================= PREFERENSI & TAMPILAN IMK =================
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                secondary: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: isDark ? const Color(0xFF60A5FA) : const Color(0xFFF59E0B),
                ),
                title: Text(
                  isDark ? 'Mode Gelap (Dark Mode)' : 'Mode Terang (Light Mode)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  isDark
                      ? 'Tema biru gelap aktif (Kontras tinggi & nyaman di mata)'
                      : 'Tema biru terang aktif (Bersih & mudah dibaca)',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                activeTrackColor: _kPrimary,
                value: isDark,
                onChanged: (_) => state.toggleTheme(),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: const Icon(Icons.info_outline_rounded, color: _kPrimary),
                title: const Text('Tentang TugasKu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text(
                  'Aplikasi ATS Praktikum Pemrograman Bergerak 2026',
                  style: TextStyle(fontSize: 11.5),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'TugasKu',
                    applicationVersion: 'v1.0.0 — ATS Praktikum',
                    applicationIcon: const Icon(Icons.checklist_rtl_rounded, size: 40, color: _kPrimary),
                    children: const [
                      Text('Aplikasi manajemen tugas mahasiswa TRPL Politeknik Negeri Batam.'),
                      SizedBox(height: 8),
                      Text('NIM: 4342511073 | Tulus Pratama | TRPL 3A'),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ================= TAUTAN CEPAT LANGSUNG KE BROWSER =================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.open_in_browser_rounded, color: _kPrimary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Tautan Web Cepat',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => _showAddLinkDialog(context),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: _kPrimary),
              label: const Text('Tambah', style: TextStyle(fontSize: 12, color: _kPrimary)),
            ),
          ],
        ),
        const SizedBox(height: 4),

        if (state.quickLinks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('Belum ada tautan web tersimpan')),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.quickLinks.map((link) {
              return InputChip(
                elevation: 1,
                avatar: const Icon(Icons.open_in_new_rounded, size: 16, color: _kPrimary),
                label: Text(
                  link.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                backgroundColor: isDark ? const Color(0xFF1E293B) : _kAccent.withAlpha(50),
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : _kPrimary.withAlpha(60),
                ),
                tooltip: 'Ketuk untuk membuka ${link.url}',
                onPressed: () => _handleDirectLinkClick(context, link.name, link.url),
                onDeleted: () {
                  state.removeQuickLink(link.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tautan "${link.name}" berhasil dihapus'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                deleteIconColor: Colors.red.shade400,
              );
            }).toList(),
          ),
        const SizedBox(height: 28),

        // Tombol Logout
        OutlinedButton.icon(
          onPressed: () {
            state.logout();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          icon: const Icon(Icons.logout_rounded, color: Colors.red),
          label: const Text('Keluar dari Akun', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }
}
