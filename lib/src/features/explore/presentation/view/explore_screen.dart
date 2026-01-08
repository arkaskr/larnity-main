import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/features/explore/presentation/widgets/explore_groups_widget.dart';
import 'package:larnity/src/features/explore/presentation/widgets/footer_widget.dart';
import 'package:larnity/src/features/explore/presentation/widgets/group_card.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  ExploreScreen({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  static const int _itemsPerPage = 3;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);
    final currentUserId = ref.watch(authProvider).user?.id;

    final searchText = _searchController.text.toLowerCase();
    List<GroupModel> filteredGroups = groupState.groups ?? [];

    // Filter out user's own groups
    if (currentUserId != null) {
      filteredGroups = filteredGroups.where((group) {
        return group.userId != currentUserId;
      }).toList();
    }

    // Apply search filter
    if (searchText.isNotEmpty) {
      filteredGroups = filteredGroups.where((group) {
        return group.name.toLowerCase().contains(searchText) ||
            (group.description ?? '').toLowerCase().contains(searchText) ||
            (group.category ?? '').toLowerCase().contains(searchText);
      }).toList();
    }

    // Apply category filter
    if (groupState.selectedCategory != null &&
        groupState.selectedCategory!.name != 'All') {
      final selectedCategory = groupState.selectedCategory!.name.toLowerCase();
      filteredGroups = filteredGroups.where((group) {
        return (group.category ?? '').toLowerCase().contains(selectedCategory);
      }).toList();
    }

    /// Pagination logic
    final int totalPages = (filteredGroups.length / _itemsPerPage).ceil();

    if (_currentPage > totalPages && totalPages != 0) {
      _currentPage = totalPages;
    }

    final int startIndex = (_currentPage - 1) * _itemsPerPage;
    final int endIndex = startIndex + _itemsPerPage;

    final List<GroupModel> paginatedGroups = filteredGroups.sublist(
      startIndex,
      endIndex > filteredGroups.length ? filteredGroups.length : endIndex,
    );

    return Scaffold(
      key: widget.scaffoldKey,
      backgroundColor: AppColors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [AppColors.darkBrown.withOpacity(0.3), AppColors.black],
            center: Alignment.topCenter,
            radius: 1.2,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            /// HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.xs,
                  vertical: AppSizes.xs,
                ),
                child: ExploreGroupsWidget(searchController: _searchController),
              ),
            ),

            /// CONTENT STATES
            if (groupState.fetchState == AsyncState.loading)
              const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (groupState.fetchState == AsyncState.failure)
              const SliverToBoxAdapter(
                child: Center(child: Text('Failed to load groups')),
              )
            else if (filteredGroups.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      const Text('No groups found'),
                      AppSizes.xs.ph,
                      Text(
                        groupState.selectedCategory != null
                            ? 'No groups in ${groupState.selectedCategory!.name}'
                            : 'No groups match your search',
                        style: AppTextStyles.caption2(
                          color: AppColors.creamWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              /// GROUP LIST
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final group = paginatedGroups[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.xs,
                      vertical: AppSizes.xxs,
                    ),
                    child: GroupCard(group: group),
                  );
                }, childCount: paginatedGroups.length),
              ),

            /// PAGINATION
            if (totalPages > 1)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// Previous
                      GestureDetector(
                        onTap: _currentPage > 1
                            ? () {
                                setState(() {
                                  _currentPage--;
                                });
                              }
                            : null,
                        child: Opacity(
                          opacity: _currentPage > 1 ? 1 : 0.4,
                          child: _pageButton('Previous'),
                        ),
                      ),

                      AppSizes.xs.pw,

                      /// Page Numbers
                      ...List.generate(totalPages, (index) {
                        final page = index + 1;
                        final isActive = page == _currentPage;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentPage = page;
                              });
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.white
                                    : AppColors.black,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                page.toString(),
                                style: TextStyle(
                                  color: isActive
                                      ? AppColors.black
                                      : AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                      AppSizes.xs.pw,

                      /// Next
                      GestureDetector(
                        onTap: _currentPage < totalPages
                            ? () {
                                setState(() {
                                  _currentPage++;
                                });
                              }
                            : null,
                        child: Opacity(
                          opacity: _currentPage < totalPages ? 1 : 0.4,
                          child: _pageButton('Next'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            /// FOOTER
            const SliverToBoxAdapter(child: FooterWidget()),
          ],
        ),
      ),
    );
  }

  Widget _pageButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withOpacity(0.2)),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.white)),
    );
  }
}
