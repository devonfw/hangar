import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Take Off';

  @override
  String get gc => 'Google Cloud';

  @override
  String get az => 'Azure';

  @override
  String get aws => 'AWS';

  @override
  String get createProject => 'Create a project';

  @override
  String get createButton => 'Create';

  @override
  String get closeButton => 'Close';

  @override
  String get projectResources => 'project resources';

  @override
  String get openIdeButton => 'Open IDE';

  @override
  String get openPipelineButton => 'Open Pipeline';

  @override
  String get openFeRepo => 'Open FE Repo';

  @override
  String get openBeRepo => 'Open BE Repo';
}
