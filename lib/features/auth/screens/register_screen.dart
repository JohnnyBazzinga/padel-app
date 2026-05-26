import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController();
  String _selectedLevel = 'BEGINNER';
  bool _isLoading = false;

  final _levels = [
    {'value': 'BEGINNER', 'label': 'Iniciante'},
    {'value': 'INTERMEDIATE', 'label': 'Intermedio'},
    {'value': 'ADVANCED', 'label': 'Avancado'},
    {'value': 'PROFESSIONAL', 'label': 'Profissional'},
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      city: _cityController.text.trim(),
      skillLevel: _selectedLevel,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      final next = GoRouterState.of(context).uri.queryParameters['next'];
      final target = (next != null && next.isNotEmpty)
          ? Uri.decodeComponent(next)
          : '/home';
      context.go(target);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Erro ao criar conta'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Criar conta',
        transparent: true,
        showBackgroundLine: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Regista-te e encontra parceiros para jogar.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _firstNameController,
                        label: 'Nome',
                        hint: 'Joao',
                        prefixIcon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatorio';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _lastNameController,
                        label: 'Apelido',
                        hint: 'Silva',
                        prefixIcon: Icons.badge_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatorio';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  label: 'Email',
                  hint: 'teuemail@exemplo.pt',
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Introduz o teu email';
                    }
                    if (!value.contains('@')) {
                      return 'Email invalido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  obscureText: true,
                  label: 'Password',
                  hint: 'minimo 8 caracteres',
                  prefixIcon: Icons.lock_outline,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Introduz uma password';
                    }
                    if (value.length < 8) {
                      return 'Minimo 8 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _cityController,
                  label: 'Cidade',
                  hint: 'Lisboa',
                  prefixIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedLevel,
                  decoration: InputDecoration(
                    labelText: 'Nivel de jogo',
                    labelStyle: AppTypography.labelMedium,
                    prefixIcon: const Icon(Icons.sports_tennis),
                  ),
                  items: _levels
                      .map(
                        (level) => DropdownMenuItem(
                          value: level['value'],
                          child: Text(level['label']!),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedLevel = value!);
                  },
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Criar conta',
                  isLoading: _isLoading,
                  onPressed: _register,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ja tens conta? ',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Entrar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
