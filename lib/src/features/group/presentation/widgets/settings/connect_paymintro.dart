import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_assets.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/features/group/data/models/paymintro_creds_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:larnity/src/core/utils/async_states.dart';

class ConnectPaymintro extends ConsumerStatefulWidget {
  const ConnectPaymintro({Key? key}) : super(key: key);

  @override
  ConsumerState<ConnectPaymintro> createState() => _ConnectPaymintroState();
}

class _ConnectPaymintroState extends ConsumerState<ConnectPaymintro> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController clientIdController = TextEditingController();
  final TextEditingController secretIdController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    clientIdController.dispose();
    secretIdController.dispose();
    super.dispose();
  }

  void _saveCreds() async {
    final clientId = clientIdController.text.trim();
    final secretId = secretIdController.text.trim();

    if (clientId.isEmpty || secretId.isEmpty) {
      // Basic validation handled by toast in provider if error, or just return here
      return;
    }

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    final creds = PaymintroCredsModel(
      paymintroClientId: clientId,
      paymintroSecretId: secretId,
      userId: currentUser.id,
    );

    final success =
        await ref.read(groupProvider.notifier).savePaymintroCreds(creds);

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);
    final isLoading = groupState.updateState == AsyncState.loading;

    return Container(
      width: 400,
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppSizes.sm),
        border: Border.all(color: AppColors.darkBgContainer),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(Icons.close, color: AppColors.white),
                ),
              ],
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.xs),
                    child: Image.asset(
                      AppAssets.images.logoColor,
                      height: 40,
                      width: 40,
                      errorBuilder: (c, e, s) => Container(
                          height: 40, width: 40, color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
                    child: Icon(Icons.compare_arrows, color: Colors.grey),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.xs),
                    child: Image.asset(
                      AppAssets.images.paymintro,
                      height: 40,
                      width: 40,
                      errorBuilder: (c, e, s) => Container(
                        height: 40,
                        width: 40,
                        color: Colors.white,
                        child: Icon(Icons.payment, color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSizes.md.ph,
            Center(
              child: Text(
                "Connect PayMintro Account",
                style: AppTextStyles.headline3(color: AppColors.white),
              ),
            ),
            AppSizes.xs.ph,
            Center(
              child: Text(
                "PayMintro is the fastest and easiest way to integrate payments and financial services into your software platform or marketplace.",
                textAlign: TextAlign.center,
                style: AppTextStyles.caption(color: Colors.grey),
              ),
            ),
            AppSizes.md.ph,
            Divider(color: AppColors.darkBgContainer),
            AppSizes.md.ph,
            _buildTextField("Phone Number", phoneController, "+91 |",
                isPhone: true),
            AppSizes.sm.ph,
            _buildTextField("Client Id", clientIdController, "Enter your client id"),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: AppSizes.sm),
              child: Text("Client id is required",
                  style: AppTextStyles.caption2(color: AppColors.primaryOrange)),
            ),
            _buildTextField(
                "Secret Id", secretIdController, "Enter your secret id"),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: AppSizes.md),
              child: Text("Secret id is required",
                  style: AppTextStyles.caption2(color: AppColors.primaryOrange)),
            ),
            AppButton(
              isExpanded: true,
              onPressed: () {
                  if(!isLoading) _saveCreds();
              },
              label: "Connect Integration",
              isLoading: isLoading,
              labelStyle: AppTextStyles.button(color: AppColors.black),
              bgColor: AppColors.primaryOrange,
              radius: AppSizes.xxxs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint,
      {bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyText2(color: AppColors.white)),
        AppSizes.xs.ph,
        Row(
          children: [
            if (isPhone)
              Container(
                margin: EdgeInsets.only(right: AppSizes.xs),
                padding: EdgeInsets.symmetric(horizontal: AppSizes.xs),
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  border: Border.all(color: AppColors.darkBgContainer),
                ),
                child: Center(
                  child: Row(
                    children: [
                      Icon(Icons.flag, color: Colors.orange, size: 20),
                      Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: TextFormField(
                controller: controller,
                style: AppTextStyles.bodyText2(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTextStyles.caption(color: Colors.grey),
                  filled: true,
                  fillColor: AppColors.black,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(color: AppColors.darkBgContainer),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(color: AppColors.darkBgContainer),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(color: AppColors.primaryOrange),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
