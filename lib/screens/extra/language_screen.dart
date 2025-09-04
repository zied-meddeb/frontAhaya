import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/language_provider.dart';
import 'package:shop/l10n/app_localizations.dart';
import 'package:shop/constants.dart';


class LanguageSelectorScreen extends StatefulWidget {
  const LanguageSelectorScreen({super.key});

  @override
  State<LanguageSelectorScreen> createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  final List<Language> languages = const [
    Language(code: 'ar', name: 'العربية', flag: '🇸🇦'),
    Language(code: 'fr', name: 'Français', flag: '🇫🇷'),
    Language(code: 'en', name: 'English', flag: '🇺🇸'),
  ];

  @override
  void initState() {
    super.initState();
    // Load the current language when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LanguageProvider>().loadLanguage();
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    await context.read<LanguageProvider>().changeLanguage(languageCode);
  }

  Future<void> _saveLanguageAndPop() async {
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languageSelection),
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
    final l10n = AppLocalizations.of(context);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor,
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
          l10n.languageSelection,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937), // gray-800
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.choosePreferredLanguage,
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
    final l10n = AppLocalizations.of(context);
    final languageProvider = context.watch<LanguageProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.language,
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
              value: languageProvider.currentLanguage,
              hint: Text(l10n.selectALanguage),
              isExpanded: true,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _changeLanguage(newValue);
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
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Text(
                l10n.confirm,
                style: const TextStyle(
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


