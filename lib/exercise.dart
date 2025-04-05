class Exercise {
  final String name;
  final String type; // Push, Pull, Legs, Core, Cardio
  final List<ExerciseSet> sets;
  final bool isTimedActivity; // For Cardio
  final String targetMuscle;  // <-- New field to track which muscle is targeted

  Exercise({
    required this.name,
    required this.type,
    required this.sets,
    this.isTimedActivity = false,
    this.targetMuscle = '',  // Provide a default so it's never null
  });

  @override
  String toString() {
    // Create a string for all sets
    return '$name | ';
  }
}

class ExerciseSet {
  final int setNumber;
  int? reps;
  int? weight;
  final double? time;
  final double? distance;

  ExerciseSet({
    required this.setNumber,
    this.reps,
    this.weight,
    this.time,
    this.distance,
  });

  @override
  String toString() {
    if (time != null && distance != null) {
      return 'Set($setNumber: ${time?.toStringAsFixed(0)}s, ${distance?.toStringAsFixed(1)}km)';
    } else {
      return 'Set($setNumber: $reps reps, $weight weight)';
    }
  }
}
