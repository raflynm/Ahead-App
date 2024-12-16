import 'package:flutter/material.dart';
import '../models/plan_model.dart';

class PlanCard extends StatelessWidget {
  final Plan plan;

  PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(plan.name),
        subtitle: Text("${plan.date.toLocal()} | ${plan.startTime} - ${plan.endTime}"),
        trailing: Text(plan.location),
      ),
    );
  }
}
