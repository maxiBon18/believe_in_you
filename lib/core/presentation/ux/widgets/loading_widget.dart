import 'package:believe_in_you/core/presentation/ux/theme/barrel_theme.dart';
import 'package:believe_in_you/core/shared/constants/app_strings.dart';
import 'package:material_ui/material_ui.dart';

class BelieveInYouLoadingWidget extends StatelessWidget {
  const BelieveInYouLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      spacing: AppSpacing.s16,
      children: <Widget>[
        SizedBox(
          height: AppSizes.loadingSize,
          width: AppSizes.loadingSize,
          child: CircularProgressIndicator(color: AppColors.onBrand),
        ),
        Text(AppStrings.loading, style: AppBodyText.buttonLabel),
      ],
    );
  }
}
