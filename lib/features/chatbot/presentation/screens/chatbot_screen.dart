import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../controllers/chatbot_controller.dart';
import 'package:lottie/lottie.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatbotController());
    final textController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        title: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Lottie.network(
                'https://assets2.lottiefiles.com/packages/lf20_q5pk6p1k.json',
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.support_agent, color: Colors.white),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ushu AI Assistant', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Online', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.md),
                itemCount: controller.messages.length + (controller.isLoading.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.messages.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: AppDimensions.md, right: 60),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16).copyWith(topLeft: const Radius.circular(4)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: const SizedBox(
                          width: 40,
                          child: LinearProgressIndicator(color: AppColors.primaryPurple),
                        ),
                      ),
                    );
                  }

                  final message = controller.messages[index];
                  return Align(
                    alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.only(
                        bottom: AppDimensions.md,
                        left: message.isUser ? 60 : 0,
                        right: message.isUser ? 0 : 60,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: message.isUser ? AppColors.primaryPurple : AppColors.white,
                        borderRadius: BorderRadius.circular(16).copyWith(
                          bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(16),
                          topLeft: !message.isUser ? const Radius.circular(4) : const Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : AppColors.darkText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: const TextStyle(color: AppColors.hintText, fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.lightBackground,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Obx(() => GestureDetector(
                      onTap: controller.isLoading.value
                          ? null
                          : () {
                              controller.sendMessage(textController.text);
                              textController.clear();
                            },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: controller.isLoading.value ? Colors.grey : AppColors.primaryPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
