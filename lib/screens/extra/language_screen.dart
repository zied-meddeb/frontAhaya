import 'package:flutter/material.dart';
import 'package:shop/services/auth_service.dart';


class LanguageSelectorScreen extends StatefulWidget {
  const LanguageSelectorScreen({super.key});

  @override
  State<LanguageSelectorScreen> createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  String _selectedLanguage = 'fr'; // Default language
  final AuthService _authService = AuthService();


  final List<Language> languages = const [
    Language(code: 'ar', name: 'العربية', flag: '🇸🇦'),
    Language(code: 'fr', name: 'Français', flag: '🇫🇷'),
    Language(code: 'en', name: 'English', flag: '🇺🇸'),
  ];

  final Map<String, Translation> translations = const {
    'ar': Translation(
      title: 'اختيار اللغة',
      description: 'اختر لغتك المفضلة',
      label: 'اللغة',
      placeholder: 'اختر لغة',
      selected: 'اللغة المختارة:',
    ),
    'fr': Translation(
      title: 'Sélection de langue',
      description: 'Choisissez votre langue préférée',
      label: 'Langue',
      placeholder: 'Sélectionner une langue',
      selected: 'Langue sélectionnée :',
    ),
    'en': Translation(
      title: 'Language Selection',
      description: 'Choose your preferred language',
      label: 'Language',
      placeholder: 'Select a language',
      selected: 'Selected language:',
    ),
  };

  Translation get currentTranslation => translations[_selectedLanguage]!;
  Language get currentLanguage => languages.firstWhere((lang) => lang.code == _selectedLanguage);

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    final language = await _authService.getLanguage();
    setState(() {
      _selectedLanguage = language ?? 'fr'; // Default to French if not found
    });
  }

  Future<void> _changeSelectedLanguage(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  Future<void> _saveLanguageAndPop() async {
    await _authService.saveLanguage(_selectedLanguage);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),

      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEBF8FF), // blue-50
              Color(0xFFE0E7FF), // indigo-100
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWeb ? 400 : double.infinity,
              ),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildLanguageSelector(),
                      const SizedBox(height: 24),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.language,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          currentTranslation.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937), // gray-800
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          currentTranslation.description,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280), // gray-600
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentTranslation.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151), // gray-700
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD1D5DB)), // gray-300
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLanguage,
              hint: Text(currentTranslation.placeholder),
              isExpanded: true,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _changeSelectedLanguage(newValue);
                }
              },
              items: languages.map<DropdownMenuItem<String>>((Language language) {
                return DropdownMenuItem<String>(
                  value: language.code,
                  child: Row(
                    children: [
                      Text(
                        language.flag,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        language.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveLanguageAndPop,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Confirmer',
                style: TextStyle(
                  fontSize: 18,

                ),
              ),
            ),
          ),
        )
      ],
    );
  }


}

class Language {
  final String code;
  final String name;
  final String flag;

  const Language({
    required this.code,
    required this.name,
    required this.flag,
  });
}

class Translation {
  final String title;
  final String description;
  final String label;
  final String placeholder;
  final String selected;

  const Translation({
    required this.title,
    required this.description,
    required this.label,
    required this.placeholder,
    required this.selected,
  });
}
