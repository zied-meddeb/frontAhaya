import 'package:flutter/material.dart';
import 'package:shop/services/fournisseur_service.dart';
import 'package:shop/constants.dart';

class FournisseurOnboardingScreen extends StatefulWidget {
  const FournisseurOnboardingScreen({super.key});

  @override
  State<FournisseurOnboardingScreen> createState() => _FournisseurOnboardingScreenState();
}

class _FournisseurOnboardingScreenState extends State<FournisseurOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final _fournisseurService = FournisseurService();
  
  int _currentStep = 0;
  bool _isLoading = false;
  
  // Store information
  final _storeNameController = TextEditingController();
  final _storeDescriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _twitterController = TextEditingController();
  
  // Address information
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  
  String _selectedAddressType = 'primary';
  bool _isDefaultAddress = true;
  
  final List<Map<String, dynamic>> _addresses = [];
  
  @override
  void dispose() {
    _storeNameController.dispose();
    _storeDescriptionController.dispose();
    _websiteController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _pageController.dispose();
    super.dispose();
  }
  
  void _addAddress() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _addresses.add({
          'type': _selectedAddressType,
          'street': _streetController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'postalCode': _postalCodeController.text,
          'country': _countryController.text,
          'isDefault': _isDefaultAddress,
        });
        
        // Clear form
        _streetController.clear();
        _cityController.clear();
        _stateController.clear();
        _postalCodeController.clear();
        _countryController.clear();
        _isDefaultAddress = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adresse ajoutée avec succès'),
          backgroundColor: successColor,
        ),
      );
    }
  }
  
  void _removeAddress(int index) {
    setState(() {
      _addresses.removeAt(index);
    });
  }
  
  Future<void> _completeOnboarding() async {
    if (_addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins une adresse'),
          backgroundColor: warningColor,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final onboardingData = {
        'storeInfo': {
          'website': _websiteController.text.isNotEmpty ? _websiteController.text : null,
          'description': _storeDescriptionController.text.isNotEmpty ? _storeDescriptionController.text : null,
          'socialMedia': {
            'facebook': _facebookController.text.isNotEmpty ? _facebookController.text : null,
            'instagram': _instagramController.text.isNotEmpty ? _instagramController.text : null,
            'twitter': _twitterController.text.isNotEmpty ? _twitterController.text : null,
          }
        },
        'addresses': _addresses,
      };
      
      await _fournisseurService.completeOnboarding(onboardingData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration terminée avec succès!'),
            backgroundColor: successColor,
          ),
        );
        
        // Navigate to main fournisseur screen
        Navigator.pushReplacementNamed(context, '/fournisseur');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration du Fournisseur'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentStep = index;
            });
          },
          children: [
            _buildStoreInfoStep(),
            _buildAddressStep(),
            _buildReviewStep(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
  
  Widget _buildStoreInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations du Magasin',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _storeNameController,
            decoration: const InputDecoration(
              labelText: 'Nom du magasin',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le nom du magasin';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _storeDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Description du magasin',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _websiteController,
            decoration: const InputDecoration(
              labelText: 'Site web (optionnel)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Réseaux Sociaux (optionnel)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _facebookController,
            decoration: const InputDecoration(
              labelText: 'Facebook',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _instagramController,
            decoration: const InputDecoration(
              labelText: 'Instagram',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _twitterController,
            decoration: const InputDecoration(
              labelText: 'Twitter',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddressStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adresses',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Address form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ajouter une adresse',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedAddressType,
                    decoration: const InputDecoration(
                      labelText: 'Type d\'adresse',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'primary', child: Text('Principale')),
                      DropdownMenuItem(value: 'secondary', child: Text('Secondaire')),
                      DropdownMenuItem(value: 'warehouse', child: Text('Entrepôt')),
                      DropdownMenuItem(value: 'office', child: Text('Bureau')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedAddressType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _streetController,
                    decoration: const InputDecoration(
                      labelText: 'Rue',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer la rue';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'Ville',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer la ville';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _stateController,
                          decoration: const InputDecoration(
                            labelText: 'État/Région',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer l\'état';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _postalCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Code postal',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le code postal';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _countryController,
                          decoration: const InputDecoration(
                            labelText: 'Pays',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le pays';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  CheckboxListTile(
                    title: const Text('Adresse par défaut'),
                    value: _isDefaultAddress,
                    onChanged: (value) {
                      setState(() {
                        _isDefaultAddress = value!;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addAddress,
                      child: const Text('Ajouter l\'adresse'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Address list
          if (_addresses.isNotEmpty) ...[
            const Text(
              'Adresses ajoutées',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _addresses.length,
                itemBuilder: (context, index) {
                  final address = _addresses[index];
                  return Card(
                    child: ListTile(
                      title: Text('${address['street']}, ${address['city']}'),
                      subtitle: Text('${address['state']}, ${address['postalCode']}, ${address['country']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (address['isDefault'])
                            const Chip(
                              label: Text('Défaut'),
                              backgroundColor: primaryColor,
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: errorColor),
                            onPressed: () => _removeAddress(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildReviewStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Récapitulatif',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Store info review
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations du magasin',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text('Nom: ${_storeNameController.text}'),
                  if (_storeDescriptionController.text.isNotEmpty)
                    Text('Description: ${_storeDescriptionController.text}'),
                  if (_websiteController.text.isNotEmpty)
                    Text('Site web: ${_websiteController.text}'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Addresses review
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adresses (${_addresses.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...(_addresses.map((address) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '${address['type']}: ${address['street']}, ${address['city']} ${address['isDefault'] ? '(Défaut)' : ''}',
                    ),
                  ))),
                ],
              ),
            ),
          ),
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _completeOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Terminer la configuration'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomNavigation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('Précédent'),
              ),
            )
          else
            const SizedBox.shrink(),
          
          Text('Étape ${_currentStep + 1} sur 3'),
          
          if (_currentStep < 2)
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentStep == 0) {
                    // Validate store info
                    if (_storeNameController.text.isNotEmpty) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez entrer le nom du magasin'),
                          backgroundColor: warningColor,
                        ),
                      );
                    }
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: const Text('Suivant'),
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
