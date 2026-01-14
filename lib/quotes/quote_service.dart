import '../core/constants.dart';
import '../core/supabase_client.dart';
import 'quote_model.dart';

/// Service for managing quotes
class QuoteService {
  /// Fetch all quotes
  static Future<List<Quote>> fetchQuotes({String? category}) async {
    try {
      var query = SupabaseService.client
          .from(AppConstants.quotesTable)
          .select();

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => Quote.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch quotes: $e');
    }
  }

  /// Search quotes by text
  static Future<List<Quote>> searchQuotes(String searchText) async {
    try {
      final response = await SupabaseService.client
          .from(AppConstants.quotesTable)
          .select()
          .or('text.ilike.%$searchText%,author.ilike.%$searchText%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Quote.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search quotes: $e');
    }
  }

  /// Get quote by ID
  static Future<Quote?> getQuoteById(String id) async {
    try {
      final response = await SupabaseService.client
          .from(AppConstants.quotesTable)
          .select()
          .eq('id', id)
          .single();

      return Quote.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Check if quote is favorited by current user
  static Future<bool> isFavorite(String quoteId) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) return false;

      final response = await SupabaseService.client
          .from(AppConstants.favoritesTable)
          .select()
          .eq('user_id', userId)
          .eq('quote_id', quoteId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Add quote to favorites
  static Future<void> addToFavorites(String quoteId) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await SupabaseService.client.from(AppConstants.favoritesTable).insert({
        'user_id': userId,
        'quote_id': quoteId,
      });
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  /// Remove quote from favorites
  static Future<void> removeFromFavorites(String quoteId) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await SupabaseService.client
          .from(AppConstants.favoritesTable)
          .delete()
          .eq('user_id', userId)
          .eq('quote_id', quoteId);
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  /// Get user's favorite quotes
  static Future<List<Quote>> getFavoriteQuotes() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) return [];

      final response = await SupabaseService.client
          .from(AppConstants.favoritesTable)
          .select('quote:quotes(*)')
          .eq('user_id', userId);

      return (response as List)
          .map((item) => Quote.fromJson(
              (item as Map<String, dynamic>)['quote'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch favorite quotes: $e');
    }
  }
}
