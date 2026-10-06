import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/datasources/chatbot_remote_data_source.dart';
import '../../../../features/home/data/models/product_model.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final List<ProductModel>? recommendedProducts;

  ChatMessage({required this.text, required this.isUser, this.recommendedProducts});
}

class ChatbotController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  late final ChatbotRemoteDataSource _remoteDataSource;
  final String sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';

  @override
  void onInit() {
    super.onInit();
    final apiClient = ApiClient();
    _remoteDataSource = ChatbotRemoteDataSource(apiClient);
    
    // Add initial greeting
    messages.add(ChatMessage(
      text: "Hi there! I'm Ushu's AI Assistant. How can I help you today?", 
      isUser: false
    ));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    messages.add(ChatMessage(text: text, isUser: true));
    isLoading.value = true;

    try {
      final userId = SessionManager.userId ?? '';
      final reply = await _remoteDataSource.sendMessage(text, userId, sessionId);
      messages.add(reply);
    } catch (e) {
      messages.add(ChatMessage(
        text: 'Sorry, I encountered a connection issue. Please try again.',
        isUser: false,
      ));
    } finally {
      isLoading.value = false;
    }
  }
}
