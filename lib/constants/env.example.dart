class Env {
  static const djangoBaseUrl = 
      String.fromEnvironment('DJANGO_BASE_URL', defaultValue: 'YOUR KEY');
  static const fastapiBaseUrl = 
      String.fromEnvironment('FASTAPI_BASE_URL', defaultValue: 'YOUR KEY');
}