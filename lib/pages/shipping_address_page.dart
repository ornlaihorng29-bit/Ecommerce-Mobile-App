// lib/pages/shipping_address_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/shipping_address_model.dart';
import '../services/shipping_address_service.dart';

class ShippingAddressPage extends StatefulWidget {
  const ShippingAddressPage({super.key});

  @override
  State<ShippingAddressPage> createState() => _ShippingAddressPageState();
}

class _ShippingAddressPageState extends State<ShippingAddressPage>
    with SingleTickerProviderStateMixin {
  static const _bg      = Color(0xFF0A0A14);
  static const _surface = Color(0xFF13131F);
  static const _border  = Color(0xFF1E1E2E);
  static const _accent  = Color(0xFF6C63FF);
  static const _accent2 = Color(0xFF06B6D4);

  final _service = ShippingAddressService();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading   = false;
  bool _isFetching  = true;
  bool _hasExisting = false;

  final _address1Controller   = TextEditingController();
  final _address2Controller   = TextEditingController();
  final _cityController       = TextEditingController();
  final _stateController      = TextEditingController();
  final _postalCodeController = TextEditingController();

  String _selectedCountryCode = 'KH';

  late AnimationController _animController;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  final _countries = const [
    {'code': 'KH', 'name': '🇰🇭  Cambodia'},
    {'code': 'US', 'name': '🇺🇸  United States'},
    {'code': 'GB', 'name': '🇬🇧  United Kingdom'},
    {'code': 'TH', 'name': '🇹🇭  Thailand'},
    {'code': 'VN', 'name': '🇻🇳  Vietnam'},
    {'code': 'SG', 'name': '🇸🇬  Singapore'},
    {'code': 'MY', 'name': '🇲🇾  Malaysia'},
    {'code': 'JP', 'name': '🇯🇵  Japan'},
    {'code': 'CN', 'name': '🇨🇳  China'},
    {'code': 'AU', 'name': '🇦🇺  Australia'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _fetchExisting();
  }

  @override
  void dispose() {
    _animController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  // ── Fetch existing ───────────────────────────────────────────────────────

  Future<void> _fetchExisting() async {
    final existing = await _service.getMyAddress();
    if (existing != null) {
      _hasExisting               = true;
      _address1Controller.text   = existing.address1;
      _address2Controller.text   = existing.address2;
      _cityController.text       = existing.city;
      _stateController.text      = existing.state; // mapped from "stats"
      _postalCodeController.text = existing.postalCode;
      final codeExists = _countries.any((c) => c['code'] == existing.countryCode);
      _selectedCountryCode = codeExists ? existing.countryCode : 'KH';
    }
    if (mounted) {
      setState(() => _isFetching = false);
      _animController.forward();
    }
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final request = ShippingAddressRequestModel(
      address1    : _address1Controller.text.trim(),
      address2    : _address2Controller.text.trim(),
      city        : _cityController.text.trim(),
      state       : _stateController.text.trim(),
      countryCode : _selectedCountryCode,
      postalCode  : _postalCodeController.text.trim(),
    );

    try {
      if (_hasExisting) {
        await _service.update(request);
      } else {
        await _service.store(request);
      }
      if (!mounted) return;
      _showSuccess('Address saved successfully!');
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Snackbars ────────────────────────────────────────────────────────────

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500))),
    ]),
    backgroundColor: Colors.redAccent,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(16),
  ));

  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
      const SizedBox(width: 8),
      Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
    ]),
    backgroundColor: const Color(0xFF22C55E),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(16),
  ));

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(top: -80,    right: -80, child: _blob(260, _accent,  0.12)),
          Positioned(bottom: -100, left: -80, child: _blob(300, _accent2, 0.07)),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                if (_isFetching)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: _accent, strokeWidth: 2),
                    ),
                  )
                else
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildBanner(),
                                const SizedBox(height: 24),
                                _buildForm(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                _buildBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── App bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar() => Padding(
    padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
    child: Row(children: [
      IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white70, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      Expanded(
        child: Text(
          _hasExisting ? 'Update Shipping Address' : 'Add Shipping Address',
          style: const TextStyle(
              color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
    ]),
  );

  // ── Banner ───────────────────────────────────────────────────────────────

  Widget _buildBanner() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _accent.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _accent.withOpacity(0.2)),
    ),
    child: Row(children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_accent, _accent2]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            _hasExisting ? 'Update your shipping address' : 'Add your shipping address',
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text('Required to complete your orders',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
        ]),
      ),
    ]),
  );

  // ── Form ─────────────────────────────────────────────────────────────────

  Widget _buildForm() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      _label('Address Line 1 *'),
      _field(
        controller: _address1Controller,
        hint: '123 Street 456',
        icon: Icons.home_outlined,
        validator: (v) => v!.trim().isEmpty ? 'Address line 1 is required' : null,
      ),
      const SizedBox(height: 16),

      _label('Address Line 2'),
      _field(
        controller: _address2Controller,
        hint: 'Apartment, suite, unit (optional)',
        icon: Icons.apartment_outlined,
      ),
      const SizedBox(height: 16),

      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('City *'),
          _field(
            controller: _cityController,
            hint: 'Phnom Penh',
            icon: Icons.location_city_outlined,
            validator: (v) => v!.trim().isEmpty ? 'City is required' : null,
          ),
        ])),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('State / Province *'),
          _field(
            controller: _stateController,
            hint: 'Phnom Penh',
            icon: Icons.map_outlined,
            validator: (v) => v!.trim().isEmpty ? 'State is required' : null,
          ),
        ])),
      ]),
      const SizedBox(height: 16),

      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('Country *'),
          _countryDropdown(),
        ])),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('Postal Code *'),
          _field(
            controller: _postalCodeController,
            hint: '12000',
            icon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) => v!.trim().isEmpty ? 'Required' : null,
          ),
        ])),
      ]),

    ]),
  );

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.w600)),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) =>
      TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
          filled: true,
          fillColor: _bg,
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.25), size: 17),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accent)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent)),
          errorStyle: const TextStyle(fontSize: 10),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      );

  Widget _countryDropdown() => DropdownButtonFormField<String>(
    value: _selectedCountryCode,
    dropdownColor: const Color(0xFF1A1A2E),
    style: const TextStyle(color: Colors.white, fontSize: 13),
    icon: Icon(Icons.keyboard_arrow_down_rounded,
        color: Colors.white.withOpacity(0.4)),
    decoration: InputDecoration(
      filled: true,
      fillColor: _bg,
      prefixIcon: Icon(Icons.flag_outlined,
          color: Colors.white.withOpacity(0.25), size: 17),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    ),
    items: _countries
        .map((c) => DropdownMenuItem<String>(
      value: c['code'],
      child: Text(c['name']!,
          style: const TextStyle(color: Colors.white, fontSize: 13)),
    ))
        .toList(),
    onChanged: (v) {
      if (v != null) setState(() => _selectedCountryCode = v);
    },
  );

  // ── Bottom bar ───────────────────────────────────────────────────────────

  Widget _buildBottomBar() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
    decoration: BoxDecoration(
      color: _bg,
      border: Border(top: BorderSide(color: _border)),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, -6))
      ],
    ),
    child: SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_accent, Color(0xFF9B5CF6)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: _accent.withOpacity(0.45),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _saveAddress,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: _isLoading
              ? const SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.check_rounded, color: Colors.white, size: 20),
          label: Text(
            _isLoading ? 'Saving...' : (_hasExisting ? 'Update Address' : 'Save Address'),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2),
          ),
        ),
      ),
    ),
  );

  Widget _blob(double size, Color color, double opacity) => Container(
      width: size, height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: [color.withOpacity(opacity), Colors.transparent])));
}