import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/supabase_client.dart';
import '../core/theme.dart';
import '../notifications/daily_quote_service.dart';
import '../widgets/loading.dart';
import '../widgets/empty_state.dart';
import '../collections/collection_service.dart';
import '../collections/collection_model.dart';
import 'quote_model.dart';
import 'quote_service.dart';
import 'quote_tile.dart';

/// Home screen with quotes feed
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Quote> _quotes = [];
  List<Quote> _filteredQuotes = [];
  List<String> _favoriteIds = [];
  bool _isLoading = true;
  String _selectedCategory = '';
  final TextEditingController _searchController = TextEditingController();
  Quote? _dailyQuote;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
    _loadDailyQuote();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQuotes() async {
    setState(() => _isLoading = true);
    try {
      final quotes = await QuoteService.fetchQuotes(
        category: _selectedCategory.isEmpty ? null : _selectedCategory,
      );
      setState(() {
        _quotes = quotes;
        _filteredQuotes = quotes;
      });
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

  Future<void> _loadDailyQuote() async {
    try {
      final quote = await DailyQuoteService.getDailyQuote();
      setState(() => _dailyQuote = quote);
    } catch (e) {
      // Ignore errors for daily quote
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await QuoteService.getFavoriteQuotes();
      setState(() {
        _favoriteIds = favorites.map((q) => q.id).toList();
      });
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _toggleFavorite(Quote quote) async {
    try {
      final isFavorite = _favoriteIds.contains(quote.id);
      if (isFavorite) {
        await QuoteService.removeFromFavorites(quote.id);
        setState(() => _favoriteIds.remove(quote.id));
      } else {
        await QuoteService.addToFavorites(quote.id);
        setState(() => _favoriteIds.add(quote.id));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showCollectionsDialog(Quote quote) async {
    try {
      final collections = await CollectionService.getUserCollections();
      
      if (!mounted) return;

      if (collections.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No collections available. Create one first!'),
          ),
        );
        return;
      }

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add to Collection'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final collection = collections[index];
                return ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(collection.name),
                  subtitle: Text('${collection.quoteCount} quotes'),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      await CollectionService.addQuoteToCollection(
                        collection.id,
                        quote.id,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added to "${collection.name}"'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading collections: $e')),
        );
      }
    }
  }

  void _filterQuotes(String query) {
    if (query.isEmpty) {
      setState(() => _filteredQuotes = _quotes);
      return;
    }

    setState(() {
      _filteredQuotes = _quotes.where((quote) {
        return quote.text.toLowerCase().contains(query.toLowerCase()) ||
            quote.author.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = _selectedCategory == category ? '' : category;
    });
    _loadQuotes();
  }

  Future<void> _refresh() async {
    await Future.wait([
      _loadQuotes(),
      _loadFavorites(),
      _loadDailyQuote(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              title: const Text(AppConstants.appName),
              floating: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refresh,
                ),
              ],
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search quotes or authors...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterQuotes('');
                            },
                          )
                        : null,
                  ),
                  onChanged: _filterQuotes,
                ),
              ),
            ),

            // Category Tabs
            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: AppConstants.categories.length,
                  itemBuilder: (context, index) {
                    final category = AppConstants.categories[index];
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) => _selectCategory(category),
                        selectedColor: primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Daily Quote (if available)
            if (_dailyQuote != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: isDark
                        ? primaryColor.withOpacity(0.2)
                        : primaryColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.wb_twilight,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Daily Quote',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '"${_dailyQuote!.text}"',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '— ${_dailyQuote!.author}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Quotes List
            if (_isLoading)
              const SliverFillRemaining(
                child: LoadingWidget(),
              )
            else if (_filteredQuotes.isEmpty)
              SliverFillRemaining(
                child: EmptyStateWidget(
                  icon: Icons.format_quote,
                  title: 'No quotes found',
                  message: _searchController.text.isNotEmpty
                      ? 'Try a different search term'
                      : 'No quotes available',
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final quote = _filteredQuotes[index];
                    final isFavorite = _favoriteIds.contains(quote.id);
                    return QuoteTile(
                      quote: quote,
                      isFavorite: isFavorite,
                      onFavoriteTap: () => _toggleFavorite(quote),
                      onLongPress: () => _showCollectionsDialog(quote),
                    );
                  },
                  childCount: _filteredQuotes.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
