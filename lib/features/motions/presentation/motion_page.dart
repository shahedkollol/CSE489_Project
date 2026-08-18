import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/loading_view.dart';
import '../application/motion_providers.dart';
import '../domain/motion.dart';

class MotionPage extends ConsumerWidget {
  const MotionPage({super.key, required this.tournamentId});

  final String tournamentId;

  Future<void> _showEditor(BuildContext context, WidgetRef ref, [Motion? initialMotion]) async {
    final textController = TextEditingController(text: initialMotion?.text ?? '');
    final infoController = TextEditingController(text: initialMotion?.info ?? '');
    final roundController = TextEditingController(
      text: initialMotion == null ? '1' : initialMotion.round.toString(),
    );

    final didSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(initialMotion == null ? 'Add motion' : 'Edit motion'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Motion text'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: infoController,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Notes / info'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roundController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Round number'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final text = textController.text.trim();
                final info = infoController.text.trim();
                final round = int.tryParse(roundController.text) ?? 1;
                if (text.isEmpty) {
                  return;
                }

                final repository = ref.read(motionRepositoryProvider(tournamentId));
                if (initialMotion == null) {
                  repository.create(
                    text: text,
                    info: info,
                    round: round,
                  );
                } else {
                  repository.update(
                    initialMotion.copyWith(
                      text: text,
                      info: info,
                      round: round,
                    ),
                  );
                }
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(initialMotion == null ? 'Save' : 'Update'),
            ),
          ],
        );
      },
    );

    if (didSave == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Motion saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motionsAsync = ref.watch(motionListProvider(tournamentId));
    final repository = ref.read(motionRepositoryProvider(tournamentId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/tournaments/$tournamentId'),
        ),
        title: const Text('Motions'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add motion'),
      ),
      body: motionsAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(message: 'Could not load motions.\n$error'),
        data: (motions) {
          if (motions.isEmpty) {
            return const Center(child: Text('No motions yet. Add the first one.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: motions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final motion = motions[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  title: Text(motion.text),
                  subtitle: motion.info.isNotEmpty
                      ? Text('Round ${motion.round} • ${motion.info}')
                      : Text('Round ${motion.round}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit motion',
                        onPressed: () => _showEditor(context, ref, motion),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete motion',
                        onPressed: () async {
                          await repository.delete(motion.id);
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
