import 'package:flutter/material.dart';

import '../core/supabase_client.dart';
import '../quotes/quote_model.dart';
import '../quotes/quote_service.dart';
import '../quotes/quote_tile.dart';
import '../widgets/loading.dart';
import '../widgets/empty_state.dart';

/// Favorites screen
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Quote> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload when screen becomes visible
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (!SupabaseService.isAuthenticated) {
      setState(() {
        _favorites = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final favorites = await QuoteService.getFavoriteQuotes();
      setState(() => _favorites = favorites);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading favorites: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite(Quote quote) async {
    try {
      await QuoteService.removeFromFavorites(quote.id);
      setState(() => _favorites.removeWhere((q) => q.id == quote.id));
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
        title: const Text('Favorites'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        child: _isLoading
            ? const LoadingWidget()
            : _favorites.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.favorite_border,
                    title: 'No favorites yet',
                    message:
                        'Start favoriting quotes to see them here. Tap the\nheart icon on any quote to save it.',
                  )
                : ListView.builder(
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final quote = _favorites[index];
                      return QuoteTile(
                        quote: quote,
                        isFavorite: true,
                        onFavoriteTap: () => _toggleFavorite(quote),
                      );
                    },
                  ),
      ),
    );
  }
}
