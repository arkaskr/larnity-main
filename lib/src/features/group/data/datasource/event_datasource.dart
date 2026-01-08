import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/event_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final eventDataSourceProvider = Provider<EventDataSource>((ref) {
  return EventDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class EventDataSource {
  final SupabaseClient supabaseClient;

  EventDataSource({required this.supabaseClient});

  Future<Either<Failure, EventModel>> createEvent({
    required EventModel event,
  }) async {
    try {
      final response = await supabaseClient
          .from('Event')
          .insert(event.toMap())
          .select()
          .single();

      Log.info("Create Event Response: ${response.toString()}");

      return Right(EventModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Create Event Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Create Event Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, EventModel>> getEvent({required String id}) async {
    try {
      final response = await supabaseClient
          .from('Event')
          .select()
          .eq('id', id)
          .single();

      return Right(EventModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Get Event Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Event Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<EventModel>>> getEventsByGroup({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from('Event')
          .select()
          .eq('groupId', groupId)
          .order('date', ascending: true);

      final events = response.map((data) => EventModel.fromMap(data)).toList();

      return Right(events);
    } on PostgrestException catch (e) {
      Log.error("Get Events by Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Events by Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, EventModel>> updateEvent({
    required EventModel event,
  }) async {
    try {
      final response = await supabaseClient
          .from('Event')
          .update(event.toMap())
          .eq('id', event.id ?? "")
          .select()
          .single();

      Log.info("Update Event Response: ${response.toString()}");

      return Right(EventModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Update Event Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Update Event Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteEvent({required String id}) async {
    try {
      await supabaseClient.from('Event').delete().eq('id', id);

      Log.info("Delete Event Success for ID: $id");

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Delete Event Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Delete Event Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }
}
