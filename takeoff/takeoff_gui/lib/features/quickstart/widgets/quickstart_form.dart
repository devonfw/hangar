import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/quickstart/controllers/quickstart_controller.dart';
import 'package:takeoff_gui/features/quickstart/utils/apps.dart';
import 'package:takeoff_gui/features/quickstart/widgets/viplane_form.dart';
import 'package:takeoff_gui/features/quickstart/widgets/wayat_form.dart';

class QuickstartForm extends StatelessWidget {
  final QuickstartController controller = GetIt.I.get<QuickstartController>();
  QuickstartForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      switch (controller.app) {
        case Apps.wayat:
          return WayatForm();
        case Apps.viplane:
          return VipLaneForm();
      }
    });
  }
}
