// Data model for food journal entry
class FoodJournal {
  final String? id;
  final String userId;
  final String foodName;
  final int calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final String? description;
  final String mealType;
  final String? portionNote;
  final String? imageUrl;
  final DateTime loggedAt;
  final DateTime? createdAt;

  FoodJournal({
    this.id,
    required this.userId,
    required this.foodName,
    required this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.description,
    required this.mealType,
    this.portionNote,
    this.imageUrl,
    required this.loggedAt,
    this.createdAt,
  });

  factory FoodJournal.fromJson(Map<String, dynamic> json) {
    return FoodJournal(
      id: json['id'],
      userId: json['user_id'],
      foodName: json['food_name'],
      calories: json['calories'] is int ? json['calories'] : (json['calories'] as num).toInt(),
      proteinG: json['protein_g'] != null ? (json['protein_g'] as num).toDouble() : null,
      carbsG: json['carbs_g'] != null ? (json['carbs_g'] as num).toDouble() : null,
      fatG: json['fat_g'] != null ? (json['fat_g'] as num).toDouble() : null,
      description: json['description'],
      mealType: json['meal_type'] ?? 'other',
      portionNote: json['portion_note'],
      imageUrl: json['image_url'],
      loggedAt: json['logged_at'] != null ? DateTime.parse(json['logged_at']) : DateTime.now(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'user_id': userId,
      'food_name': foodName,
      'calories': calories,
      'protein_g': proteinG,
      'carbs_g': carbsG,
      'fat_g': fatG,
      'description': description,
      'meal_type': mealType,
      'portion_note': portionNote,
      'image_url': imageUrl,
      'logged_at': loggedAt.toUtc().toIso8601String(),
    };
    if (id != null) map['id'] = id!;
    if (createdAt != null) map['created_at'] = createdAt!.toIso8601String();
    return map;
  }

  String get mealTypeLabel {
    switch (mealType) {
      case 'breakfast':
        return 'Sarapan';
      case 'lunch':
        return 'Makan Siang';
      case 'dinner':
        return 'Makan Malam';
      case 'snack':
        return 'Camilan';
      default:
        return 'Lainnya';
    }
  }

  String get mealTypeEmoji {
    switch (mealType) {
      case 'breakfast':
        return '☀️';
      case 'lunch':
        return '🌤️';
      case 'dinner':
        return '🌙';
      case 'snack':
        return '🍎';
      default:
        return '🍽️';
    }
  }
}

// Model for AI detection result
class AiResult {
  final String foodName;
  final int estimasiKalori;
  final int? proteinG;
  final int? karbohidratG;
  final int? lemakG;
  final String? porsiEstimasi;
  final String? mealTypeSuggestion;
  final String? deskripsiSingkat;
  final bool isError;
  final String? errorMessage;

  AiResult({
    required this.foodName,
    required this.estimasiKalori,
    this.proteinG,
    this.karbohidratG,
    this.lemakG,
    this.porsiEstimasi,
    this.mealTypeSuggestion,
    this.deskripsiSingkat,
    this.isError = false,
    this.errorMessage,
  });

  factory AiResult.error(String message) {
    return AiResult(
      foodName: '',
      estimasiKalori: 0,
      isError: true,
      errorMessage: message,
    );
  }

  factory AiResult.fromJson(Map<String, dynamic> json) {
    return AiResult(
      foodName: json['nama_makanan'] ?? '',
      estimasiKalori: json['estimasi_kalori'] ?? 0,
      proteinG: json['makronutrien']?['protein_g'],
      karbohidratG: json['makronutrien']?['karbohidrat_g'],
      lemakG: json['makronutrien']?['lemak_g'],
      porsiEstimasi: json['porsi_estimasi'],
      mealTypeSuggestion: json['meal_type_suggestion'],
      deskripsiSingkat: json['deskripsi_singkat'],
    );
  }
}

// Daily summary model
class DailySummary {
  final int totalCalories;
  final int totalProteinG;
  final int totalCarbsG;
  final int totalFatG;
  final int entryCount;
  final int targetCalories;

  DailySummary({
    required this.totalCalories,
    required this.totalProteinG,
    required this.totalCarbsG,
    required this.totalFatG,
    required this.entryCount,
    required this.targetCalories,
  });

  double get calorieProgress =>
      targetCalories > 0 ? (totalCalories / targetCalories).clamp(0.0, 1.0) : 0;
  int get remainingCalories => (targetCalories - totalCalories).clamp(0, targetCalories);
}
