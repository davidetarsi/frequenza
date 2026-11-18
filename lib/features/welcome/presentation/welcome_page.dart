import 'package:flutter/material.dart';

import '../../../ui/theme/app_motion.dart';
import '../../radio/presentation/radio_page.dart';
import 'welcome_tour.dart';

/// The first launch uses the real radio, with a guide inside its display.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, this.appName = 'Frequenza'});
  final String appName;

  @override
  Widget build(BuildContext context) => WelcomeTour(
    builder: (targets) => HeroMode(
      enabled: AppMotion.enabled(context),
      child: RadioPage(
        appName: appName,
        tourTargets: targets,
        settingsAction: const IconButton(
          onPressed: null,
          icon: Icon(Icons.settings_outlined),
        ),
      ),
    ),
  );
}
