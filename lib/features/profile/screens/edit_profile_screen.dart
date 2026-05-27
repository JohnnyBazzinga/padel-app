import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _cityController;
  late TextEditingController _bioController;
  late String _skillLevel;
  late String _availabilityStatus;
  bool _isLoading = false;

  final _levels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'PROFESSIONAL'];
  final _availabilityOptions = const [
    _AvailabilityOption(value: '', label: 'Não definir'),
    _AvailabilityOption(value: 'a_jogar', label: 'A Jogar'),
    _AvailabilityOption(value: 'a_procurar_parceiro', label: 'A Procurar Parceiro'),
    _AvailabilityOption(value: 'offline', label: 'Offline'),
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _firstNameController = TextEditingController(text: user?.firstName);
    _lastNameController = TextEditingController(text: user?.lastName);
    _cityController = TextEditingController(text: user?.city);
    _bioController = TextEditingController(text: user?.bio);
    _skillLevel = user?.skillLevel ?? 'BEGINNER';
    _availabilityStatus = canonicalAvailabilityStatus(user?.availabilityStatus) ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final payload = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'city': _cityController.text.trim(),
      'bio': _bioController.text.trim(),
      'skillLevel': _skillLevel,
    };

    if (_availabilityStatus.isNotEmpty) {
      payload['availabilityStatus'] = _availabilityStatus;
    }

    final success = await context.read<AuthProvider>().updateProfile(payload);
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AuthProvider>().error ?? 'Erro ao atualizar'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Editar Perfil'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _firstNameController,
                    label: 'Nome',
                    prefixIcon: Icons.person_outline,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _lastNameController,
                    label: 'Apelido',
                    prefixIcon: Icons.badge_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _cityController,
              label: 'Cidade',
              prefixIcon: Icons.location_on,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _bioController,
              label: 'Bio',
              hint: 'Conta algo sobre ti...',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _skillLevel,
              decoration: const InputDecoration(
                labelText: 'Nivel',
                prefixIcon: Icon(Icons.sports_tennis),
              ),
              items:
                  _levels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) => setState(() => _skillLevel = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _availabilityStatus,
              decoration: const InputDecoration(
                labelText: 'Estado social',
                prefixIcon: Icon(Icons.circle_notifications_rounded),
              ),
              items: _availabilityOptions
                  .map((option) => DropdownMenuItem(
                        value: option.value,
                        child: Text(option.label),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _availabilityStatus = v ?? ''),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Guardar',
              isLoading: _isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityOption {
  final String value;
  final String label;

  const _AvailabilityOption({required this.value, required this.label});
}
