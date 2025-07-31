import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  Future<String> getChatResponse(String userMessage) async {
    try {
      final String apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
      

      final model = GenerativeModel(model: "gemini-1.5-pro", apiKey: apiKey);

      final content = [Content.text(userMessage)];
      final response = await model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      } else {
        return "Die KI konnte keine Antwort generieren.";
      }
    } catch (e ) {
      if (e is GenerativeAIException) {
        return "API-Fehler: ${e.message}";
      } else {
        return "Unerwarteter Fehler. Bitte überprüfe die Verbindung.";
      }
    }
  }
}
