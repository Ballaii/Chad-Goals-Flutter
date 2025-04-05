import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'exercise.dart';
import 'dart:async';
import 'timer_handler.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final TimerHandler _timerHandler = TimerHandler();

  bool _showSession = false;
  bool _showAddExercise = false;
  bool _isTimedActivity = false;

  // --------------------------------------------------------
  //  NEW: Muscle groups for each filter
  // --------------------------------------------------------
  final Map<String, List<String>> _muscleGroups = {
    'Push': ['Upper Chest', 'Middle Chest', 'Lower Chest', 'Front Delt', 'Side Delt', 'Rear Delt', 'Triceps(Medial head)', 'Triceps(Lateral head)', 'Triceps(Long head)'],
    'Pull': ['Lats','Upper back', 'Traps','Lower back','Teres majors','Biceps(Short Head)', 'Biceps(Long Head)','Brachialis','Forearms'],
    'Legs': ['Quads', 'Hamstrings', 'Calves', 'Glutes', 'Adductors'],
    'Core': ['Upper Abs','Lower Abs','Obliques'],
    'Cardio': ['Running', 'Cycling', 'Walking', 'Stairs', 'Rowing']
  };
  String? _selectedMuscle;

  @override
  void initState() {
    super.initState();
    // Set default selected muscle based on the initial filter.
    _selectedMuscle = _muscleGroups['Push']?.first;
    // Rebuild the UI whenever TimerHandler notifies changes.
    _timerHandler.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timerHandler.dispose();
    super.dispose();
  }

  // Track all exercises in this workout session
  final List<Exercise> _exercises = [];

  // For the "Add Exercise" flow
  final TextEditingController _exerciseNameController = TextEditingController();
  String _selectedFilter = 'Push'; // Default filter/type

  // Simple timer placeholders
  String timerDisplay = '00:00:00';
  bool isTimerRunning = false;

  String email = FirebaseAuth.instance.currentUser!.email!.toString();
  double volumeScore = 0.0;


  void updateVolumeScore() {
    // Reset the volume score first to avoid accumulation
    volumeScore = 0.0;

    for (final exercise in _exercises) {
      // If you want to exclude cardio exercises (which might use time/distance instead)
      if (!(exercise.type == 'Cardio' && exercise.isTimedActivity)) {
        for (final set in exercise.sets) {
          // Multiply reps by weight for each set and sum it up
          volumeScore += set.reps! * set.weight!;
        }
      }
    }
  }

  Future<void> addWorkoutDataToFirestore() async {
    try {
      // First update the volume score.
      updateVolumeScore();

      // Only proceed if there are exercises to save.
      if (_exercises.isEmpty) {
        //print('No exercises to save');
        return;
      }

      final exercisesString =
      _exercises.map((exercise) => exercise.toString()).join('\n');
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        //print('No user logged in');
        return;
      }

      final workoutData = {
        'email': email,
        'exercises': exercisesString,
        'time': _timerHandler.formattedTime,
        'volume_score': volumeScore.toString(),
        'timestamp': FieldValue.serverTimestamp(), // For sorting by time.
      };

      // Using the add() method will create a unique document ID for each new workout.
      await FirebaseFirestore.instance.
      collection('workouts').
      add(workoutData);

      //print('Workout saved successfully');
    } catch (e) {
      //print('Error saving workout: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // Main Content
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF41318D),
                  Colors.black,
                ],
                stops: const [0.29, 1.0],
              ),
            ),
            child: _showSession
                ? _buildSessionView()
                : _showAddExercise
                ? _buildAddExerciseView()
                : _buildInitialView(),
          ),

          // Cancel (x) icon: Only show during an active session or while adding an exercise.
          if (_showSession || _showAddExercise)
            Positioned(
              top: 40, // Adjust as needed for your design
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () {
                  // Stop and reset the timer, clear any session data,
                  // then return to the initial workout page.
                  _timerHandler.stopTimer();
                  _timerHandler.resetTimer();
                  _exercises.clear();
                  setState(() {
                    _showSession = false;
                    _showAddExercise = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  //  INITIAL VIEW
  // --------------------------------------------------------
  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          const Text(
            'Workout',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFF303F9F),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 40),
                onPressed: () {
                  setState(() {
                    _showSession = true;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Tap the '+' to start a new workout",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  //  SESSION VIEW
  // --------------------------------------------------------
  Widget _buildSessionView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 360.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text(
              'Session',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Timer display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                _timerHandler.formattedTime,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Timer controls
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton('Stop timer', Colors.red, () {
                    _timerHandler.stopTimer();
                  }),
                  _buildControlButton('End session', Colors.deepOrange, () {
                    _timerHandler.stopTimer();
                    setState(() {
                      _showSession = false;
                    });
                    addWorkoutDataToFirestore();
                  }),
                  _buildControlButton('Start timer', Colors.green, () {
                    _timerHandler.startTimer();
                  }),
                ],
              ),
            ),
            // Add exercise button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showAddExercise = true;
                    _showSession = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Add new exercise',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Dynamically built exercise list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  for (int i = 0; i < _exercises.length; i++)
                    _buildExerciseCard(_exercises[i]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------
  //  EXERCISE CARD
  // --------------------------------------------------------
  Widget _buildExerciseCard(Exercise exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF303F9F).withValues(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row + "New set" button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Display exercise name, type, and target muscle (if provided)
                Text(
                  '${exercise.name} (${exercise.type}'
                      '${(exercise.targetMuscle.isNotEmpty) ? " -\n${exercise.targetMuscle}" : ""}'
                      '${(exercise.type == 'Cardio' && exercise.isTimedActivity) ? ', Timed' : ''})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      final newSetIndex = exercise.sets.length + 1;
                      if (exercise.type == 'Cardio' && exercise.isTimedActivity) {
                        exercise.sets.add(
                          ExerciseSet(
                            setNumber: newSetIndex,
                            time: 0.0,
                            distance: 0.0,
                          ),
                        );
                      } else {
                        exercise.sets.add(
                          ExerciseSet(
                            setNumber: newSetIndex,
                            reps: 0,
                            weight: 0,
                          ),
                        );
                      }
                    });
                  },
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  label: const Text('New set',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          // Headers based on exercise type
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: (exercise.type == 'Cardio' && exercise.isTimedActivity)
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text(
                  'Time',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Distance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text(
                  'Set #',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Reps',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Weight',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Render each set row based on exercise type
          for (final set in exercise.sets)
            (exercise.type == 'Cardio' && exercise.isTimedActivity)
                ? _buildCardioSetRow(set)
                : _buildSetRow(set),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCardioSetRow(ExerciseSet set) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            width: 60,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0).withValues(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${set.time?.toStringAsFixed(0) ?? "0"}s',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Container(
            width: 60,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0).withValues(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${set.distance?.toStringAsFixed(1) ?? "0.0"}km',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(ExerciseSet set) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Display Set #
          Container(
            width: 60,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0).withValues(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${set.setNumber}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          // Editable TextField for Reps
          SizedBox(
            width: 60,
            height: 40,
            child: TextFormField(
              initialValue: set.reps?.toString() ?? '0',
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFF9C27B0).withValues(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  set.reps = int.tryParse(value) ?? 0;
                });
                updateVolumeScore();
              },
            ),
          ),
          // Editable TextField for Weight
          SizedBox(
            width: 60,
            height: 40,
            child: TextFormField(
              initialValue: set.weight?.toString() ?? '0',
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFF9C27B0).withValues(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  set.weight = int.tryParse(value) ?? 0;
                });
                updateVolumeScore();
              },
            ),
          ),
        ],
      ),
    );
  }


  // --------------------------------------------------------
  //  ADD EXERCISE VIEW (Updated with Muscle Dropdown)
  // --------------------------------------------------------
  Widget _buildAddExerciseView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text(
              'Add Exercise',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Timer display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                _timerHandler.formattedTime,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Timer controls
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton('Stop timer', Colors.red, () {
                    _timerHandler.stopTimer();
                  }),
                  _buildControlButton('End session', Colors.red, () async {
    if (_exercises.isNotEmpty) {
       showDialog(
       context: context,
       barrierDismissible: false,
       builder: (BuildContext context) {
       return const Center(
       child: CircularProgressIndicator(),
       );
      }
    );
       Future.delayed(const Duration(seconds: 1), () {
       Navigator.of(context).pop();
       }
      );
    }
    await addWorkoutDataToFirestore();
    Navigator.of(context).pop();

                    _timerHandler.stopTimer();
                    _timerHandler.resetTimer();
                    _exercises.clear();
                    setState(() {
                      _showSession = false;
                    });
                  }),
                  _buildControlButton('Start timer', Colors.green, () {
                    _timerHandler.startTimer();
                  }),
                ],
              ),
            ),
            // --------------------------------------------------------
            //  Filter section with Muscle Dropdown (replacing search bar)
            // --------------------------------------------------------
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF303F9F).withValues(),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter your workout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFilterButton('Push'),
                        _buildFilterButton('Pull'),
                        _buildFilterButton('Legs'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Spacer(),
                        _buildFilterButton('Core'),
                        const SizedBox(width: 36),
                        _buildFilterButton('Cardio'),
                        const Spacer(),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: DropdownButton<String>(
                        value: _selectedMuscle,
                        dropdownColor: Colors.grey.shade800,
                        enableFeedback: true,
                        style: const TextStyle(color: Colors.white),
                        items: (_muscleGroups[_selectedFilter] ?? []).map((muscle) {
                          return DropdownMenuItem<String>(
                            value: muscle,
                            child: Text(muscle),

                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMuscle = value;
                          });
                        },
                        hint: const Text(
                          'Select target muscle',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Add Exercise:',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _exerciseNameController,
                      decoration: InputDecoration(
                        hintText: 'Exercise name',
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey.shade800,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final newName = _exerciseNameController.text.trim();
                        if (newName.isNotEmpty) {
                          setState(() {
                            // Make sure your Exercise model includes a targetMuscle property.
                            _exercises.add(
                              Exercise(
                                name: newName,
                                type: _selectedFilter,
                                targetMuscle: _selectedMuscle ?? '',
                                isTimedActivity: _selectedFilter == 'Cardio' ? _isTimedActivity : false,
                                sets: [],
                              ),
                            );
                            _exerciseNameController.clear();
                            _showAddExercise = false;
                            _showSession = true;
                            _isTimedActivity = false; // Reset toggle if needed
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter an exercise name'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Add Exercise',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------
  //  HELPER WIDGETS
  // --------------------------------------------------------
  Widget _buildControlButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Each filter button updates `_selectedFilter` and sets a default muscle for that group.
  Widget _buildFilterButton(String text) {
    final bool isSelected = (_selectedFilter == text);
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedFilter = text;
          _selectedMuscle = _muscleGroups[_selectedFilter]?.first;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
        isSelected ? const Color(0xFF9C27B0) : const Color(0xFF2A2A5A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
