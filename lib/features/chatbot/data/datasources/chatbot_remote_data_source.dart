import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../features/home/data/models/product_model.dart';
import '../../presentation/controllers/chatbot_controller.dart';

class ChatbotRemoteDataSource {
  final ApiClient apiClient;

  ChatbotRemoteDataSource(this.apiClient);

  Future<ChatMessage> sendMessage(String message, String userId, String sessionId) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.chatMessage,
        data: {
          'message': message,
          'userId': userId,
          'sessionId': sessionId,
        },
        options: Options(validateStatus: (status) => true),
      );
      
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['success'] == true && data['data'] != null) {
          final responseData = data['data'];
          final text = responseData['text'] ?? 'No reply received.';
          
          List<ProductModel>? recommendedProducts;
          if (responseData['recommendedProducts'] != null && responseData['recommendedProducts'] is List) {
            final List productsList = responseData['recommendedProducts'];
            recommendedProducts = productsList.map((p) => ProductModel.fromJson(p)).toList();
          }
          
          return ChatMessage(
            text: text,
            isUser: false,
            recommendedProducts: recommendedProducts,
          );
        } else {
          return ChatMessage(
            text: data['message'] ?? 'Sorry, I am unable to process your request at the moment.',
            isUser: false,
          );
        }
      }
      return ChatMessage(
        text: 'Sorry, I am unable to process your request at the moment.',
        isUser: false,
      );
    } catch (e) {
      return ChatMessage(
        text: 'Connection error. Please try again later.',
        isUser: false,
      );
    }
  }
}
