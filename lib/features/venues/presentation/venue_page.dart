import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/loading_view.dart';
import '../application/venue_providers.dart';
import '../domain/venue.dart';

class VenuePage extends ConsumerWidget {
  const VenuePage({super.key, required this.tournamentId});

  final String tournamentId;

  Future<void> _showEditor(BuildContext context, WidgetRef ref, [Venue? initialVenue]) async {
    final nameController = TextEditingController(text: initialVenue?.name ?? '');
    final buildingController = TextEditingController(text: initialVenue?.building ?? '');
    final capacityController = TextEditingController(
      text: initialVenue == null ? '' : initialVenue.capacity.toString(),
    );

    final didSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(initialVenue == null ? 'Add venue' : 'Edit venue'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Venue name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: buildingController,
                  decoration: const InputDecoration(labelText: 'Building / room note'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Capacity'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final building = buildingController.text.trim();
                final capacityText = capacityController.text.trim();
                if (name.isEmpty) {
                  return;
                }

                final capacity = int.tryParse(capacityText) ?? 0;
                final repository = ref.read(venueRepositoryProvider(tournamentId));
                if (initialVenue == null) {
                  repository.create(
                    name: name,
                    building: building,
                    capacity: capacity,
                  );
                } else {
                  repository.update(
                    initialVenue.copyWith(
                      name: name,
                      building: building,
                      capacity: capacity,
                    ),
                  );
                }
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(initialVenue == null ? 'Save' : 'Update'),
            ),
          ],
        );
      },
    );

    if (didSave == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venue saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venuesAsync = ref.watch(venueListProvider(tournamentId));
    final repository = ref.read(venueRepositoryProvider(tournamentId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/tournaments/$tournamentId'),
        ),
        title: const Text('Venues'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add venue'),
      ),
      body: venuesAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(message: 'Could not load venues.\n$error'),
        data: (venues) {
          if (venues.isEmpty) {
            return const Center(child: Text('No venues yet. Add the first space.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: venues.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final venue = venues[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  title: Text(venue.name),
                  subtitle: Text(
                    venue.building.isNotEmpty
                        ? '${venue.building}${venue.capacity > 0 ? ' • ${venue.capacity} seats' : ''}'
                        : (venue.capacity > 0 ? '${venue.capacity} seats' : 'No capacity noted'),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit venue',
                        onPressed: () => _showEditor(context, ref, venue),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete venue',
                        onPressed: () async {
                          await repository.delete(venue.id);
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
