import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class ChatbotRemoteDataSource {
  final ApiClient apiClient;

  ChatbotRemoteDataSource(this.apiClient);

  Future<String> sendMessage(String message) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.chatMessage,
        data: {'message': message},
        options: Options(validateStatus: (status) => true),
      );
      
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['success'] == true) {
          return data['reply'] ?? 'No reply received.';
        } else {
          return data['message'] ?? 'Sorry, I am unable to process your request at the moment.';
        }
      }
      return 'Sorry, I am unable to process your request at the moment.';
    } catch (e) {
      return 'Connection error. Please try again later.';
    }
  }
}
