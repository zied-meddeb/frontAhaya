import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Common translations
  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get shop => _localizedValues[locale.languageCode]!['shop']!;
  String get favorites => _localizedValues[locale.languageCode]!['favorites']!;
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get search => _localizedValues[locale.languageCode]!['search']!;
  String get searchProducts => _localizedValues[locale.languageCode]!['searchProducts']!;
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get signup => _localizedValues[locale.languageCode]!['signup']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get back => _localizedValues[locale.languageCode]!['back']!;
  String get next => _localizedValues[locale.languageCode]!['next']!;
  String get previous => _localizedValues[locale.languageCode]!['previous']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get success => _localizedValues[locale.languageCode]!['success']!;
  String get warning => _localizedValues[locale.languageCode]!['warning']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get selectLanguage => _localizedValues[locale.languageCode]!['selectLanguage']!;
  String get languageSelection => _localizedValues[locale.languageCode]!['languageSelection']!;
  String get choosePreferredLanguage => _localizedValues[locale.languageCode]!['choosePreferredLanguage']!;
  String get selectedLanguage => _localizedValues[locale.languageCode]!['selectedLanguage']!;
  String get selectALanguage => _localizedValues[locale.languageCode]!['selectALanguage']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get notifications => _localizedValues[locale.languageCode]!['notifications']!;
  String get wallet => _localizedValues[locale.languageCode]!['wallet']!;
  String get orders => _localizedValues[locale.languageCode]!['orders']!;
  String get help => _localizedValues[locale.languageCode]!['help']!;
  String get about => _localizedValues[locale.languageCode]!['about']!;
  String get contact => _localizedValues[locale.languageCode]!['contact']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get price => _localizedValues[locale.languageCode]!['price']!;
  String get addToCart => _localizedValues[locale.languageCode]!['addToCart']!;
  String get buyNow => _localizedValues[locale.languageCode]!['buyNow']!;
  String get outOfStock => _localizedValues[locale.languageCode]!['outOfStock']!;
  String get inStock => _localizedValues[locale.languageCode]!['inStock']!;
  String get description => _localizedValues[locale.languageCode]!['description']!;
  String get reviews => _localizedValues[locale.languageCode]!['reviews']!;
  String get rating => _localizedValues[locale.languageCode]!['rating']!;
  String get categories => _localizedValues[locale.languageCode]!['categories']!;
  String get popularProducts => _localizedValues[locale.languageCode]!['popularProducts']!;
  String get newArrivals => _localizedValues[locale.languageCode]!['newArrivals']!;
  String get bestSellers => _localizedValues[locale.languageCode]!['bestSellers']!;
  String get flashSale => _localizedValues[locale.languageCode]!['flashSale']!;
  String get specialOffer => _localizedValues[locale.languageCode]!['specialOffer']!;
  String get discount => _localizedValues[locale.languageCode]!['discount']!;
  String get freeShipping => _localizedValues[locale.languageCode]!['freeShipping']!;
  String get total => _localizedValues[locale.languageCode]!['total']!;
  String get subtotal => _localizedValues[locale.languageCode]!['subtotal']!;
  String get tax => _localizedValues[locale.languageCode]!['tax']!;
  String get shipping => _localizedValues[locale.languageCode]!['shipping']!;
  String get checkout => _localizedValues[locale.languageCode]!['checkout']!;
  String get paymentMethod => _localizedValues[locale.languageCode]!['paymentMethod']!;
  String get creditCard => _localizedValues[locale.languageCode]!['creditCard']!;
  String get cashOnDelivery => _localizedValues[locale.languageCode]!['cashOnDelivery']!;
  String get orderPlaced => _localizedValues[locale.languageCode]!['orderPlaced']!;
  String get orderConfirmed => _localizedValues[locale.languageCode]!['orderConfirmed']!;
  String get orderShipped => _localizedValues[locale.languageCode]!['orderShipped']!;
  String get orderDelivered => _localizedValues[locale.languageCode]!['orderDelivered']!;
  String get orderCancelled => _localizedValues[locale.languageCode]!['orderCancelled']!;
  String get trackOrder => _localizedValues[locale.languageCode]!['trackOrder']!;
  String get orderHistory => _localizedValues[locale.languageCode]!['orderHistory']!;
  String get myOrders => _localizedValues[locale.languageCode]!['myOrders']!;
  String get myProfile => _localizedValues[locale.languageCode]!['myProfile']!;
  String get personalInfo => _localizedValues[locale.languageCode]!['personalInfo']!;
  String get address => _localizedValues[locale.languageCode]!['address']!;
  String get phoneNumber => _localizedValues[locale.languageCode]!['phoneNumber']!;
  String get dateOfBirth => _localizedValues[locale.languageCode]!['dateOfBirth']!;
  String get gender => _localizedValues[locale.languageCode]!['gender']!;
  String get male => _localizedValues[locale.languageCode]!['male']!;
  String get female => _localizedValues[locale.languageCode]!['female']!;
  String get other => _localizedValues[locale.languageCode]!['other']!;
  String get privacy => _localizedValues[locale.languageCode]!['privacy']!;
  String get terms => _localizedValues[locale.languageCode]!['terms']!;
  String get privacyPolicy => _localizedValues[locale.languageCode]!['privacyPolicy']!;
  String get termsOfService => _localizedValues[locale.languageCode]!['termsOfService']!;
  String get version => _localizedValues[locale.languageCode]!['version']!;
  String get buildNumber => _localizedValues[locale.languageCode]!['buildNumber']!;
  String get developer => _localizedValues[locale.languageCode]!['developer']!;
  String get support => _localizedValues[locale.languageCode]!['support']!;
  String get feedback => _localizedValues[locale.languageCode]!['feedback']!;
  String get reportBug => _localizedValues[locale.languageCode]!['reportBug']!;
  String get shareApp => _localizedValues[locale.languageCode]!['shareApp']!;
  String get rateApp => _localizedValues[locale.languageCode]!['rateApp']!;
  String get noInternetConnection => _localizedValues[locale.languageCode]!['noInternetConnection']!;
  String get serverError => _localizedValues[locale.languageCode]!['serverError']!;
  String get somethingWentWrong => _localizedValues[locale.languageCode]!['somethingWentWrong']!;
  String get tryAgain => _localizedValues[locale.languageCode]!['tryAgain']!;
  String get noDataFound => _localizedValues[locale.languageCode]!['noDataFound']!;
  String get emptyCart => _localizedValues[locale.languageCode]!['emptyCart']!;
  String get emptyFavorites => _localizedValues[locale.languageCode]!['emptyFavorites']!;
  String get emptyOrders => _localizedValues[locale.languageCode]!['emptyOrders']!;
  String get emptyNotifications => _localizedValues[locale.languageCode]!['emptyNotifications']!;
  String get emptyWallet => _localizedValues[locale.languageCode]!['emptyWallet']!;
  String get emptyWalletHistory => _localizedValues[locale.languageCode]!['emptyWalletHistory']!;
  String get noAddresses => _localizedValues[locale.languageCode]!['noAddresses']!;
  String get noPaymentMethods => _localizedValues[locale.languageCode]!['noPaymentMethods']!;
  String get noReviews => _localizedValues[locale.languageCode]!['noReviews']!;
  String get noProducts => _localizedValues[locale.languageCode]!['noProducts']!;
  String get noCategories => _localizedValues[locale.languageCode]!['noCategories']!;
  String get noBrands => _localizedValues[locale.languageCode]!['noBrands']!;
  String get noSearchResults => _localizedValues[locale.languageCode]!['noSearchResults']!;
  String get searchResults => _localizedValues[locale.languageCode]!['searchResults']!;
  String get filter => _localizedValues[locale.languageCode]!['filter']!;
  String get sort => _localizedValues[locale.languageCode]!['sort']!;
  String get clear => _localizedValues[locale.languageCode]!['clear']!;
  String get apply => _localizedValues[locale.languageCode]!['apply']!;
  String get reset => _localizedValues[locale.languageCode]!['reset']!;
  String get all => _localizedValues[locale.languageCode]!['all']!;
  String get none => _localizedValues[locale.languageCode]!['none']!;
  String get selectAll => _localizedValues[locale.languageCode]!['selectAll']!;
  String get deselectAll => _localizedValues[locale.languageCode]!['deselectAll']!;
  String get selected => _localizedValues[locale.languageCode]!['selected']!;
  String get unselected => _localizedValues[locale.languageCode]!['unselected']!;
  String get required => _localizedValues[locale.languageCode]!['required']!;
  String get optional => _localizedValues[locale.languageCode]!['optional']!;
  String get yes => _localizedValues[locale.languageCode]!['yes']!;
  String get no => _localizedValues[locale.languageCode]!['no']!;
  String get ok => _localizedValues[locale.languageCode]!['ok']!;
  String get done => _localizedValues[locale.languageCode]!['done']!;
  String get skip => _localizedValues[locale.languageCode]!['skip']!;
  String get continue_ => _localizedValues[locale.languageCode]!['continue']!;
  String get finish => _localizedValues[locale.languageCode]!['finish']!;
  String get start => _localizedValues[locale.languageCode]!['start']!;
  String get stop => _localizedValues[locale.languageCode]!['stop']!;
  String get pause => _localizedValues[locale.languageCode]!['pause']!;
  String get resume => _localizedValues[locale.languageCode]!['resume']!;
  String get retry => _localizedValues[locale.languageCode]!['retry']!;
  String get refresh => _localizedValues[locale.languageCode]!['refresh']!;
  String get reload => _localizedValues[locale.languageCode]!['reload']!;
  String get update => _localizedValues[locale.languageCode]!['update']!;
  String get upgrade => _localizedValues[locale.languageCode]!['upgrade']!;
  String get download => _localizedValues[locale.languageCode]!['download']!;
  String get upload => _localizedValues[locale.languageCode]!['upload']!;
  String get install => _localizedValues[locale.languageCode]!['install']!;
  String get uninstall => _localizedValues[locale.languageCode]!['uninstall']!;
  String get enable => _localizedValues[locale.languageCode]!['enable']!;
  String get disable => _localizedValues[locale.languageCode]!['disable']!;
  String get on => _localizedValues[locale.languageCode]!['on']!;
  String get off => _localizedValues[locale.languageCode]!['off']!;
  String get active => _localizedValues[locale.languageCode]!['active']!;
  String get inactive => _localizedValues[locale.languageCode]!['inactive']!;
  String get online => _localizedValues[locale.languageCode]!['online']!;
  String get offline => _localizedValues[locale.languageCode]!['offline']!;
  String get connected => _localizedValues[locale.languageCode]!['connected']!;
  String get disconnected => _localizedValues[locale.languageCode]!['disconnected']!;
  String get available => _localizedValues[locale.languageCode]!['available']!;
  String get unavailable => _localizedValues[locale.languageCode]!['unavailable']!;
  String get visible => _localizedValues[locale.languageCode]!['visible']!;
  String get hidden => _localizedValues[locale.languageCode]!['hidden']!;
  String get public => _localizedValues[locale.languageCode]!['public']!;
  String get private => _localizedValues[locale.languageCode]!['private']!;
  String get draft => _localizedValues[locale.languageCode]!['draft']!;
  String get published => _localizedValues[locale.languageCode]!['published']!;
  String get pending => _localizedValues[locale.languageCode]!['pending']!;
  String get approved => _localizedValues[locale.languageCode]!['approved']!;
  String get rejected => _localizedValues[locale.languageCode]!['rejected']!;
  String get expired => _localizedValues[locale.languageCode]!['expired']!;
  String get completed => _localizedValues[locale.languageCode]!['completed']!;
  String get cancelled => _localizedValues[locale.languageCode]!['cancelled']!;
  String get failed => _localizedValues[locale.languageCode]!['failed']!;
  String get processing => _localizedValues[locale.languageCode]!['processing']!;
  String get shipped => _localizedValues[locale.languageCode]!['shipped']!;
  String get delivered => _localizedValues[locale.languageCode]!['delivered']!;
  String get returned => _localizedValues[locale.languageCode]!['returned']!;
  String get refunded => _localizedValues[locale.languageCode]!['refunded']!;
  String get paid => _localizedValues[locale.languageCode]!['paid']!;
  String get unpaid => _localizedValues[locale.languageCode]!['unpaid']!;
  String get partial => _localizedValues[locale.languageCode]!['partial']!;
  String get full => _localizedValues[locale.languageCode]!['full']!;
  String get partialRefund => _localizedValues[locale.languageCode]!['partialRefund']!;
  String get fullRefund => _localizedValues[locale.languageCode]!['fullRefund']!;
  String get partialPayment => _localizedValues[locale.languageCode]!['partialPayment']!;
  String get fullPayment => _localizedValues[locale.languageCode]!['fullPayment']!;
  String get partialDelivery => _localizedValues[locale.languageCode]!['partialDelivery']!;
  String get fullDelivery => _localizedValues[locale.languageCode]!['fullDelivery']!;
  String get partialReturn => _localizedValues[locale.languageCode]!['partialReturn']!;
  String get fullReturn => _localizedValues[locale.languageCode]!['fullReturn']!;

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Ahaya',
      'home': 'Home',
      'shop': 'Shop',
      'favorites': 'Favorites',
      'profile': 'Profile',
      'search': 'Search',
      'searchProducts': 'Search products...',
      'login': 'Login',
      'signup': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'save': 'Save',
      'edit': 'Edit',
      'delete': 'Delete',
      'back': 'Back',
      'next': 'Next',
      'previous': 'Previous',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'language': 'Language',
      'selectLanguage': 'Select Language',
      'languageSelection': 'Language Selection',
      'choosePreferredLanguage': 'Choose your preferred language',
      'selectedLanguage': 'Selected language:',
      'selectALanguage': 'Select a language',
      'settings': 'Settings',
      'notifications': 'Notifications',
      'wallet': 'Wallet',
      'orders': 'Orders',
      'help': 'Help',
      'about': 'About',
      'contact': 'Contact',
      'logout': 'Logout',
      'price': 'Price',
      'addToCart': 'Add to Cart',
      'buyNow': 'Buy Now',
      'outOfStock': 'Out of Stock',
      'inStock': 'In Stock',
      'description': 'Description',
      'reviews': 'Reviews',
      'rating': 'Rating',
      'categories': 'Categories',
      'popularProducts': 'Popular Products',
      'newArrivals': 'New Arrivals',
      'bestSellers': 'Best Sellers',
      'flashSale': 'Flash Sale',
      'specialOffer': 'Special Offer',
      'discount': 'Discount',
      'freeShipping': 'Free Shipping',
      'total': 'Total',
      'subtotal': 'Subtotal',
      'tax': 'Tax',
      'shipping': 'Shipping',
      'checkout': 'Checkout',
      'paymentMethod': 'Payment Method',
      'creditCard': 'Credit Card',
      'cashOnDelivery': 'Cash on Delivery',
      'orderPlaced': 'Order Placed',
      'orderConfirmed': 'Order Confirmed',
      'orderShipped': 'Order Shipped',
      'orderDelivered': 'Order Delivered',
      'orderCancelled': 'Order Cancelled',
      'trackOrder': 'Track Order',
      'orderHistory': 'Order History',
      'myOrders': 'My Orders',
      'myProfile': 'My Profile',
      'personalInfo': 'Personal Information',
      'address': 'Address',
      'phoneNumber': 'Phone Number',
      'dateOfBirth': 'Date of Birth',
      'gender': 'Gender',
      'male': 'Male',
      'female': 'Female',
      'other': 'Other',
      'privacy': 'Privacy',
      'terms': 'Terms',
      'privacyPolicy': 'Privacy Policy',
      'termsOfService': 'Terms of Service',
      'version': 'Version',
      'buildNumber': 'Build Number',
      'developer': 'Developer',
      'support': 'Support',
      'feedback': 'Feedback',
      'reportBug': 'Report Bug',
      'shareApp': 'Share App',
      'rateApp': 'Rate App',
      'noInternetConnection': 'No Internet Connection',
      'serverError': 'Server Error',
      'somethingWentWrong': 'Something went wrong',
      'tryAgain': 'Try Again',
      'noDataFound': 'No data found',
      'emptyCart': 'Your cart is empty',
      'emptyFavorites': 'No favorites yet',
      'emptyOrders': 'No orders yet',
      'emptyNotifications': 'No notifications',
      'emptyWallet': 'Wallet is empty',
      'emptyWalletHistory': 'No wallet history',
      'noAddresses': 'No addresses',
      'noPaymentMethods': 'No payment methods',
      'noReviews': 'No reviews yet',
      'noProducts': 'No products found',
      'noCategories': 'No categories',
      'noBrands': 'No brands',
      'noSearchResults': 'No search results',
      'searchResults': 'Search Results',
      'filter': 'Filter',
      'sort': 'Sort',
      'clear': 'Clear',
      'apply': 'Apply',
      'reset': 'Reset',
      'all': 'All',
      'none': 'None',
      'selectAll': 'Select All',
      'deselectAll': 'Deselect All',
      'selected': 'Selected',
      'unselected': 'Unselected',
      'required': 'Required',
      'optional': 'Optional',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'done': 'Done',
      'skip': 'Skip',
      'continue': 'Continue',
      'finish': 'Finish',
      'start': 'Start',
      'stop': 'Stop',
      'pause': 'Pause',
      'resume': 'Resume',
      'retry': 'Retry',
      'refresh': 'Refresh',
      'reload': 'Reload',
      'update': 'Update',
      'upgrade': 'Upgrade',
      'download': 'Download',
      'upload': 'Upload',
      'install': 'Install',
      'uninstall': 'Uninstall',
      'enable': 'Enable',
      'disable': 'Disable',
      'on': 'On',
      'off': 'Off',
      'active': 'Active',
      'inactive': 'Inactive',
      'online': 'Online',
      'offline': 'Offline',
      'connected': 'Connected',
      'disconnected': 'Disconnected',
      'available': 'Available',
      'unavailable': 'Unavailable',
      'visible': 'Visible',
      'hidden': 'Hidden',
      'public': 'Public',
      'private': 'Private',
      'draft': 'Draft',
      'published': 'Published',
      'pending': 'Pending',
      'approved': 'Approved',
      'rejected': 'Rejected',
      'expired': 'Expired',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      'failed': 'Failed',
      'processing': 'Processing',
      'shipped': 'Shipped',
      'delivered': 'Delivered',
      'returned': 'Returned',
      'refunded': 'Refunded',
      'paid': 'Paid',
      'unpaid': 'Unpaid',
      'partial': 'Partial',
      'full': 'Full',
      'partialRefund': 'Partial Refund',
      'fullRefund': 'Full Refund',
      'partialPayment': 'Partial Payment',
      'fullPayment': 'Full Payment',
      'partialDelivery': 'Partial Delivery',
      'fullDelivery': 'Full Delivery',
      'partialReturn': 'Partial Return',
      'fullReturn': 'Full Return',
    },
    'fr': {
      'appTitle': 'Ahaya',
      'home': 'Accueil',
      'shop': 'Boutique',
      'favorites': 'Favoris',
      'profile': 'Profil',
      'search': 'Rechercher',
      'searchProducts': 'Rechercher des produits...',
      'login': 'Connexion',
      'signup': 'S\'inscrire',
      'email': 'Email',
      'password': 'Mot de passe',
      'confirm': 'Confirmer',
      'cancel': 'Annuler',
      'save': 'Enregistrer',
      'edit': 'Modifier',
      'delete': 'Supprimer',
      'back': 'Retour',
      'next': 'Suivant',
      'previous': 'Précédent',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'success': 'Succès',
      'warning': 'Avertissement',
      'language': 'Langue',
      'selectLanguage': 'Sélectionner la langue',
      'languageSelection': 'Sélection de langue',
      'choosePreferredLanguage': 'Choisissez votre langue préférée',
      'selectedLanguage': 'Langue sélectionnée :',
      'selectALanguage': 'Sélectionner une langue',
      'settings': 'Paramètres',
      'notifications': 'Notifications',
      'wallet': 'Portefeuille',
      'orders': 'Commandes',
      'help': 'Aide',
      'about': 'À propos',
      'contact': 'Contact',
      'logout': 'Déconnexion',
      'price': 'Prix',
      'addToCart': 'Ajouter au panier',
      'buyNow': 'Acheter maintenant',
      'outOfStock': 'Rupture de stock',
      'inStock': 'En stock',
      'description': 'Description',
      'reviews': 'Avis',
      'rating': 'Note',
      'categories': 'Catégories',
      'popularProducts': 'Produits populaires',
      'newArrivals': 'Nouveautés',
      'bestSellers': 'Meilleures ventes',
      'flashSale': 'Vente flash',
      'specialOffer': 'Offre spéciale',
      'discount': 'Remise',
      'freeShipping': 'Livraison gratuite',
      'total': 'Total',
      'subtotal': 'Sous-total',
      'tax': 'Taxe',
      'shipping': 'Livraison',
      'checkout': 'Commander',
      'paymentMethod': 'Méthode de paiement',
      'creditCard': 'Carte de crédit',
      'cashOnDelivery': 'Paiement à la livraison',
      'orderPlaced': 'Commande passée',
      'orderConfirmed': 'Commande confirmée',
      'orderShipped': 'Commande expédiée',
      'orderDelivered': 'Commande livrée',
      'orderCancelled': 'Commande annulée',
      'trackOrder': 'Suivre la commande',
      'orderHistory': 'Historique des commandes',
      'myOrders': 'Mes commandes',
      'myProfile': 'Mon profil',
      'personalInfo': 'Informations personnelles',
      'address': 'Adresse',
      'phoneNumber': 'Numéro de téléphone',
      'dateOfBirth': 'Date de naissance',
      'gender': 'Sexe',
      'male': 'Homme',
      'female': 'Femme',
      'other': 'Autre',
      'privacy': 'Confidentialité',
      'terms': 'Conditions',
      'privacyPolicy': 'Politique de confidentialité',
      'termsOfService': 'Conditions d\'utilisation',
      'version': 'Version',
      'buildNumber': 'Numéro de build',
      'developer': 'Développeur',
      'support': 'Support',
      'feedback': 'Commentaires',
      'reportBug': 'Signaler un bug',
      'shareApp': 'Partager l\'app',
      'rateApp': 'Noter l\'app',
      'noInternetConnection': 'Pas de connexion Internet',
      'serverError': 'Erreur du serveur',
      'somethingWentWrong': 'Quelque chose s\'est mal passé',
      'tryAgain': 'Réessayer',
      'noDataFound': 'Aucune donnée trouvée',
      'emptyCart': 'Votre panier est vide',
      'emptyFavorites': 'Aucun favori pour le moment',
      'emptyOrders': 'Aucune commande pour le moment',
      'emptyNotifications': 'Aucune notification',
      'emptyWallet': 'Portefeuille vide',
      'emptyWalletHistory': 'Aucun historique de portefeuille',
      'noAddresses': 'Aucune adresse',
      'noPaymentMethods': 'Aucune méthode de paiement',
      'noReviews': 'Aucun avis pour le moment',
      'noProducts': 'Aucun produit trouvé',
      'noCategories': 'Aucune catégorie',
      'noBrands': 'Aucune marque',
      'noSearchResults': 'Aucun résultat de recherche',
      'searchResults': 'Résultats de recherche',
      'filter': 'Filtrer',
      'sort': 'Trier',
      'clear': 'Effacer',
      'apply': 'Appliquer',
      'reset': 'Réinitialiser',
      'all': 'Tous',
      'none': 'Aucun',
      'selectAll': 'Tout sélectionner',
      'deselectAll': 'Tout désélectionner',
      'selected': 'Sélectionné',
      'unselected': 'Non sélectionné',
      'required': 'Requis',
      'optional': 'Optionnel',
      'yes': 'Oui',
      'no': 'Non',
      'ok': 'OK',
      'done': 'Terminé',
      'skip': 'Passer',
      'continue': 'Continuer',
      'finish': 'Terminer',
      'start': 'Commencer',
      'stop': 'Arrêter',
      'pause': 'Pause',
      'resume': 'Reprendre',
      'retry': 'Réessayer',
      'refresh': 'Actualiser',
      'reload': 'Recharger',
      'update': 'Mettre à jour',
      'upgrade': 'Mettre à niveau',
      'download': 'Télécharger',
      'upload': 'Téléverser',
      'install': 'Installer',
      'uninstall': 'Désinstaller',
      'enable': 'Activer',
      'disable': 'Désactiver',
      'on': 'Activé',
      'off': 'Désactivé',
      'active': 'Actif',
      'inactive': 'Inactif',
      'online': 'En ligne',
      'offline': 'Hors ligne',
      'connected': 'Connecté',
      'disconnected': 'Déconnecté',
      'available': 'Disponible',
      'unavailable': 'Indisponible',
      'visible': 'Visible',
      'hidden': 'Masqué',
      'public': 'Public',
      'private': 'Privé',
      'draft': 'Brouillon',
      'published': 'Publié',
      'pending': 'En attente',
      'approved': 'Approuvé',
      'rejected': 'Rejeté',
      'expired': 'Expiré',
      'completed': 'Terminé',
      'cancelled': 'Annulé',
      'failed': 'Échoué',
      'processing': 'En cours',
      'shipped': 'Expédié',
      'delivered': 'Livré',
      'returned': 'Retourné',
      'refunded': 'Remboursé',
      'paid': 'Payé',
      'unpaid': 'Impayé',
      'partial': 'Partiel',
      'full': 'Complet',
      'partialRefund': 'Remboursement partiel',
      'fullRefund': 'Remboursement complet',
      'partialPayment': 'Paiement partiel',
      'fullPayment': 'Paiement complet',
      'partialDelivery': 'Livraison partielle',
      'fullDelivery': 'Livraison complète',
      'partialReturn': 'Retour partiel',
      'fullReturn': 'Retour complet',
    },
    'ar': {
      'appTitle': 'أهيا',
      'home': 'الرئيسية',
      'shop': 'المتجر',
      'favorites': 'المفضلة',
      'profile': 'الملف الشخصي',
      'search': 'البحث',
      'searchProducts': 'البحث عن المنتجات...',
      'login': 'تسجيل الدخول',
      'signup': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirm': 'تأكيد',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'edit': 'تعديل',
      'delete': 'حذف',
      'back': 'رجوع',
      'next': 'التالي',
      'previous': 'السابق',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجح',
      'warning': 'تحذير',
      'language': 'اللغة',
      'selectLanguage': 'اختيار اللغة',
      'languageSelection': 'اختيار اللغة',
      'choosePreferredLanguage': 'اختر لغتك المفضلة',
      'selectedLanguage': 'اللغة المختارة:',
      'selectALanguage': 'اختر لغة',
      'settings': 'الإعدادات',
      'notifications': 'الإشعارات',
      'wallet': 'المحفظة',
      'orders': 'الطلبات',
      'help': 'المساعدة',
      'about': 'حول',
      'contact': 'اتصل بنا',
      'logout': 'تسجيل الخروج',
      'price': 'السعر',
      'addToCart': 'أضف إلى السلة',
      'buyNow': 'اشتري الآن',
      'outOfStock': 'نفد المخزون',
      'inStock': 'متوفر',
      'description': 'الوصف',
      'reviews': 'التقييمات',
      'rating': 'التقييم',
      'categories': 'الفئات',
      'popularProducts': 'المنتجات الشائعة',
      'newArrivals': 'وصل حديثاً',
      'bestSellers': 'الأكثر مبيعاً',
      'flashSale': 'تخفيضات سريعة',
      'specialOffer': 'عرض خاص',
      'discount': 'خصم',
      'freeShipping': 'شحن مجاني',
      'total': 'المجموع',
      'subtotal': 'المجموع الفرعي',
      'tax': 'الضريبة',
      'shipping': 'الشحن',
      'checkout': 'الدفع',
      'paymentMethod': 'طريقة الدفع',
      'creditCard': 'بطاقة ائتمان',
      'cashOnDelivery': 'الدفع عند الاستلام',
      'orderPlaced': 'تم الطلب',
      'orderConfirmed': 'تم تأكيد الطلب',
      'orderShipped': 'تم شحن الطلب',
      'orderDelivered': 'تم تسليم الطلب',
      'orderCancelled': 'تم إلغاء الطلب',
      'trackOrder': 'تتبع الطلب',
      'orderHistory': 'تاريخ الطلبات',
      'myOrders': 'طلباتي',
      'myProfile': 'ملفي الشخصي',
      'personalInfo': 'المعلومات الشخصية',
      'address': 'العنوان',
      'phoneNumber': 'رقم الهاتف',
      'dateOfBirth': 'تاريخ الميلاد',
      'gender': 'الجنس',
      'male': 'ذكر',
      'female': 'أنثى',
      'other': 'آخر',
      'privacy': 'الخصوصية',
      'terms': 'الشروط',
      'privacyPolicy': 'سياسة الخصوصية',
      'termsOfService': 'شروط الخدمة',
      'version': 'الإصدار',
      'buildNumber': 'رقم البناء',
      'developer': 'المطور',
      'support': 'الدعم',
      'feedback': 'التعليقات',
      'reportBug': 'الإبلاغ عن خطأ',
      'shareApp': 'مشاركة التطبيق',
      'rateApp': 'تقييم التطبيق',
      'noInternetConnection': 'لا يوجد اتصال بالإنترنت',
      'serverError': 'خطأ في الخادم',
      'somethingWentWrong': 'حدث خطأ ما',
      'tryAgain': 'حاول مرة أخرى',
      'noDataFound': 'لم يتم العثور على بيانات',
      'emptyCart': 'سلة التسوق فارغة',
      'emptyFavorites': 'لا توجد مفضلات بعد',
      'emptyOrders': 'لا توجد طلبات بعد',
      'emptyNotifications': 'لا توجد إشعارات',
      'emptyWallet': 'المحفظة فارغة',
      'emptyWalletHistory': 'لا يوجد تاريخ للمحفظة',
      'noAddresses': 'لا توجد عناوين',
      'noPaymentMethods': 'لا توجد طرق دفع',
      'noReviews': 'لا توجد تقييمات بعد',
      'noProducts': 'لم يتم العثور على منتجات',
      'noCategories': 'لا توجد فئات',
      'noBrands': 'لا توجد علامات تجارية',
      'noSearchResults': 'لا توجد نتائج بحث',
      'searchResults': 'نتائج البحث',
      'filter': 'تصفية',
      'sort': 'ترتيب',
      'clear': 'مسح',
      'apply': 'تطبيق',
      'reset': 'إعادة تعيين',
      'all': 'الكل',
      'none': 'لا شيء',
      'selectAll': 'تحديد الكل',
      'deselectAll': 'إلغاء تحديد الكل',
      'selected': 'محدد',
      'unselected': 'غير محدد',
      'required': 'مطلوب',
      'optional': 'اختياري',
      'yes': 'نعم',
      'no': 'لا',
      'ok': 'موافق',
      'done': 'تم',
      'skip': 'تخطي',
      'continue': 'متابعة',
      'finish': 'إنهاء',
      'start': 'بدء',
      'stop': 'إيقاف',
      'pause': 'إيقاف مؤقت',
      'resume': 'استئناف',
      'retry': 'إعادة المحاولة',
      'refresh': 'تحديث',
      'reload': 'إعادة تحميل',
      'update': 'تحديث',
      'upgrade': 'ترقية',
      'download': 'تحميل',
      'upload': 'رفع',
      'install': 'تثبيت',
      'uninstall': 'إلغاء التثبيت',
      'enable': 'تفعيل',
      'disable': 'إلغاء التفعيل',
      'on': 'مفعل',
      'off': 'معطل',
      'active': 'نشط',
      'inactive': 'غير نشط',
      'online': 'متصل',
      'offline': 'غير متصل',
      'connected': 'متصل',
      'disconnected': 'غير متصل',
      'available': 'متاح',
      'unavailable': 'غير متاح',
      'visible': 'مرئي',
      'hidden': 'مخفي',
      'public': 'عام',
      'private': 'خاص',
      'draft': 'مسودة',
      'published': 'منشور',
      'pending': 'في الانتظار',
      'approved': 'موافق عليه',
      'rejected': 'مرفوض',
      'expired': 'منتهي الصلاحية',
      'completed': 'مكتمل',
      'cancelled': 'ملغي',
      'failed': 'فشل',
      'processing': 'قيد المعالجة',
      'shipped': 'تم الشحن',
      'delivered': 'تم التسليم',
      'returned': 'مرتجع',
      'refunded': 'مسترد',
      'paid': 'مدفوع',
      'unpaid': 'غير مدفوع',
      'partial': 'جزئي',
      'full': 'كامل',
      'partialRefund': 'استرداد جزئي',
      'fullRefund': 'استرداد كامل',
      'partialPayment': 'دفع جزئي',
      'fullPayment': 'دفع كامل',
      'partialDelivery': 'تسليم جزئي',
      'fullDelivery': 'تسليم كامل',
      'partialReturn': 'إرجاع جزئي',
      'fullReturn': 'إرجاع كامل',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
