import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/core/ui/widgets/phone_number_input.dart';
import 'package:larnity/src/features/group/data/datasource/country_list_with_code.dart';
import 'package:larnity/src/features/group/data/models/country_model.dart';
import 'package:larnity/src/features/group/data/models/supporter_model.dart';
import 'package:larnity/src/features/group/presentation/provider/supporter_provider.dart';

class NewSupporter extends ConsumerStatefulWidget {
  final String groupId;

  const NewSupporter({Key? key, required this.groupId}) : super(key: key);

  @override
  ConsumerState<NewSupporter> createState() => _NewSupporterState();
}

class _NewSupporterState extends ConsumerState<NewSupporter> {
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _bookingLinkController = TextEditingController();

  String? _selectedUserId;

  @override
  void dispose() {
    _phoneController.dispose();
    _whatsappController.dispose();
    _bookingLinkController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateSupporter() async {
    if (_phoneController.text.isEmpty ||
        _whatsappController.text.isEmpty ||
        _bookingLinkController.text.isEmpty ||
        _selectedUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final supporter = SupporterModel(
      groupId: widget.groupId,
      userId: _selectedUserId!,
      phoneNumber: _phoneController.text,
      whatsappNumber: _whatsappController.text,
      link: _bookingLinkController.text,
    );

    final success = await ref
        .read(supporterProvider)
        .createSupporter(supporter);

    if (success && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supporter added successfully')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: ${ref.read(supporterProvider).errorMessage}'),
        ),
      );
    }
  }

  // Fetch group members
  Future<List<AppDropdownItem>> _fetchGroupMembers() async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      // Fetch members from your Members table based on groupId
      final response = await supabase
          .from('Members')
          .select('userId, Users(id, name, email)')
          .eq('groupId', widget.groupId);

      return response.map<AppDropdownItem>((member) {
        final userData = member['Users'] as Map<String, dynamic>?;
        final userId = userData?['id'] as String? ?? '';
        final name = userData?['name'] as String? ?? 'Unknown';
        final email = userData?['email'] as String? ?? '';

        return AppDropdownItem(value: userId, label: '$name ($email)');
      }).toList();
    } catch (e) {
      // Fallback to current user if fetch fails
      final currentUserId = ref
          .read(supabaseClientProvider)
          .auth
          .currentUser
          ?.id;
      if (currentUserId != null) {
        return [AppDropdownItem(value: currentUserId, label: 'Current User')];
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(supporterProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.addNewSupporter,
                style: AppTextStyles.headline4(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  AppStrings.addNewSupporterDesc,
                  style: AppTextStyles.overLine(color: AppColors.skyBlue),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          AppSizes.lg.ph,

          AppSizes.xs.ph,
          Text(AppStrings.selectMember, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,

          FutureBuilder<List<AppDropdownItem>>(
            future: _fetchGroupMembers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.all(AppSizes.xs),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.xs),
                  ),
                  child: const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              final members = snapshot.data ?? [];

              // If no members found, use current user as fallback
              if (members.isEmpty) {
                final currentUserId = ref
                    .read(supabaseClientProvider)
                    .auth
                    .currentUser
                    ?.id;
                if (currentUserId != null && _selectedUserId == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _selectedUserId = currentUserId;
                    });
                  });
                }

                return Container(
                  padding: const EdgeInsets.all(AppSizes.xs),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.xs),
                  ),
                  child: Text(
                    'Current User (auto-selected)',
                    style: AppTextStyles.bodyText2(color: AppColors.white),
                  ),
                );
              }

              return AppDropdown(
                button: Container(
                  padding: const EdgeInsets.all(AppSizes.xs),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.xs),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedUserId == null
                              ? AppStrings.searchMemberByEmail
                              : members
                                        .firstWhere(
                                          (m) => m.value == _selectedUserId,
                                          orElse: () => members.first,
                                        )
                                        .label ??
                                    'Member Selected',
                          style: AppTextStyles.bodyText2(
                            color: AppColors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
                onItemSelected: (value) {
                  setState(() {
                    _selectedUserId = value;
                  });
                },
                items: members,
              );
            },
          ),
          AppSizes.xs.ph,

          Text(
            AppStrings.phoneNumber ?? 'Phone Number',
            style: AppTextStyles.overLine(),
          ),
          AppSizes.xxxs.ph,
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBgContainer,
              hintText: "00000-00000",
              hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: BorderSide(
                  color: AppColors.skyBlue.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: const BorderSide(color: AppColors.skyBlue),
              ),
            ),
          ),

          AppSizes.xs.ph,
          Text(AppStrings.whatsappNumber, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          TextFormField(
            controller: _whatsappController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBgContainer,
              hintText: AppStrings.whatsappNumberHint,
              hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: BorderSide(
                  color: AppColors.skyBlue.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: const BorderSide(color: AppColors.skyBlue),
              ),
            ),
          ),

          AppSizes.xs.ph,
          Text(AppStrings.booking, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          TextFormField(
            controller: _bookingLinkController,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBgContainer,
              hintText: AppStrings.enterAppointmentBooking,
              hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: BorderSide(
                  color: AppColors.skyBlue.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: const BorderSide(color: AppColors.skyBlue),
              ),
            ),
          ),
          AppSizes.xs.ph,
          AppButton(
            onPressed: isLoading ? null : _handleCreateSupporter,
            label: isLoading ? "Creating..." : AppStrings.create,
            labelStyle: AppTextStyles.button(color: AppColors.black),
            bgColor: AppColors.primaryOrange,
          ),
        ],
      ),
    );
  }
}
