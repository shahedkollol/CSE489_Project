import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/tournament_providers.dart';
import '../domain/tournament.dart';

class TournamentFormPage extends ConsumerStatefulWidget {
  const TournamentFormPage({super.key, this.tournamentId});

  /// Null when creating a new tournament, set when editing an existing one.
  final String? tournamentId;

  bool get isEditing => tournamentId != null;

  @override
  ConsumerState<TournamentFormPage> createState() => _TournamentFormPageState();
}

class _TournamentFormPageState extends ConsumerState<TournamentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  TournamentFormat _format = TournamentFormat.bp;

  bool _slugEditedManually = false;
  bool _hasLoadedExisting = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  void _prefillFrom(Tournament tournament) {
    if (_hasLoadedExisting) return;
    _hasLoadedExisting = true;
    _nameController.text = tournament.name;
    _slugController.text = tournament.slug;
    setState(() => _format = tournament.format);
  }

  String _slugify(String input) {
    final lower = input.trim().toLowerCase();
    final replaced = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return replaced.replaceAll(RegExp(r'^-+|-+$'), '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final repository = ref.read(tournamentRepositoryProvider);
    try {
      if (widget.isEditing) {
        await repository.update(
          Tournament(
            id: widget.tournamentId!,
            name: _nameController.text.trim(),
            slug: _slugController.text.trim(),
            format: _format,
          ),
        );
        if (mounted) context.go('/admin/tournaments/${widget.tournamentId}');
      } else {
        final id = await repository.create(
          name: _nameController.text.trim(),
          slug: _slugController.text.trim(),
          format: _format,
        );
        if (mounted) context.go('/admin/tournaments/$id');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      // Side-effect-only subscription: prefill the form once the
      // tournament loads, without making this whole page rebuild on
      // every downstream Firestore update while the admin is mid-edit.
      ref.listen(tournamentByIdProvider(widget.tournamentId!), (previous, next) {
        next.whenData((tournament) {
          if (tournament != null) _prefillFrom(tournament);
        });
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit tournament' : 'New tournament')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Tournament name'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Enter a name' : null,
                    onChanged: (value) {
                      if (!_slugEditedManually) {
                        _slugController.text = _slugify(value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _slugController,
                    decoration: const InputDecoration(
                      labelText: 'Slug',
                      helperText: 'Used in the public results URL',
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Enter a slug' : null,
                    onChanged: (_) => _slugEditedManually = true,
                  ),
                  const SizedBox(height: 24),
                  Text('Format', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  SegmentedButton<TournamentFormat>(
                    segments: const [
                      ButtonSegment(
                        value: TournamentFormat.bp,
                        label: Text('BP \u00b7 4 teams'),
                      ),
                      ButtonSegment(
                        value: TournamentFormat.ap,
                        label: Text('AP \u00b7 2 teams'),
                      ),
                    ],
                    selected: {_format},
                    onSelectionChanged: (selection) => setState(() => _format = selection.first),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.isEditing ? 'Save changes' : 'Create tournament'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
