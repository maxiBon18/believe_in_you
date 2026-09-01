import 'package:believe_in_you/core/presentation/ux/theme/app_theme.dart';
import 'package:believe_in_you/core/shared/constants/app_strings.dart';
import 'package:material_ui/material_ui.dart';

class BelieveInYouApp extends StatelessWidget {
  const BelieveInYouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: lightAppTheme,
      darkTheme: darkAppTheme,
      highContrastTheme: lightAppTheme,
      highContrastDarkTheme: darkAppTheme,
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      showSemanticsDebugger: false,
      home: const Placeholder(),
    );
  }
}
