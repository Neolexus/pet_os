abstract class ApiConstants {
  static const String openAIApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String roboflowApiKey = String.fromEnvironment('ROBOFLOW_API_KEY');
  static const String paypalClientId = String.fromEnvironment('PAYPAL_CLIENT_ID');
  
  static const String openAIBaseUrl = 'https://api.openai.com/v1';
  static const String roboflowBaseUrl = 'https://detect.roboflow.com';
  static const String paypalBaseUrl = 'https://api.paypal.com';
}