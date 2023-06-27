import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/quickstart/controllers/quickstart_controller.dart';
import 'package:takeoff_lib/takeoff_lib.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VipLaneForm extends StatelessWidget {
  final QuickstartController controller = GetIt.I.get<QuickstartController>();
  final TakeOffFacade facade = GetIt.I.get<TakeOffFacade>();
  VipLaneForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
      AppLocalizations.of(context)!.comingSoonButton,
      style: const TextStyle(fontSize: 20),
    ));
  }
}
