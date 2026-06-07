import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AuthController auth;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    auth = Get.find<AuthController>();
    _populateFields(auth.user.value);
  }

  void _populateFields(UserModel? u) {
    if (u == null) return;
    auth.nameCtrl.text    = u.name;
    auth.emailCtrl.text   = u.email;
    auth.dobCtrl.text     = u.dob;
    auth.addressCtrl.text = u.address;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        leading: const BackButton(color: AppColors.textPrimary),
        actions: [
          if (!auth.isGuest)
            TextButton(
              onPressed: () {
                if (_editing) {
                  _populateFields(auth.user.value); // reset on cancel
                }
                setState(() => _editing = !_editing);
              },
              child: Text(_editing ? 'Cancel' : 'Edit ✏',
                style: const TextStyle(color: AppColors.accent, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: Obx(() {
        final u = auth.user.value;
        if (u == null) return const Center(child: CircularProgressIndicator());
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // Avatar
            _AvatarWidget(u: u, editing: _editing && !auth.isGuest),
            const SizedBox(height: 12),
            if (u.isGuest) ...[
              const Text('Guest User',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Sign in with Phone to unlock full features',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: auth.signOut, child: const Text('Sign in with Phone')),
            ] else ...[
              Text(u.name.isNotEmpty ? u.name : 'Hunger Point Customer',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              if (u.phone.isNotEmpty) Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.verified, color: AppColors.success, size: 16),
                const SizedBox(width: 4),
                Text(u.phone, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 24),
              _editing
                ? _EditForm(
                    auth: auth,
                    onSave: () => setState(() => _editing = false),
                  )
                : _ProfileView(u: u),
            ],
          ]),
        );
      }),
    );
  }
}

// ── Avatar (tappable in edit mode to pick new photo) ──────────────────────────

class _AvatarWidget extends StatefulWidget {
  final UserModel u;
  final bool editing;
  const _AvatarWidget({required this.u, required this.editing});
  @override State<_AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<_AvatarWidget> {
  Uint8List? _newBytes;

  Future<void> _pick() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _newBytes = bytes);
    // Immediately save the new photo to Firestore/Storage
    await Get.find<AuthController>().updateProfile(
      name:        widget.u.name,
      email:       widget.u.email,
      dob:         widget.u.dob,
      address:     widget.u.address,
      avatarBytes: bytes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
    final hasPhoto = _newBytes != null || u.photoUrl.isNotEmpty;

    Widget avatar;
    if (_newBytes != null) {
      avatar = CircleAvatar(radius: 45, backgroundImage: MemoryImage(_newBytes!));
    } else if (u.photoUrl.isNotEmpty) {
      avatar = CircleAvatar(
        radius: 45,
        backgroundImage: CachedNetworkImageProvider(u.photoUrl),
        backgroundColor: AppColors.primary,
        child: !hasPhoto
          ? Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white))
          : null,
      );
    } else {
      avatar = CircleAvatar(
        radius: 45,
        backgroundColor: AppColors.primary,
        child: Text(
          u.isGuest ? '👤' : (u.name.isNotEmpty ? u.name[0].toUpperCase() : '?'),
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: widget.editing ? _pick : null,
      child: Stack(alignment: Alignment.center, children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))]),
          child: avatar,
        ),
        if (widget.editing)
          Positioned(
            bottom: 0, right: 0,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2)),
              child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
            ),
          ),
      ]),
    );
  }
}

// ── Read-only profile view ─────────────────────────────────────────────────────

class _ProfileView extends StatelessWidget {
  final UserModel u;
  const _ProfileView({required this.u});
  @override
  Widget build(BuildContext context) => Column(children: [
    _FieldRow('Full Name',    u.name.isNotEmpty    ? u.name    : 'Not set', Icons.person_outline),
    _FieldRow('Phone Number', u.phone.isNotEmpty   ? u.phone   : 'Not set', Icons.phone_outlined, verified: u.phone.isNotEmpty),
    _FieldRow('Email',        u.email.isNotEmpty   ? u.email   : 'Not set', Icons.email_outlined),
    _FieldRow('Date of Birth',u.dob.isNotEmpty     ? u.dob     : 'Not set', Icons.cake_outlined),
    _FieldRow('Address',      u.address.isNotEmpty ? u.address : 'Not set', Icons.location_on_outlined),
  ]);
}

class _FieldRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final bool verified;
  const _FieldRow(this.label, this.value, this.icon, {this.verified = false});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
    child: Row(children: [
      Icon(icon, color: AppColors.accent, size: 20),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      ])),
      if (verified) const Icon(Icons.verified_rounded, color: AppColors.success, size: 18),
    ]),
  );
}

// ── Edit form ─────────────────────────────────────────────────────────────────

class _EditForm extends StatelessWidget {
  final AuthController auth;
  final VoidCallback onSave;
  const _EditForm({required this.auth, required this.onSave});

  @override
  Widget build(BuildContext context) => Form(
    key: auth.profileFormKey,
    child: Column(children: [
      TextFormField(
        controller: auth.nameCtrl,
        decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
        validator: (v) => v?.isEmpty == true ? 'Name required' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: auth.emailCtrl,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
      ),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(1995),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            auth.dobCtrl.text = '${picked.day}/${picked.month}/${picked.year}';
          }
        },
        child: AbsorbPointer(child: TextFormField(
          controller: auth.dobCtrl,
          decoration: const InputDecoration(
            labelText: 'Date of Birth',
            prefixIcon: Icon(Icons.cake_outlined),
            suffixIcon: Icon(Icons.calendar_today_outlined)),
        )),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: auth.addressCtrl,
        maxLines: 2,
        decoration: const InputDecoration(
          labelText: 'Delivery Address',
          prefixIcon: Icon(Icons.location_on_outlined),
          alignLabelWithHint: true,
        ),
      ),
      const SizedBox(height: 20),
      Obx(() => ElevatedButton(
        onPressed: auth.isLoading.value ? null : () async {
          if (!auth.profileFormKey.currentState!.validate()) return;
          await auth.updateProfile(
            name:    auth.nameCtrl.text.trim(),
            email:   auth.emailCtrl.text.trim(),
            dob:     auth.dobCtrl.text.trim(),
            address: auth.addressCtrl.text.trim(),
          );
          onSave();
        },
        child: auth.isLoading.value
          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF1A1A1A)))
          : const Text('Save Changes'),
      )),
    ]),
  );
}
