class AppRoles {
  static const String admin = 'admin';
  static const String user = 'user';
  
  // Helper to check if a value is a customer/user role
  static bool isUser(String? role) {
    if (role == null) return true;
    final r = role.toLowerCase();
    return r == user || r == 'customer' || r == 'ग्राहक' || r == 'ગ્રાહક' || r == 'ग्राहक'; // Marathi uses same script as Hindi mostly, but good to check.
  }

  // Helper to check if a value is a seller/admin role
  static bool isAdmin(String? role) {
    if (role == null) return false;
    final r = role.toLowerCase();
    return r == admin || r == 'seller' || r == 'vendor' || r == 'विक्रेता' || r == 'વિક્રેતા' || r == 'विक्रेता';
  }
}
