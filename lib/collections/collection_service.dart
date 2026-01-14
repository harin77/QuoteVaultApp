import '../core/constants.dart';
import '../core/supabase_client.dart';
import 'collection_model.dart';
import '../quotes/quote_model.dart';

/// Service for managing collections
class CollectionService {
  /// Get all collections for current user
  static Future<List<Collection>> getUserCollections() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) return [];

      final response = await SupabaseService.client
          .from(AppConstants.collectionsTable)
          .select('*, quote_count:collection_quotes(count)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        final data = json as Map<String, dynamic>;
        final quoteCountData = data['quote_count'] as List?;
        final quoteCount = quoteCountData?.isNotEmpty == true
            ? (quoteCountData![0] as Map<String, dynamic>)['count'] as int
            : 0;
        return Collection.fromJson({
          ...data,
          'quote_count': quoteCount,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch collections: $e');
    }
  }

  /// Create a new collection
  static Future<Collection> createCollection(String name) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await SupabaseService.client
          .from(AppConstants.collectionsTable)
          .insert({
        'name': name,
        'user_id': userId,
      }).select().single();

      return Collection.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create collection: $e');
    }
  }

  /// Delete a collection
  static Future<void> deleteCollection(String collectionId) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await SupabaseService.client
          .from(AppConstants.collectionsTable)
          .delete()
          .eq('id', collectionId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to delete collection: $e');
    }
  }

  /// Get quotes in a collection
  static Future<List<Quote>> getCollectionQuotes(String collectionId) async {
    try {
      final response = await SupabaseService.client
          .from(AppConstants.collectionQuotesTable)
          .select('quote:quotes(*)')
          .eq('collection_id', collectionId);

      return (response as List)
          .map((item) => Quote.fromJson(
              (item as Map<String, dynamic>)['quote'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch collection quotes: $e');
    }
  }

  /// Add quote to collection
  static Future<void> addQuoteToCollection(
    String collectionId,
    String quoteId,
  ) async {
    try {
      await SupabaseService.client
          .from(AppConstants.collectionQuotesTable)
          .insert({
        'collection_id': collectionId,
        'quote_id': quoteId,
      });
    } catch (e) {
      throw Exception('Failed to add quote to collection: $e');
    }
  }

  /// Remove quote from collection
  static Future<void> removeQuoteFromCollection(
    String collectionId,
    String quoteId,
  ) async {
    try {
      await SupabaseService.client
          .from(AppConstants.collectionQuotesTable)
          .delete()
          .eq('collection_id', collectionId)
          .eq('quote_id', quoteId);
    } catch (e) {
      throw Exception('Failed to remove quote from collection: $e');
    }
  }

  /// Check if quote is in collection
  static Future<bool> isQuoteInCollection(
    String collectionId,
    String quoteId,
  ) async {
    try {
      final response = await SupabaseService.client
          .from(AppConstants.collectionQuotesTable)
          .select()
          .eq('collection_id', collectionId)
          .eq('quote_id', quoteId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}
