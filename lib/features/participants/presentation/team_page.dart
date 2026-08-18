import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/loading_view.dart';
import '../application/team_providers.dart';
import '../domain/team.dart';

class TeamPage extends ConsumerWidget {
  const TeamPage({super.key, required this.tournamentId});

  final String tournamentId;

  Future<void> _showEditor(
    BuildContext context,
    WidgetRef ref, [
    Team? initialTeam,
  ]) async {
    final nameController = TextEditingController(text: initialTeam?.name ?? '');
    final shortNameController = TextEditingController(text: initialTeam?.shortName ?? '');
    final institutionController = TextEditingController(text: initialTeam?.institution ?? '');

    final didSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(initialTeam == null ? 'Add team' : 'Edit team'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Team name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: shortNameController,
                  decoration: const InputDecoration(labelText: 'Short name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: institutionController,
                  decoration: const InputDecoration(labelText: 'Institution'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final shortName = shortNameController.text.trim();
                final institution = institutionController.text.trim();
                if (name.isEmpty || shortName.isEmpty) {
                  return;
                }

                final repository = ref.read(teamRepositoryProvider(tournamentId));
                if (initialTeam == null) {
                  repository.create(
                    name: name,
                    shortName: shortName,
                    institution: institution,
                  );
                } else {
                  repository.update(
                    initialTeam.copyWith(
                      name: name,
                      shortName: shortName,
                      institution: institution,
                    ),
                  );
                }
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(initialTeam == null ? 'Save' : 'Update'),
            ),
          ],
        );
      },
    );

    if (didSave == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(teamListProvider(tournamentId));
    final repository = ref.read(teamRepositoryProvider(tournamentId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/tournaments/$tournamentId'),
        ),
        title: const Text('Participants'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add team'),
      ),
      body: teamsAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(message: 'Could not load teams.\n$error'),
        data: (teams) {
          if (teams.isEmpty) {
            return const Center(child: Text('No teams yet. Add the first one.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: teams.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final team = teams[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  title: Text(team.name),
                  subtitle: team.institution.isNotEmpty
                      ? Text('${team.shortName} • ${team.institution}')
                      : Text(team.shortName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit team',
                        onPressed: () => _showEditor(context, ref, team),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete team',
                        onPressed: () async {
                          await repository.delete(team.id);
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
