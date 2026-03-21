// lib/pages/edit_profile_page.dart

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import '../services/storage_service.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _service = ProfileService();
  final _picker  = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;

  String?    _selectedGender;
  XFile?     _pickedImage;    // pending — uploaded only on Save
  Uint8List? _imageBytes;
  bool       _isLoading   = false;
  bool       _fieldsChanged = false;
  String?    _errorMessage;

  late AnimationController _animController;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  static const _bg      = Color(0xFF0A0A14);
  static const _surface = Color(0xFF13131F);
  static const _border  = Color(0xFF1E1E2E);
  static const _accent  = Color(0xFF6C63FF);
  static const _accent2 = Color(0xFF06B6D4);

  static const _genders = [
    {'label': 'Male',   'value': 'male'},
    {'label': 'Female', 'value': 'female'},
    {'label': 'Other',  'value': 'other'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController  = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _dobController   = TextEditingController(text: widget.user.dob ?? '');
    _selectedGender  = widget.user.gender;

    _nameController.addListener(_checkFieldsChanged);
    _emailController.addListener(_checkFieldsChanged);
    _dobController.addListener(_checkFieldsChanged);

    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  /// Recalculates whether any field (including a pending image) has changed
  void _checkFieldsChanged() {
    final changed =
        _nameController.text.trim()  != widget.user.name        ||
        _emailController.text.trim() != widget.user.email       ||
        _dobController.text.trim()   != (widget.user.dob ?? '') ||
        _selectedGender              != widget.user.gender      ||
        _pickedImage                 != null; // pending image counts as a change
    if (changed != _fieldsChanged) setState(() => _fieldsChanged = changed);
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkFieldsChanged);
    _emailController.removeListener(_checkFieldsChanged);
    _dobController.removeListener(_checkFieldsChanged);
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // ── Image picker — deferred, no upload here ────────────────────────────────

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 36, height: 4,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2)),
          ),
          _sheetTile(Icons.photo_library_outlined, 'Choose from Gallery',
              ImageSource.gallery),
          if (!kIsWeb)
            _sheetTile(Icons.camera_alt_outlined, 'Take a Photo',
                ImageSource.camera),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _sheetTile(IconData icon, String label, ImageSource source) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
            color: _accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: _accent, size: 20),
      ),
      title: Text(label,
          style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 15, fontWeight: FontWeight.w500)),
      onTap: () async {
        Navigator.pop(context);
        await _selectImage(source);
      },
    );
  }

  /// Stores picked image locally — upload deferred to Save
  Future<void> _selectImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (file == null) return;

    try {
      final bytes = await file.readAsBytes();
      setState(() {
        _pickedImage   = file;
        _imageBytes    = bytes;
        _fieldsChanged = true; // pending image enables Save button
        _errorMessage  = null;
      });
    } catch (e) {
      setState(() =>
          _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ── Date picker ────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    DateTime initial = DateTime(1993, 1, 1);
    if (_dobController.text.isNotEmpty) {
      try {
        final parts = _dobController.text.split('/');
        if (parts.length == 3) {
          initial = DateTime(int.parse(parts[2]), int.parse(parts[1]),
              int.parse(parts[0]));
        }
      } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _accent,
            onPrimary: Colors.white,
            surface: Color(0xFF13131F),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final d = picked.day.toString().padLeft(2, '0');
      final m = picked.month.toString().padLeft(2, '0');
      _dobController.text = '$d/$m/${picked.year}';
      _checkFieldsChanged();
    }
  }

  // ── Save — branches on whether an image is pending ─────────────────────────
  //
  //  _pickedImage != null  →  POST /users/edit  (multipart: image + fields)
  //  _pickedImage == null  →  PATCH /users/edit (JSON: fields only)

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null) {
      setState(() => _errorMessage = 'Please select a gender');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final name   = _nameController.text.trim();
      final email  = _emailController.text.trim();
      final gender = _selectedGender!;
      final dob    = _dobController.text.trim();
      final req    = EditProfileRequest(
          name: name, email: email, gender: gender, dob: dob);

      if (_pickedImage != null) {
        // ── POST /users/edit — multipart (image + fields)
        await _service.uploadImageWithProfile(_pickedImage!, req);
      } else {
        // ── PATCH /users/edit — JSON (fields only)
        await _service.editProfile(req);
      }

      await StorageService.updateProfile(
          name: name, email: email, gender: gender, dob: dob);

      // Reset change-tracking after a successful save
      setState(() {
        _fieldsChanged = false;
        _pickedImage   = null; // consumed — next save will use PATCH again
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Profile updated successfully!',
                style: TextStyle(fontWeight: FontWeight.w500)),
          ]),
          backgroundColor: const Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() =>
          _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final canSave = _fieldsChanged && !_isLoading;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(top: -80, right: -80, child: _blob(260, _accent, 0.18)),
          Positioned(
              bottom: -100, left: -80, child: _blob(300, _accent2, 0.10)),

          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text('Edit Profile',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3)),
                    ),
                  ]),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // ── Avatar ───────────────────────────────
                              Center(
                                child: Stack(
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
                                      child: ClipOval(
                                        child: _imageBytes != null
                                            ? Image.memory(_imageBytes!,
                                                fit: BoxFit.cover,
                                                width: 90, height: 90)
                                            : Center(
                                                child: Text(
                                                  _initials(widget.user.name),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 30,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                )),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _isLoading ? null : _pickImage,
                                      child: Container(
                                        width: 30, height: 30,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                              colors: [_accent, _accent2]),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: _bg, width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                                color:
                                                    _accent.withOpacity(0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3))
                                          ],
                                        ),
                                        child: const Icon(
                                            Icons.camera_alt_rounded,
                                            color: Colors.white, size: 15),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),
                              Center(
                                child: GestureDetector(
                                  onTap: _isLoading ? null : _pickImage,
                                  child: Text(
                                    _pickedImage != null
                                        ? 'Photo selected — save to upload'
                                        : 'Tap to change photo',
                                    style: TextStyle(
                                        color: _pickedImage != null
                                            ? const Color(0xFFF59E0B)
                                            : _accent.withOpacity(0.7),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // ── Form card ────────────────────────────
                              Container(
                                padding: const EdgeInsets.all(22),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Full Name'),
                                    const SizedBox(height: 8),
                                    _field(
                                      controller: _nameController,
                                      hint: 'Your name',
                                      icon: Icons.person_outline_rounded,
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                              ? 'Name is required'
                                              : null,
                                    ),

                                    const SizedBox(height: 18),
                                    _label('Email Address'),
                                    const SizedBox(height: 8),
                                    _field(
                                      controller: _emailController,
                                      hint: 'you@example.com',
                                      icon: Icons.email_outlined,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Email is required';
                                        }
                                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                            .hasMatch(v)) {
                                          return 'Enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 18),
                                    _label('Gender'),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: _genders.map((g) {
                                        final sel =
                                            _selectedGender == g['value'];
                                        return Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedGender =
                                                      g['value'];
                                                  _errorMessage = null;
                                                });
                                                _checkFieldsChanged();
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 180),
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  gradient: sel
                                                      ? const LinearGradient(
                                                          colors: [
                                                              _accent,
                                                              _accent2
                                                            ])
                                                      : null,
                                                  color:
                                                      sel ? null : _bg,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12),
                                                  border: Border.all(
                                                    color: sel
                                                        ? Colors.transparent
                                                        : _border,
                                                  ),
                                                  boxShadow: sel
                                                      ? [
                                                          BoxShadow(
                                                              color: _accent
                                                                  .withOpacity(
                                                                      0.3),
                                                              blurRadius: 10,
                                                              offset:
                                                                  const Offset(
                                                                      0, 4))
                                                        ]
                                                      : [],
                                                ),
                                                child: Center(
                                                  child: Text(g['label']!,
                                                      style: TextStyle(
                                                        color: sel
                                                            ? Colors.white
                                                            : Colors.white
                                                                .withOpacity(
                                                                    0.4),
                                                        fontSize: 13,
                                                        fontWeight: sel
                                                            ? FontWeight.w700
                                                            : FontWeight.w400,
                                                      )),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),

                                    const SizedBox(height: 18),
                                    _label('Date of Birth'),
                                    const SizedBox(height: 8),
                                    _field(
                                      controller: _dobController,
                                      hint: 'DD/MM/YYYY',
                                      icon: Icons.calendar_today_outlined,
                                      readOnly: true,
                                      onTap: _pickDate,
                                      validator: (v) =>
                                          (v == null || v.isEmpty)
                                              ? 'Date of birth is required'
                                              : null,
                                    ),

                                    if (_errorMessage != null) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEF4444)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: const Color(0xFFEF4444)
                                                  .withOpacity(0.3)),
                                        ),
                                        child: Row(children: [
                                          const Icon(
                                              Icons.error_outline_rounded,
                                              color: Color(0xFFEF4444),
                                              size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                              child: Text(_errorMessage!,
                                                  style: const TextStyle(
                                                      color:
                                                          Color(0xFFEF4444),
                                                      fontSize: 13))),
                                        ]),
                                      ),
                                    ],

                                    const SizedBox(height: 24),

                                    // ── Save button ───────────────────
                                    SizedBox(
                                      width: double.infinity,
                                      height: 54,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: canSave
                                                ? [
                                                    _accent,
                                                    const Color(0xFF9B5CF6)
                                                  ]
                                                : [
                                                    Colors.white
                                                        .withOpacity(0.06),
                                                    Colors.white
                                                        .withOpacity(0.06),
                                                  ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: canSave
                                              ? [
                                                  BoxShadow(
                                                      color: _accent
                                                          .withOpacity(0.45),
                                                      blurRadius: 20,
                                                      offset:
                                                          const Offset(0, 8))
                                                ]
                                              : [],
                                        ),
                                        child: ElevatedButton(
                                          onPressed:
                                              canSave ? _handleSave : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            disabledBackgroundColor:
                                                Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        16)),
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 22, height: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2.5))
                                              : Text(
                                                  'Save Changes',
                                                  style: TextStyle(
                                                    color: canSave
                                                        ? Colors.white
                                                        : Colors.white
                                                            .withOpacity(
                                                                0.25),
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    letterSpacing: 0.3,
                                                  )),
                                        ),
                                      ),
                                    ),

                                    if (!_fieldsChanged) ...[
                                      const SizedBox(height: 10),
                                      Center(
                                        child: Text(
                                          'Edit a field above to save changes',
                                          style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(0.2),
                                              fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _label(String text) => Text(text,
      style: TextStyle(
          color: Colors.white.withOpacity(0.45),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.white.withOpacity(0.18), fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white24, size: 20),
        filled: true,
        fillColor: _bg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: Colors.white.withOpacity(0.08))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: Colors.white.withOpacity(0.08))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _accent, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEF4444))),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
        errorStyle:
            const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
      ),
      validator: validator,
    );
  }

  Widget _blob(double size, Color color, double opacity) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            color.withOpacity(opacity),
            Colors.transparent
          ])));

  String _initials(String name) => name
      .trim()
      .split(' ')
      .take(2)
      .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
      .join();
}