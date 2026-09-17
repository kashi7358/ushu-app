import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/chatbot_remote_data_source.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatbotController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  late final ChatbotRemoteDataSource _remoteDataSource;

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
      final reply = await _remoteDataSource.sendMessage(text);
      messages.add(ChatMessage(text: reply, isUser: false));
    } finally {
      isLoading.value = false;
    }
  }
}
