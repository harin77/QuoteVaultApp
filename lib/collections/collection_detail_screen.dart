import 'package:flutter/material.dart';

import '../core/supabase_client.dart';
import '../quotes/quote_model.dart';
import '../quotes/quote_tile.dart';
import '../widgets/loading.dart';
import '../widgets/empty_state.dart';
import 'collection_model.dart';
import 'collection_service.dart';

/// Collection detail screen
class CollectionDetailScreen extends StatefulWidget {
  final Collection collection;

  const CollectionDetailScreen({super.key, required this.collection});

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  List<Quote> _quotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    setState(() => _isLoading = true);
    try {
      final quotes =
          await CollectionService.getCollectionQuotes(widget.collection.id);
      setState(() => _quotes = quotes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quotes: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeQuote(Quote quote) async {
    try {
      await CollectionService.removeQuoteFromCollection(
        widget.collection.id,
        quote.id,
      );
      setState(() => _quotes.removeWhere((q) => q.id == quote.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Collection'),
                  content: Text(
                      'Are you sure you want to delete "${widget.collection.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child:
                          const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                try {
                  await CollectionService.deleteCollection(widget.collection.id);
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadQuotes,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${_quotes.length} quotes',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const LoadingWidget()
                  : _quotes.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.format_quote,
                          title: 'No quotes in this collection',
                          message:
                              'Add quotes from your feed or favorites by tapping the + icon.',
                        )
                      : ListView.builder(
                          itemCount: _quotes.length,
                          itemBuilder: (context, index) {
                            final quote = _quotes[index];
                            return QuoteTile(
                              quote: quote,
                              onAddToCollection: () => _removeQuote(quote),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
