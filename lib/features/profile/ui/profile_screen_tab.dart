import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hlms_mobile/features/auth/logic/auth_bloc/auth_bloc.dart';
import 'package:hlms_mobile/features/profile/data/profile_repository.dart';

class ProfileScreenTab extends StatelessWidget {
  const ProfileScreenTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Custom Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: const Icon(Icons.arrow_back, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Pengaturan',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Icon(Icons.settings, color: Color(0xFF003399), size: 28),
                  const SizedBox(width: 16),
                  const Icon(Icons.notifications_none, color: Colors.grey, size: 28),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Profile Card with Avatar Overlay
            Stack(
              alignment: Alignment.topCenter,
              children: [
                // Menu Container
                Container(
                  margin: const EdgeInsets.only(top: 40, left: 24, right: 24),
                  padding: const EdgeInsets.only(top: 80, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(Icons.person, 'Edit Profil', () {}),
                      _buildMenuItem(Icons.payment, 'Opsi Pembayaran', () {}),
                      _buildMenuItem(Icons.description, 'Syarat & Ketentuan', () {}),
                      _buildMenuItem(Icons.headset_mic, 'Pusat Bantuan', () {}),
                      _buildMenuItem(Icons.send, 'Undang Teman', () {}),
                      _buildMenuItem(
                        Icons.logout, 
                        'Keluar', 
                        () {
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Divider(height: 32),
                      ),
                      _buildMenuItem(
                        Icons.delete_forever, 
                        'Hapus Akun', 
                        () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Akun'),
                              content: const Text('Apakah Anda yakin ingin menghapus akun? Tindakan ini tidak dapat dibatalkan.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            try {
                              await context.read<ProfileRepository>().deleteAccount();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Akun berhasil dihapus')),
                                );
                                context.read<AuthBloc>().add(AuthLogoutRequested());
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          }
                        }, 
                        isLast: true,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
                
                // Avatar & User Info
                Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        image: const DecorationImage(
                          image: NetworkImage('https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        String name = 'User';
                        String email = '';
                        if (state is AuthAuthenticated) {
                          name = state.user['name'] ?? 'User';
                          email = state.user['email'] ?? '';
                        }
                        return Column(
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 20, 
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            if (email.isNotEmpty)
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 14, 
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Footer
            const Text(
              'Versi Aplikasi 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '© 2026 MOLANG LMS. Hak Cipta Dilindungi.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon, 
    String title, 
    VoidCallback onTap, {
    bool isLast = false,
    Color color = const Color(0xFF003399),
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: color),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
