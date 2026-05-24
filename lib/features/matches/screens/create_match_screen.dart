import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/matches_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchesProvider>();
    final auth = context.watch<AuthProvider>();
    if (!auth.isAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Criar Jogo')),
        body: const Center(child: Text('Inicia sessão para criar jogos')),
      );
    }

    if (!auth.canCreateMatches) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Criar Jogo')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Sem permissões para criar jogos',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Criar Jogo')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título (opcional)',
                hintText: 'Ex: Jogo casual no domingo',
              ),
            ),
            const SizedBox(height: 16),

            // Date
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('EEEE, d MMMM yyyy', 'pt_PT').format(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),

            // Time
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _startTime,
                      );
                      if (picked != null) {
                        setState(() => _startTime = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Início',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(_startTime.format(context)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _endTime,
                      );
                      if (picked != null) {
                        setState(() => _endTime = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fim',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(_endTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Local',
                prefixIcon: Icon(Icons.location_on),
                hintText: 'Nome do clube ou local',
              ),
              validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Cidade',
                prefixIcon: Icon(Icons.location_city),
              ),
              validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 24),

            // Level
            const Text('Nível', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _minLevel,
                    decoration: const InputDecoration(labelText: 'Mínimo'),
                    items: _levels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                    onChanged: (v) => setState(() => _minLevel = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _maxLevel,
                    decoration: const InputDecoration(labelText: 'Máximo'),
                    items: _levels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                    onChanged: (v) => setState(() => _maxLevel = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Players
            const Text('Número de jogadores', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [2, 4].map((n) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _playersNeeded = n),
                  child: Container(
                    margin: EdgeInsets.only(right: n == 2 ? 8 : 0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _playersNeeded == n ? AppColors.primary : AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '$n jogadores',
                        style: TextStyle(
                          color: _playersNeeded == n ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: provider.isLoading ? null : () async {
                if (!_formKey.currentState!.validate()) return;

                final match = await provider.createMatch(
                  date: DateFormat('yyyy-MM-dd').format(_selectedDate),
                  startTime: '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                  endTime: '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
                  title: _titleController.text.isNotEmpty ? _titleController.text : null,
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
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: provider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Criar Jogo'),
            ),
          ],
        ),
      ),
    );
  }
}
