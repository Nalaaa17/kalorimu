import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kalorimu/core/constants/app_colors.dart';
import 'package:kalorimu/core/services/auth_service.dart';
import 'package:kalorimu/core/services/database_service.dart';
import 'package:kalorimu/core/services/gemini_service.dart';
import 'package:kalorimu/data/models/food_journal.dart';

class ReviewFormScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;

  const ReviewFormScreen({super.key, this.extra});

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _calorieController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _descController;
  final List<Map<String, dynamic>> _components = [];
  final List<String> _units = ['porsi', 'gram', 'biji', 'sdm', 'centong', 'mangkuk', 'potong'];
  String _selectedMealType = 'lunch';
  String? _imageUrl;
  bool _isSaving = false;
  
  final _databaseService = DatabaseService();
  final _authService = AuthService();

  final List<Map<String, String>> _mealTypes = [
    {'value': 'breakfast', 'label': 'Sarapan', 'emoji': '☀️'},
    {'value': 'lunch', 'label': 'Siang', 'emoji': '🌤️'},
    {'value': 'dinner', 'label': 'Malam', 'emoji': '🌙'},
    {'value': 'snack', 'label': 'Camilan', 'emoji': '🍎'},
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.extra ?? {};

    _nameController = TextEditingController(text: data['foodName'] ?? 'Nasi Goreng Spesial');
    _calorieController = TextEditingController(text: data['calories']?.toString() ?? '520');
    _proteinController = TextEditingController(text: data['protein']?.toString() ?? '18');
    _carbsController = TextEditingController(text: data['carbs']?.toString() ?? '65');
    _fatController = TextEditingController(text: data['fat']?.toString() ?? '15');
    _descController = TextEditingController(text: data['description'] ?? '');
    
    final rawComponents = data['components'] as List? ?? [];
    if (rawComponents.isEmpty) {
      _components.add({
        'name': data['foodName'] ?? 'Makanan',
        'amountController': TextEditingController(text: '1'),
        'unit': 'porsi',
      });
    } else {
      for (var c in rawComponents) {
        String unit = c['unit']?.toString().toLowerCase() ?? 'porsi';
        if (!_units.contains(unit)) {
          _units.add(unit);
        }
        _components.add({
          'name': c['name']?.toString() ?? 'Komponen',
          'amountController': TextEditingController(text: c['amount']?.toString() ?? '1'),
          'unit': unit,
        });
      }
    }
    
    _selectedMealType = data['mealType'] ?? 'lunch';
    _imageUrl = data['imageUrl'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _calorieController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _descController.dispose();
    for (var c in _components) {
      (c['amountController'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      try {
        final userId = _authService.currentUser?.id;
        if (userId == null) throw Exception('User not logged in');

        final journal = FoodJournal(
          userId: userId,
          foodName: _nameController.text.trim(),
          calories: int.tryParse(_calorieController.text) ?? 0,
          proteinG: double.tryParse(_proteinController.text),
          carbsG: double.tryParse(_carbsController.text),
          fatG: double.tryParse(_fatController.text),
          description: _descController.text.trim(),
          mealType: _selectedMealType,
          portionNote: _components.map((c) => '${(c['amountController'] as TextEditingController).text} ${c['unit']} ${c['name']}').join(', '),
          imageUrl: _imageUrl,
          loggedAt: DateTime.now(),
        );

        final result = await _databaseService.addJournal(journal);
        if (result != null && mounted) {
          context.go('/dashboard');
        } else {
          throw Exception('Failed to save journal');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
            border: Border.all(
              color: AppColors.primaryContainer.withValues(alpha: 0.3),
              width: 2,
            ),
            image: DecorationImage(
              image: NetworkImage(_imageUrl ?? 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&q=80&w=150&h=150'), 
              fit: BoxFit.cover,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.surfaceVariant,
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(
                    top: BorderSide(
                      color: Color(0x33D4AF37),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04), // ambient-shadow
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Review Meal',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Meal Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'MEAL NAME',
                      hint: 'e.g. Nasi Goreng Spesial',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Meal Type selection
                    Text(
                      'MEAL TYPE',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _mealTypes.map((type) {
                        final isSelected = _selectedMealType == type['value'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMealType = type['value']!;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.1) : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? AppColors.primaryContainer : AppColors.surfaceVariant,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(type['emoji']!),
                                const SizedBox(width: 8),
                                Text(
                                  type['label']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Macros Row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: AppColors.primaryContainer, width: 2), // accent-border
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMacroField('Protein', _proteinController),
                          Container(width: 1, height: 40, color: AppColors.surfaceVariant),
                          _buildMacroField('Carbs', _carbsController),
                          Container(width: 1, height: 40, color: AppColors.surfaceVariant),
                          _buildMacroField('Fat', _fatController),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _calorieController,
                            label: 'TOTAL CALORIES (KCAL)',
                            hint: '0',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Dynamic Components List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'COMPONENTS (KONDIMEN)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                            letterSpacing: 1.0,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryContainer),
                          onPressed: () {
                            setState(() {
                              _components.add({
                                'name': 'Baru',
                                'amountController': TextEditingController(text: '1'),
                                'unit': 'porsi',
                              });
                            });
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._components.asMap().entries.map((entry) {
                      int index = entry.key;
                      var component = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Name field (allow user to edit name too)
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                initialValue: component['name'],
                                onChanged: (val) => component['name'] = val,
                                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceVariant)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryContainer, width: 1.5)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Amount field
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: component['amountController'] as TextEditingController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceVariant)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryContainer, width: 1.5)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Unit Dropdown
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: component['unit'] as String,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceVariant)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryContainer, width: 1.5)),
                                ),
                                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                                items: _units.map((String unit) {
                                  return DropdownMenuItem<String>(
                                    value: unit,
                                    child: Text(unit),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      component['unit'] = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                            // Delete Button
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              onPressed: () {
                                setState(() {
                                  (component['amountController'] as TextEditingController).dispose();
                                  _components.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 16),
                    // Recalculate Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          setState(() => _isSaving = true);
                          List<Map<String, dynamic>> toSend = _components.map((c) => {
                            'name': c['name'],
                            'amount': double.tryParse((c['amountController'] as TextEditingController).text) ?? 1.0,
                            'unit': c['unit']
                          }).toList();
                          
                          final geminiService = GeminiService();
                          final result = await geminiService.recalculateCalories(_nameController.text, toSend);
                          
                          if (mounted) {
                            setState(() {
                              _isSaving = false;
                              if (result != null) {
                                _calorieController.text = result['calories']?.toString() ?? _calorieController.text;
                                _proteinController.text = result['protein']?.toString() ?? _proteinController.text;
                                _carbsController.text = result['carbs']?.toString() ?? _carbsController.text;
                                _fatController.text = result['fat']?.toString() ?? _fatController.text;
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Calories recalculated!'), backgroundColor: Colors.green),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to recalculate'), backgroundColor: Colors.red),
                                );
                              }
                            });
                          }
                        },
                        icon: const Icon(Icons.refresh, color: AppColors.primaryContainer),
                        label: Text(
                          'Recalculate Calories',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.primaryContainer),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryContainer),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    _buildTextField(
                      controller: _descController,
                      label: 'DESCRIPTION (OPTIONAL)',
                      hint: 'Add some notes...',
                    ),
                    
                    const SizedBox(height: 48),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Save Journal',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Footer
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: Container(height: 1, color: const Color(0x80D0C5AF))),
                      const SizedBox(width: 16),
                      Flexible(
                        flex: 2,
                        child: Text(
                          'QUIET LUXURY WELLNESS',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7F7663),
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Container(height: 1, color: const Color(0x80D0C5AF))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x80D0C5AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    TextStyle? style,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
            letterSpacing: 1.0,
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: style ?? GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.surfaceVariant,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            isDense: true,
            enabledBorder: const UnderlineInputBorder( // golden-stroke (on focus)
              borderSide: BorderSide(color: AppColors.surfaceVariant),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryContainer, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMacroField(String label, TextEditingController controller) {
    return Column(
      children: [
        SizedBox(
          width: 50,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$label(g)',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
