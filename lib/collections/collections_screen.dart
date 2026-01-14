import 'package:flutter/material.dart';

import '../core/supabase_client.dart';
import '../widgets/loading.dart';
import '../widgets/empty_state.dart';
import 'collection_model.dart';
import 'collection_service.dart';
import 'collection_detail_screen.dart';

/// Collections screen
class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  List<Collection> _collections = [];
  bool _isLoading = true;
  bool _showCreateDialog = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCollections();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadCollections() async {
    if (!SupabaseService.isAuthenticated) {
      setState(() {
        _collections = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final collections = await CollectionService.getUserCollections();
      setState(() => _collections = collections);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading collections: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createCollection() async {
    if (_nameController.text.trim().isEmpty) return;

    try {
      await CollectionService.createCollection(_nameController.text.trim());
      _nameController.clear();
      setState(() => _showCreateDialog = false);
      _loadCollections();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating collection: $e')),
        );
      }
    }
  }

  Future<void> _deleteCollection(Collection collection) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection'),
        content: Text('Are you sure you want to delete "${collection.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await CollectionService.deleteCollection(collection.id);
        _loadCollections();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting collection: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() => _showCreateDialog = true);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Create Collection'),
                  content: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Collection name',
                      hintText: 'Enter collection name',
                    ),
                    autofocus: true,
                    onSubmitted: (_) => _createCollection(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _nameController.clear();
                        setState(() => _showCreateDialog = false);
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _createCollection,
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ).then((_) {
                setState(() => _showCreateDialog = false);
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCollections,
        child: _isLoading
            ? const LoadingWidget()
            : _collections.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.folder_outlined,
                    title: 'No collections yet',
                    message:
                        'Create collections to organize your favorite quotes by theme or topic.',
                  )
                : ListView.builder(
                    itemCount: _collections.length,
                    itemBuilder: (context, index) {
                      final collection = _collections[index];
                      return ListTile(
                        leading: const Icon(Icons.folder),
                        title: Text(collection.name),
                        subtitle: Text('${collection.quoteCount} quotes'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCollection(collection),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CollectionDetailScreen(
                                collection: collection,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
