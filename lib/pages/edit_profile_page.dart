import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/yens_theme.dart';
import '../data/repositories/yens_repository.dart';
import '../widgets/yens_date_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.initialBirthday,
  });

  final String initialName;
  final String initialEmail;
  final String initialBirthday;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _birthday;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
    _email = TextEditingController(text: widget.initialEmail);
    _birthday = TextEditingController(text: widget.initialBirthday);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _birthday.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime initial = DateTime(2000);
    if (_birthday.text.trim().isNotEmpty) {
      try {
        final parts = _birthday.text.trim().split('/');
        if (parts.length == 3) {
          initial = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      } catch (_) {}
    }

    await YensDatePicker.show(
      context,
      initialDate: initial,
      onDateSelected: (date) {
        setState(() => _birthday.text = "${date.day}/${date.month}/${date.year}");
      },
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name is required.');
      return;
    }
    if (email.isNotEmpty && !email.contains('@')) {
      setState(() => _error = 'Enter a valid email.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final repo = context.read<YensRepository>();
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('customer_id') ?? '';

    var ok = false;
    try {
      ok = await repo.updateCustomer(
        customerId: id,
        fields: {
          'name': name,
          if (email.isNotEmpty) 'email': email,
          if (_birthday.text.trim().isNotEmpty) 'birthday': _birthday.text.trim(),
        },
      );
    } catch (_) {
      ok = false;
    }

    await prefs.setString('customer_name', name);

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved locally. Server profile API may not be available yet.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YensTheme.cream,
      appBar: AppBar(
        backgroundColor: YensTheme.accent,
        elevation: 0,
        title: const Text('Edit profile', style: TextStyle(color: YensTheme.navy, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: YensTheme.navy),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: 'Name',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _birthday,
            readOnly: true,
            onTap: _pickDate,
            decoration: InputDecoration(
              labelText: 'Birthday (e.g. 15/8/1995)',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.calendar_today, color: YensTheme.navy),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: YensTheme.accent,
              foregroundColor: YensTheme.navy,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _saving
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}
