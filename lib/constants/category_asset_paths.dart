class CategoryAssetPaths {
  static const Map<String, String> _categoryImages = {
    'Carpintería': 'assets/images/categories/carpentry.jpg',
    'Plomería': 'assets/images/categories/plumbing.jpg',
    'Pintura': 'assets/images/categories/painting.jpg',
    'Cerrajería': 'assets/images/categories/locksmith.jpg',
    'Electricidad': 'assets/images/categories/electricity.jpg',
    'Aires acondicionados': 'assets/images/categories/air_conditioning.jpg',
    'Jardinería': 'assets/images/categories/gardening.jpg',
    'Mudanzas': 'assets/images/categories/moving.jpg',
    'Limpieza': 'assets/images/categories/cleaning.jpg',
    'Reformas': 'assets/images/categories/renovation.jpg',
  };

  static String? imageForCategory(String category) {
    return _categoryImages[category];
  }
}
