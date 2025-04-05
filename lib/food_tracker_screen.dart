import 'package:flutter/material.dart';
import 'api_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodTrackerPage extends StatefulWidget {
  const FoodTrackerPage({super.key});

  @override
  State<FoodTrackerPage> createState() => _FoodTrackerPageState();
}

class _FoodTrackerPageState extends State<FoodTrackerPage> {
  double _calorieGoal = 2000;
  final TextEditingController _goalController = TextEditingController();

  List<FoodItem> _mealHistory = [];
  double _totalProtein = 0;
  double _totalCarbs = 0;
  double _totalFat = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _goalController.text = _calorieGoal.toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });

  }

  Future<void> _loadSavedData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    await FirebaseFirestore.instance
        .collection('calorie')
        .doc(user.uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _totalProtein = data['protein'] ?? 0.0;
          _totalCarbs = data['carbs'] ?? 0.0;
          _totalFat = data['fats'] ?? 0.0;
          _mealHistory = (data['meals'] as List<dynamic>)
              .map((item) => FoodItem.fromJson(item))
              .toList();
        });
      }
    });

  }

  Future<void> _saveData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);


        double totalCalories = (_totalCarbs * 4) + (_totalProtein * 4) +
            (_totalFat * 9);
        await FirebaseFirestore.instance.
        collection('calorie')
            .doc(user.uid)
            .set({
          'email': user.email,
          'calories': totalCalories,
          'protein': _totalProtein,
          'fats': _totalFat,
          'carbs': _totalCarbs,
          'meals': _mealHistory.map((item) => item.toJson()).toList(),
          'date': today
        });

      await prefs.setString('lastTrackedDate', today.toIso8601String());
      await _saveData();
      if (mounted) setState(() {});

  }

  // Modify existing methods to call _saveData()
  void _handleFoodSelected(FoodItem item) {
    Navigator.pop(context);
    setState(() => _mealHistory.add(item));
    _updateTotals();
    _saveData(); // Add this
  }

void showAlerbox(){
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Alert'),
        content: Text('Start new day?\n'
            'Upon starting, current data will be erased.'),
        actions: [
          TextButton(
            child: Text('Yes'),
            onPressed: () {
              //_saveDailyData();
              eraseDailyData();
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );}

  Future<void> eraseDailyData() async{
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;
    await FirebaseFirestore.instance
        .collection('calorie')
        .doc(user.uid)
        .delete()
    .then((_) {
      setState(() {
        _mealHistory.clear();
        _totalProtein = 0;
        _totalCarbs = 0;
        _totalFat = 0;
      });
    }).catchError((error) {
      //print('Error deleting document: $error');
    });
    setState(() {
      _totalProtein = 0;
      _totalCarbs = 0;
      _totalFat = 0;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastTrackedDate', '');
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
    _saveData();
  }

  void _updateTotals() {
    _totalProtein = 0;
    _totalCarbs = 0;
    _totalFat = 0;

    for (var item in _mealHistory) {
      _totalProtein += item.protein;
      _totalCarbs += item.carbs;
      _totalFat += item.fat;
    }
    setState(() {});
  }

  void _showSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.deepPurple.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _SearchPanel(
          onFoodSelected: _handleFoodSelected,
        );
      },
    );
  }

  void _showGoalDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Set Calorie Goal'),
          content: TextField(
            controller: _goalController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Goal in calories'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _calorieGoal = double.tryParse(_goalController.text) ?? 2000;
                });
                _saveData(); // Add this
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCircularCalorieGoal() {
    final double totalCals =
        (_totalCarbs * 4) + (_totalProtein * 4) + (_totalFat * 9);

    double progress = totalCals / _calorieGoal;
    if (progress > 1.0) progress = 1.0;

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: Colors.white24,
              color: Colors.greenAccent,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${totalCals.toStringAsFixed(0)} / ${_calorieGoal.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                    'P: ${_totalProtein.toStringAsFixed(0)}g\n'
                    'C: ${_totalCarbs.toStringAsFixed(0)}g\n'
                    'F: ${_totalFat.toStringAsFixed(0)}g',
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealHistory() {
    if (_mealHistory.isEmpty) {
      return const Text(
        'No meals logged yet.',
        style: TextStyle(color: Colors.white70),
      );
    }

    // Wrap items to the next line when out of horizontal space.
    return SingleChildScrollView(
      child: Wrap(
        spacing: 8.0,      // Horizontal spacing between items
        runSpacing: 8.0,   // Vertical spacing between lines
        children: _mealHistory.map((meal) {
          return Container(
            width: 120, // Fixed width for each item
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade600,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              meal.name.toUpperCase(),
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade800,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF41318D),
                    Colors.black,
                  ],
                  stops: [0.15, 1.0],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      onTap: _showSearchSheet,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade600,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            SizedBox(width: 10),
                            Icon(Icons.search, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Search for meal',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(child: _buildCircularCalorieGoal()),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _showGoalDialog,
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        'Edit Calorie Goal',
                        style: TextStyle(color: Colors.cyanAccent),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: showAlerbox,
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'New day',
                        style: TextStyle(color: Colors.cyanAccent),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _buildMealHistory(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The bottom sheet for searching foods. Single-tap to add a meal.
class _SearchPanel extends StatefulWidget {
  final ValueChanged<FoodItem> onFoodSelected;

  const _SearchPanel({required this.onFoodSelected});

  @override
  State<_SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<_SearchPanel> {
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _searchFoods() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
        return;
      }
      final results = await ApiHandler.fetchFoodData(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          // Search field
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search for meal',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.deepPurple.shade800,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _searchFoods(),
          ),
          const SizedBox(height: 16),

          // Loading indicator or error
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_errorMessage.isNotEmpty)
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),

          // List of search results
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final item = _searchResults[index];
                return Card(
                  color: Colors.deepPurple.shade700,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(
                      item.name,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    subtitle: Text(
                          'Fat: ${item.fat} g | '
                          'Carbs: ${item.carbs} g | '
                          'Protein: ${item.protein} g',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    onTap: () => widget.onFoodSelected(item),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
