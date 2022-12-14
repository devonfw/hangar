import 'dart:convert';

import 'package:takeoff_lib/src/domain/hangar_scripts/quickstart/steps_output/quickstart_step.dart';

class QuickstartStepsOutput {
  List<QuickstartStep> steps;

  QuickstartStepsOutput({required this.steps});

  factory QuickstartStepsOutput.fromMap(Map<String, dynamic> map) {
    return QuickstartStepsOutput(
        steps: (map["steps"]! as List<dynamic>)
            .map((e) => QuickstartStep.fromMap(e))
            .toList());
  }
}
