import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/matches_provider.dart';
import '../../../shared/widgets/widgets.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _cityController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 30);
  String _minLevel = 'BEGINNER';
  String _maxLevel = 'PROFESSIONAL';
  int _playersNeeded = 4;

  final _levels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'PROFESSIONAL'];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
      if (_endTime.hour < picked.hour ||
          (_endTime.hour == picked.hour && _endTime.minute <= picked.minute)) {
        final nextStart = TimeOfDay(
          hour: (picked.hour + 1) % 24,
          minute: picked.minute,
        );
        _endTime = nextStart;
      }
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchesProvider>();
    final auth = context.watch<AuthProvider>();
    if (!auth.isAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'Criar Jogo'),
        body: const Center(child: Text('Inicia sessao para criar jogos')),
      );
    }

    if (!auth.canCreateMatches) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'Criar Jogo'),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Sem permissoes para criar jogos',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Criar Jogo'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _titleController,
              label: 'Titulo',
              hint: 'Ex: Jogo casual no domingo',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDate,
              child: _PlainPickerField(
                label: 'Data',
                icon: Icons.calendar_today,
                value: DateFormat('EEEE, d MMMM yyyy', 'pt_PT').format(_selectedDate),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickStartTime,
                    child: _PlainPickerField(
                      label: 'Inicio',
                      icon: Icons.access_time,
                      value: _startTime.format(context),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickEndTime,
                    child: _PlainPickerField(
                      label: 'Fim',
                      icon: Icons.access_time,
                      value: _endTime.format(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _locationController,
              label: 'Local',
              hint: 'Nome do clube ou local',
              prefixIcon: Icons.location_on,
              textInputAction: TextInputAction.next,
              validator: (v) => v?.isEmpty == true ? 'Obrigatorio' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _cityController,
              label: 'Cidade',
              prefixIcon: Icons.location_city,
              validator: (v) => v?.isEmpty == true ? 'Obrigatorio' : null,
            ),
            const SizedBox(height: 24),
            Text(
              'Nivel',
              style: AppTypography.labelLarge,
            ).animate().fadeIn(duration: 150.ms),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _minLevel,
                    decoration: const InputDecoration(labelText: 'Minimo'),
                    items: _levels
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (v) => setState(() => _minLevel = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _maxLevel,
                    decoration: const InputDecoration(labelText: 'Maximo'),
                    items: _levels
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (v) => setState(() => _maxLevel = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Numero de jogadores',
              style: AppTypography.labelLarge,
            ).animate().fadeIn(duration: 150.ms),
            const SizedBox(height: 8),
            Row(
              children: [
                _PlayersButton(
                  label: '2',
                  selected: _playersNeeded == 2,
                  onTap: () => setState(() => _playersNeeded = 2),
                ),
                const SizedBox(width: 12),
                _PlayersButton(
                  label: '4',
                  selected: _playersNeeded == 4,
                  onTap: () => setState(() => _playersNeeded = 4),
                ),
              ],
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              label: 'Criar Jogo',
              isLoading: provider.isLoading,
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final match = await provider.createMatch(
                  date: DateFormat('yyyy-MM-dd').format(_selectedDate),
                  startTime:
                      '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                  endTime:
                      '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
                  title: _titleController.text.isNotEmpty
                      ? _titleController.text
                      : null,
                  location: _locationController.text,
                  city: _cityController.text,
                  minLevel: _minLevel,
                  maxLevel: _maxLevel,
                  playersNeeded: _playersNeeded,
                );

                if (match != null && mounted) {
                  context.go('/matches/${match.id}');
                }
              },
            ).animate().fadeIn(duration: 150.ms),
          ],
        ),
      ),
    );
  }
}

class _PlainPickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;

  const _PlainPickerField({
    required this.label,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: AppDecorations.borderRadiusMd,
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 18),
          const SizedBox(width: 10),
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
          const Spacer(),
          Text(value, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}

class _PlayersButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PlayersButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: AppDecorations.borderRadiusMd,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.glassBorder,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Center(
            child: Text(
              '$label jogadores',
              style: AppTypography.labelMedium.copyWith(
                color: selected ? AppColors.background : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
