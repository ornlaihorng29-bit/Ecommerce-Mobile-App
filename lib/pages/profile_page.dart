// lib/pages/profile_page.dart

import 'package:ecommerce_mobile_app/pages/order_history_page.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import '../services/storage_service.dart';
import '../utils/image_url.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  /// Increment this from the parent to force a reload
  final int reloadKey;

  const ProfilePage({super.key, this.reloadKey = 0});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileService = ProfileService();
  late Future<UserProfile> _future;

  static const _bg      = Color(0xFF0A0A14);
  static const _surface = Color(0xFF13131F);
  static const _border  = Color(0xFF1E1E2E);
  static const _accent  = Color(0xFF6C63FF);
  static const _accent2 = Color(0xFF06B6D4);

  @override
  void initState() {
    super.initState();
    _future = _profileService.getProfile();
  }

  @override
  void didUpdateWidget(ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload whenever parent increments reloadKey
    if (oldWidget.reloadKey != widget.reloadKey) {
      _future = _profileService.getProfile();
    }
  }

  void _reload() => setState(() {
        _future = _profileService.getProfile();
      });

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.white.withOpacity(0.55)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style:
                    TextStyle(color: Colors.white.withOpacity(0.45))),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 9),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Sign Out',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await StorageService.clearAll();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(
              top: -80, right: -80, child: _blob(260, _accent, 0.18)),
          Positioned(
              bottom: -100, left: -80, child: _blob(300, _accent2, 0.10)),
          SafeArea(
            child: FutureBuilder<UserProfile>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoading();
                }
                if (snapshot.hasError) {
                  return _buildError(snapshot.error
                      .toString()
                      .replaceFirst('Exception: ', ''));
                }
                return _buildProfile(snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(UserProfile user) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Profile',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5)),
            GestureDetector(
              onTap: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditProfilePage(user: user)),
                );
                if (updated == true) _reload();
              },
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                ),
                child: Icon(Icons.edit_outlined,
                    color: Colors.white.withOpacity(0.6), size: 19),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Avatar card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                          colors: [_accent, _accent2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      boxShadow: [
                        BoxShadow(
                            color: _accent.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8))
                      ],
                    ),
                    child: user.image != null
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: resolveImageUrl(user.image!),
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white)),
                              errorWidget: (_, __, ___) =>
                                  _avatarInitials(user.name),
                            ),
                          )
                        : _avatarInitials(user.name),
                  ),
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                        color: _accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: _bg, width: 2)),
                    child: const Icon(Icons.camera_alt_outlined,
                        color: Colors.white, size: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(user.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3)),
              const SizedBox(height: 4),
              Text(user.email,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 14)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    _accent.withOpacity(0.15),
                    _accent2.withOpacity(0.15)
                  ]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _accent.withOpacity(0.2)),
                ),
                child: Text(
                  'Member since ${_formatDate(user.createdAt)}',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        _sectionLabel('Account Info'),
        const SizedBox(height: 12),
        _infoTile(Icons.person_outline_rounded, 'Full Name', user.name),
        _infoTile(Icons.email_outlined, 'Email', user.email),
        if (user.gender != null)
          _infoTile(Icons.wc_outlined, 'Gender', _capitalize(user.gender!)),
        if (user.dob != null)
          _infoTile(Icons.cake_outlined, 'Date of Birth', user.dob!),
        _infoTile(Icons.tag_rounded, 'User ID', '#${user.id}'),
        _infoTile(Icons.calendar_today_outlined, 'Joined',
            _formatDate(user.createdAt)),

        const SizedBox(height: 24),

        _sectionLabel('Settings'),
        const SizedBox(height: 12),
        _menuTile(Icons.shopping_bag_outlined, 'My Orders', onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
          );
        }),
        _menuTile(Icons.favorite_outline_rounded, 'Wishlist'),
        _menuTile(Icons.lock_outline_rounded, 'Change Password'),
        _menuTile(Icons.help_outline_rounded, 'Help & Support'),

        const SizedBox(height: 24),

        GestureDetector(
          onTap: _logout,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.25)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded,
                    color: Color(0xFFEF4444), size: 20),
                SizedBox(width: 10),
                Text('Sign Out',
                    style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      children: [
        Container(height: 26, width: 140,
            decoration: BoxDecoration(color: _surface,
                borderRadius: BorderRadius.circular(8))),
        const SizedBox(height: 28),
        Container(height: 240,
            decoration: BoxDecoration(color: _surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _border))),
        const SizedBox(height: 24),
        ...List.generate(4, (_) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(height: 62,
              decoration: BoxDecoration(color: _surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border))),
        )),
      ],
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                color: Colors.redAccent.withOpacity(0.7), size: 52),
            const SizedBox(height: 14),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5), fontSize: 14)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _reload,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_accent, _accent2]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: _accent.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: const Text('Retry',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarInitials(String name) {
    final initials = name.trim().split(' ')
        .take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
    return Center(
        child: Text(initials,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800)));
  }

  Widget _sectionLabel(String label) => Text(label,
      style: TextStyle(
          color: Colors.white.withOpacity(0.35),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8));

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border)),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: _accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: _accent.withOpacity(0.7), size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 11, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

  Widget _menuTile(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border)),
        child: Row(children: [
          Icon(icon, color: Colors.white.withOpacity(0.55), size: 20),
          const SizedBox(width: 14),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 15, fontWeight: FontWeight.w600))),
          Icon(Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.2), size: 20),
        ]),
      ),
    );
  }

  Widget _blob(double size, Color color, double opacity) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
                colors: [color.withOpacity(opacity), Colors.transparent])));

  String _formatDate(DateTime dt) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}