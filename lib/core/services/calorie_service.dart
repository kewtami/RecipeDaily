import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/recipe_model.dart' show CookingMethod; 

class CalorieService {
  static final CalorieService _instance = CalorieService._internal();
  factory CalorieService() => _instance;
  CalorieService._internal();

  Map<String, int>? _calorieDatabase;

  // Initialize the service by loading the calorie database
  Future<void> initialize() async {
    try {
      print('🔧 Loading calorie database...');
      final String data = await rootBundle.loadString('assets/data/calories.json');
      final Map<String, dynamic> json = jsonDecode(data);
      _calorieDatabase = json.map((key, value) => MapEntry(key, value as int));
      print('Calorie database loaded: ${_calorieDatabase!.length} ingredients');
    } catch (e) {
      print('Failed to load calorie database: $e');
      _calorieDatabase = {};
    }
  }

  // Calculate calories for an ingredient
  Future<int> calculateCalories({
    required String ingredientName,
    required double quantity,
    required String unit,
    required CookingMethod cookingMethod,
  }) async {
    // Ensure database is loaded
    if (_calorieDatabase == null) {
      await initialize();
    }

    // Convert quantity to grams
    final double grams = _convertToGrams(quantity, unit);

    // Get base calories per 100g
    final int baseCal = _getBaseCalories(ingredientName);

    // Calculate for actual quantity
    double calories = (baseCal * grams) / 100;

    // Apply cooking method multiplier
    calories *= cookingMethod.calorieMultiplier;

    print('📊 Calculated: $ingredientName ${quantity}${unit} (${cookingMethod.displayName}) = ${calories.round()} kcal');

    return calories.round();
  }

  // Get base calories from database
  int _getBaseCalories(String ingredientName) {
    final normalized = ingredientName.toLowerCase().trim();
    
    // Try exact match
    if (_calorieDatabase!.containsKey(normalized)) {
      return _calorieDatabase![normalized]!;
    }

    // Try partial match
    for (var entry in _calorieDatabase!.entries) {
      if (normalized.contains(entry.key) || entry.key.contains(normalized)) {
        return entry.value;
      }
    }

    // Default if not found
    print('Ingredient "$ingredientName" not found in database, using default 100 kcal/100g');
    return 100; // Default calories per 100g
  }

  // Convert various units to grams
  double _convertToGrams(double quantity, String unit) {
    switch (unit.toLowerCase()) {
      case 'g':
      case 'gr':
      case 'gram':
      case 'grams':
        return quantity;
      
      case 'kg':
      case 'kilogram':
      case 'kilograms':
        return quantity * 1000;
      
      case 'oz':
      case 'ounce':
      case 'ounces':
        return quantity * 28.35;
      
      case 'lb':
      case 'pound':
      case 'pounds':
        return quantity * 453.59;
      
      case 'cup':
      case 'cups':
        return quantity * 240; 
      
      case 'tbsp':
      case 'tablespoon':
      case 'tablespoons':
        return quantity * 15;
      
      case 'tsp':
      case 'teaspoon':
      case 'teaspoons':
        return quantity * 5;
      
      case 'ml':
      case 'milliliter':
      case 'milliliters':
        return quantity; 
      
      case 'l':
      case 'liter':
      case 'liters':
        return quantity * 1000;
      
      default:
        print('Unknown unit "$unit", treating as grams');
        return quantity;
    }
  }

  // Get suggestions for ingredient names
  List<String> searchIngredients(String query) {
    if (_calorieDatabase == null || query.isEmpty) return [];
    
    final normalized = query.toLowerCase();
    return _calorieDatabase!.keys
        .where((key) => key.contains(normalized))
        .take(10)
        .toList();
  }
}