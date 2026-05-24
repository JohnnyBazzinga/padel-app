import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/role_invitation.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/roles_provider.dart';

class AdminInvitesScreen extends StatefulWidget {
  final String? invitationToken;
  final String? note;

  const AdminInvitesScreen({
    super.key,
    this.invitationToken,
    this.note,
  });

  @override
  State<AdminInvitesScreen> createState() => _AdminInvitesScreenState();
}

class _AdminInvitesScreenState extends State<AdminInvitesScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final auth = context.read<AuthProvider>();
    final roles = context.read<RolesProvider>();

    if (auth.isAuthenticated) {
      await Future.wait([
        roles.fetchMyInvitations(),
        roles.fetchPendingInvitations(),
      ]);
    }

    if (widget.invitationToken?.isNotEmpty == true) {
      await roles.fetchInvitationByToken(widget.invitationToken!);
    }
  }

  Future<void> _submitInvite(BuildContext context, RolesProvider roles) async {
    if (!_formKey.currentState!.validate()) return;

    roles.clearError();
    setState(() => _isSubmitting = true);
    final success = await roles.inviteOrganizer(
      _emailController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      _emailController.clear();
      _noteController.clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Convite enviado')),
        );
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(roles.error ?? 'Erro ao enviar convite')),
      );
    }
  }

  Future<void> _handleTokenAction(
      BuildContext context, bool accept, RolesProvider roles) async {
    if (widget.invitationToken == null) return;

    final auth = context.read<AuthProvider>();
    final success = accept
        ? await roles.acceptInvitationByToken(widget.invitationToken!)
        : await roles.rejectInvitationByToken(widget.invitationToken!);

    if (!mounted) return;

    if (!success) {
      final error = roles.error ?? 'Não foi possível processar o convite';
      if (!auth.isAuthenticated && roles.lastErrorStatus == 401) {
        final next = Uri(
          path: '/roles/invitations',
          queryParameters: {'token': widget.invitationToken},
        ).toString();
        context.go('/login?next=${Uri.encodeComponent(next)}');
        return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
      return;
    }
    roles.clearTokenInvitation();
    if (auth.isAuthenticated) {
      await auth.refreshUser();
    }

    if (context.mounted) {
      context.go(accept ? '/home' : '/roles/invitations');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accept
                ? 'Convite aceite. As tuas permissões foram atualizadas.'
                : 'Convite rejeitado.',
          ),
        ),
      );
    }
  }

  Future<void> _acceptInvitation(
      AuthProvider auth, RolesProvider roles, RoleInvitation invitation) async {
    final success = await roles.acceptInvitation(invitation.id);
    if (!mounted) return;
    if (!success) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(roles.error ?? 'Não foi possível aceitar')),
        );
      }
      return;
    }
    await auth.refreshUser();
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Convite aceite')),
      );
    }
  }

  Future<void> _rejectInvitation(
      AuthProvider auth, RolesProvider roles, RoleInvitation invitation) async {
    final success = await roles.rejectInvitation(invitation.id);
    if (!mounted) return;
    if (!success) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(roles.error ?? 'Não foi possível rejeitar')),
        );
      }
      return;
    }
    await auth.refreshUser();
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Convite rejeitado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final roles = context.watch<RolesProvider>();

    final canInvite = auth.canInviteOrganizer;
    final tokenInvitation = roles.tokenInvitation;
    final pending = roles.pendingInvitations;
    final mine = roles.myInvitations;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Convites'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.invitationToken != null && tokenInvitation != null)
                _TokenInvitationCard(
                  invitation: tokenInvitation,
                  onAccept: () => _handleTokenAction(context, true, roles),
                  onReject: () => _handleTokenAction(context, false, roles),
                )
              else if (widget.invitationToken != null)
                _RequestStateCard(
                  text: roles.error ?? 'A carregar convite...',
                  icon: Icons.link_off,
                  isError: roles.error != null,
                  isLoading: roles.isLoading,
                ),
              if (canInvite) ...[
                _SectionHeader(title: 'Convidar organizador'),
                _InviteOrganizerForm(
                  formKey: _formKey,
                  emailController: _emailController,
                  noteController: _noteController,
                  isSubmitting: _isSubmitting,
                  initialNote: widget.note,
                  onSubmit: () => _submitInvite(context, roles),
                ),
                _SectionHeader(title: 'Convites pendentes'),
                _InvitationList(
                  emptyText: 'Sem convites pendentes.',
                  invitations: pending,
                  onPrimaryAction: (invitation) async {
                    if (!invitation.isPending) return;
                    final cancelled =
                        await roles.cancelInvitation(invitation.id);
                    if (!mounted) return;
                    if (cancelled && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Convite cancelado')),
                      );
                    }
                  },
                ),
              ],
              _SectionHeader(
                  title: canInvite ? 'Meus convites' : 'Convites da tua conta'),
              if (widget.invitationToken == null &&
                  mine.isEmpty &&
                  !roles.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Ainda não recebeste convites.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                _InvitationList(
                  emptyText: 'Ainda não recebeste convites.',
                  invitations: mine,
                  onPrimaryAction: (invitation) async {
                    if (!invitation.isPending) return;
                    await _acceptInvitation(auth, roles, invitation);
                  },
                  onSecondaryAction: (invitation) async {
                    if (!invitation.isPending) return;
                    await _rejectInvitation(auth, roles, invitation);
                  },
                  showRole: true,
                  forMeSection: true,
                ),
            ].whereType<Widget>().toList(),
          ).animate().fadeIn(duration: 300.ms),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _RequestStateCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isError;
  final bool isLoading;

  const _RequestStateCard({
    required this.text,
    required this.icon,
    required this.isError,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isError
              ? AppColors.error.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.08),
          border: Border.all(
            color: isError
                ? AppColors.error.withOpacity(0.35)
                : AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isError ? AppColors.error : AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                    color: isError ? AppColors.error : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TokenInvitationCard extends StatelessWidget {
  final RoleInvitation invitation;
  final Future<void> Function() onAccept;
  final Future<void> Function() onReject;

  const _TokenInvitationCard({
    required this.invitation,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = invitation.isPending
        ? AppColors.warning
        : invitation.status == 'ACCEPTED'
            ? AppColors.success
            : AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surface,
          border: Border.all(color: AppColors.glassBorder),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    invitation.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  invitation.displayRole,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Convite para: ${invitation.email}',
              style: const TextStyle(fontSize: 16),
            ),
            if (invitation.note?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(invitation.note!,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 8),
            Text('Convidado por: ${invitation.invitedBy}'),
            if (invitation.expiresAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Expira a ${DateFormat('dd/MM/yyyy HH:mm').format(invitation.expiresAt!)}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            if (invitation.isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      child: const Text('Rejeitar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      child: const Text('Aceitar'),
                    ),
                  ),
                ],
              ),
            ] else
              Text(
                'Estado: ${invitation.status}',
                style: const TextStyle(color: AppColors.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}

class _InviteOrganizerForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController noteController;
  final bool isSubmitting;
  final String? initialNote;
  final VoidCallback onSubmit;

  const _InviteOrganizerForm({
    required this.formKey,
    required this.emailController,
    required this.noteController,
    required this.isSubmitting,
    required this.initialNote,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    if (initialNote != null && noteController.text.isEmpty) {
      noteController.text = initialNote!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: formKey,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(labelText: 'Email do utilizador'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Email obrigatório';
                    if (!value.contains('@')) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: noteController,
                  maxLines: 2,
                  decoration:
                      const InputDecoration(labelText: 'Mensagem (opcional)'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : onSubmit,
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Convidar organizador'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InvitationList extends StatelessWidget {
  final String emptyText;
  final List<RoleInvitation> invitations;
  final Future<void> Function(RoleInvitation)? onPrimaryAction;
  final Future<void> Function(RoleInvitation)? onSecondaryAction;
  final bool showRole;
  final bool forMeSection;

  const _InvitationList({
    required this.emptyText,
    required this.invitations,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.showRole = false,
    this.forMeSection = false,
  });

  @override
  Widget build(BuildContext context) {
    if (invitations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          emptyText,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: invitations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final invitation = invitations[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.surface,
            border: Border.all(color: AppColors.glassBorder),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(invitation.email,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              if (showRole)
                Text(
                  'Role: ${invitation.displayRole}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (forMeSection && invitation.isPending)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onSecondaryAction == null
                            ? null
                            : () => onSecondaryAction!(invitation),
                        child: const Text('Rejeitar'),
                      ),
                    ),
                  if (forMeSection && invitation.isPending)
                    const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onPrimaryAction == null
                          ? null
                          : invitation.isPending
                              ? () => onPrimaryAction!(invitation)
                              : null,
                      child: Text(forMeSection ? 'Aceitar' : 'Cancelar'),
                    ),
                  ),
                ],
              ),
              if (!invitation.isPending)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    invitation.status,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
