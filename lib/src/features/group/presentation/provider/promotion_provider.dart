import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/datasource/promotion_datasource.dart';
import 'package:larnity/src/features/group/data/models/promotion_model.dart';

final promotionProvider = NotifierProvider<PromotionNotifier, PromotionState>(
  PromotionNotifier.new,
);

class PromotionNotifier extends Notifier<PromotionState> {
  @override
  PromotionState build() {
    return PromotionState(state: AsyncState.initial);
  }

  Future<void> createPromotion({
    required PromotionModel promotion,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final dataSource = ref.read(promotionDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.createPromotion(promotion: promotion);

    response.fold(
      (failure) {
        state = state.copyWith(
          state: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (promotion) {
        final List<PromotionModel> updatedPromotions = [
          ...?state.promotions,
          promotion,
        ];
        state = state.copyWith(
          state: AsyncState.success,
          promotion: promotion,
          promotions: updatedPromotions,
        );
        successCallBack?.call();
      },
    );
  }

  Future<void> getPromotionsByGroup({required String groupId}) async {
    final dataSource = ref.read(promotionDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.getPromotionsByGroup(groupId: groupId);

    response.fold(
      (failure) => state = state.copyWith(
        state: AsyncState.failure,
        error: failure.message,
      ),
      (promotions) => state = state.copyWith(
        state: AsyncState.success,
        promotions: promotions,
      ),
    );
  }

  Future<void> updatePromotionStatus({
    required String id,
    required bool isActive,
  }) async {
    final dataSource = ref.read(promotionDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.updatePromotionStatus(
      id: id,
      isActive: isActive,
    );

    response.fold(
      (failure) => state = state.copyWith(
        state: AsyncState.failure,
        error: failure.message,
      ),
      (promotion) {
        final updatedPromotions = state.promotions?.map((p) {
          return p.id == promotion.id ? promotion : p;
        }).toList();

        state = state.copyWith(
          state: AsyncState.success,
          promotion: promotion,
          promotions: updatedPromotions,
        );
      },
    );
  }

  Future<void> deletePromotion({
    required String id,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final dataSource = ref.read(promotionDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.deletePromotion(id: id);

    response.fold(
      (failure) {
        state = state.copyWith(
          state: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (_) {
        final updatedPromotions = state.promotions?.where((p) {
          return p.id != id;
        }).toList();

        state = state.copyWith(
          state: AsyncState.success,
          promotions: updatedPromotions,
        );
        successCallBack?.call();
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = PromotionState(state: AsyncState.initial);
  }
}

class PromotionState {
  final AsyncState? state;
  final String? error;
  final PromotionModel? promotion;
  final List<PromotionModel>? promotions;

  PromotionState({this.state, this.error, this.promotion, this.promotions});

  PromotionState copyWith({
    AsyncState? state,
    String? error,
    PromotionModel? promotion,
    List<PromotionModel>? promotions,
  }) {
    return PromotionState(
      state: state ?? this.state,
      error: error ?? this.error,
      promotion: promotion ?? this.promotion,
      promotions: promotions ?? this.promotions,
    );
  }

  bool get isLoading => state == AsyncState.loading;
  bool get isSuccess => state == AsyncState.success;
  bool get isFailure => state == AsyncState.failure;
}
