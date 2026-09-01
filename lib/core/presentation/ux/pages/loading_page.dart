import 'package:believe_in_you/core/presentation/ux/theme/barrel_theme.dart';
import 'package:believe_in_you/core/presentation/ux/widgets/loading_widget.dart';
import 'package:material_ui/material_ui.dart';

/// Full-screen overlay that blocks all interaction while an operation is in progress.
///
/// Prevents the user from navigating away via [PopScope] and tints the background
/// using the active theme's on-surface colour at 70 % opacity.
class BelieveInYouOverlayLoadingWidget extends StatelessWidget {
  const BelieveInYouOverlayLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const PopScope(
      canPop: false,
      child: Material(
        type: MaterialType.canvas,
        color: AppColors.loadingBackground,
        child: Center(child: BelieveInYouLoadingWidget()),
      ),
    );
  }
}
