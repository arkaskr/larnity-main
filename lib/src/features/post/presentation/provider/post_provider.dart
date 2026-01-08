import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final postProvider =
    StateNotifierProvider<PostNotifier, AsyncValue<List<Map<String, dynamic>>>>(
      (ref) => PostNotifier(),
    );

class PostNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  PostNotifier() : super(const AsyncLoading());

  Future<void> fetchPostsByChannel(String channelId) async {
    try {
      state = const AsyncLoading();

      final response = await Supabase.instance.client
          .from('Post')
          .select('''
            id,
            title,
            htmlContent,
            jsonContent,
            authorId,
            created_at
            ''')
          .eq('channelId', channelId)
          .order('created_at', ascending: false);

      state = AsyncData(List<Map<String, dynamic>>.from(response));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
