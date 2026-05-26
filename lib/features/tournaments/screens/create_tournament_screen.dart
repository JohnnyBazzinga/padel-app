import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/tournaments_provider.dart';
import '../../../shared/widgets/widgets.dart';

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _clubIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxTeamsController = TextEditingController(text: '16');
  final _entryFeeController = TextEditingController(text: '0');
  final _prizePoolController = TextEditingController();

  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 14));
  DateTime _registrationDeadline = DateTime.now().add(const Duration(days: 5));

  String _format = 'SINGLE_ELIMINATION';
  String _minLevel = 'BEGINNER';
  String _maxLevel = 'PROFESSIONAL';
  bool _isLoading = false;

  static const formats = [
    'SINGLE_ELIMINATION',
    'DOUBLE_ELIMINATION',
    'ROUND_ROBIN',
  ];
  static const levels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'PROFESSIONAL'];

  @override
  void dispose() {
    _nameController.dispose();
    _clubIdController.dispose();
    _descriptionController.dispose();
    _maxTeamsController.dispose();
    _entryFeeController.dispose();
    _prizePoolController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, DateTime initial, Function(DateTime) onPick) async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: initial,
    );
    if (selected != null) {
      onPick(selected);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = context.read<TournamentsProvider>();
    final success = await provider.createTournament(
      name: _nameController.text.trim(),
      clubId: _clubIdController.text.trim(),
      startDate: DateFormat('yyyy-MM-dd').format(_startDate),
      endDate: DateFormat('yyyy-MM-dd').format(_endDate),
      registrationDeadline: DateFormat('yyyy-MM-dd').format(_registrationDeadline),
      format: _format,
      maxTeams: int.parse(_maxTeamsController.text.trim()),
      minLevel: _minLevel,
      maxLevel: _maxLevel,
      entryFee: int.parse(_entryFeeController.text.trim()),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      prizePool: _prizePoolController.text.trim().isEmpty
          ? null
          : int.parse(_prizePoolController.text.trim()),
    );
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
      context.go('/tournaments');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Erro ao criar torneio')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.canCreateTournaments) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'Criar Torneio'),
        body: const Center(child: Text('Sem permissoes para criar torneios')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Criar Torneio'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _nameController,
                  label: 'Nome',
                  validator: (v) => v?.isEmpty == true ? 'Nome obrigatorio' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _clubIdController,
                  label: 'ID do clube',
                  validator: (v) => v?.isEmpty == true ? 'Clube obrigatorio' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Descricao',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: 'Inicio',
                        value: _startDate,
                        onTap: () => _pickDate(
                          context,
                          _startDate,
                          (value) => setState(() => _startDate = value),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateField(
                        label: 'Fim',
                        value: _endDate,
                        onTap: () => _pickDate(
                          context,
                          _endDate,
                          (value) => setState(() => _endDate = value),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _DateField(
                  label: 'Prazo inscricoes',
                  value: _registrationDeadline,
                  onTap: () => _pickDate(
                    context,
                    _registrationDeadline,
                    (value) => setState(() => _registrationDeadline = value),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _format,
                        decoration: const InputDecoration(labelText: 'Formato'),
                        items: formats
                            .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                            .toList(),
                        onChanged: (value) => setState(() => _format = value!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _maxTeamsController,
                        keyboardType: TextInputType.number,
                        label: 'Equipas maximas',
                        validator: (v) {
                          final parsed = int.tryParse(v ?? '');
                          if (parsed == null || parsed <= 1) return 'Valor invalido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _minLevel,
                        decoration: const InputDecoration(labelText: 'Nivel minimo'),
                        items: levels
                            .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                            .toList(),
                        onChanged: (value) => setState(() => _minLevel = value!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _maxLevel,
                        decoration: const InputDecoration(labelText: 'Nivel maximo'),
                        items: levels
                            .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                            .toList(),
                        onChanged: (value) => setState(() => _maxLevel = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _entryFeeController,
                        keyboardType: TextInputType.number,
                        label: 'Taxa inscricao (centimos)',
                        validator: (v) {
                          final parsed = int.tryParse(v ?? '');
                          if (parsed == null || parsed < 0) return 'Valor invalido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _prizePoolController,
                        keyboardType: TextInputType.number,
                        label: 'Premio (centimos)',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Criar Torneio',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ).animate().fadeIn(duration: 300.ms),
              ],
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: AppDecorations.borderRadiusMd,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
            const Spacer(),
            Text(
              DateFormat('dd/MM/yyyy').format(value),
              style: AppTypography.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
