import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FoodItem {
  final String name;
  final double fat;
  final double carbs;
  final double protein;

  FoodItem({
    required this.name,
    required this.fat,
    required this.carbs,
    required this.protein,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] ?? 'Unknown',
      fat: (json['fat_total_g'] ?? 0).toDouble(),
      carbs: (json['carbohydrates_total_g'] ?? 0).toDouble(),
      protein: (json['protein_g'] ?? 0).toDouble(),
    );
  }
}

class ApiHandler {
  static const String _apiUrl = 'api.calorieninjas.com';

  static Future<List<FoodItem>> fetchFoodData(String query) async {

    await dotenv.load(fileName: ".env");
    String? rawApiKey = dotenv.env['APIKEY'];
    String apiKey = rawApiKey?.replaceAll(RegExp(r"^'|'$"), '') ?? ''
    ;
    final uri = Uri.https(_apiUrl, dotenv.env['ENDPOINT']!, {'query': query});
    final response = await http.get(
      uri,
      headers: {'X-Api-Key': apiKey},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List items = data['items'] ?? [];
      return items.map((json) => FoodItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }
}
