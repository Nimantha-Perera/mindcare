import 'package:flutter/material.dart';
import 'package:mindcare/presentation/pages/chatbot/viewmodals/chat_view_model.dart';
import 'package:provider/provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, _) {
        return PopupMenuButton<String>(
          icon: Icon(
            Icons.language,
            color: Colors.white,
            size: 20,
          ),
          onSelected: (String language) {
            viewModel.setLanguage(language);
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'auto',
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 18),
                  SizedBox(width: 8),
                  Text('Auto Detect'),
                  if (viewModel.selectedLanguage == 'auto')
                    Spacer(),
                  if (viewModel.selectedLanguage == 'auto')
                    Icon(Icons.check, size: 16, color: Color(0xFF008F76)),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'english',
              child: Row(
                children: [
                  Text('🇺🇸', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('English'),
                  if (viewModel.selectedLanguage == 'english')
                    Spacer(),
                  if (viewModel.selectedLanguage == 'english')
                    Icon(Icons.check, size: 16, color: Color(0xFF008F76)),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'sinhala',
              child: Row(
                children: [
                  Text('🇱🇰', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('සිංහල'),
                  if (viewModel.selectedLanguage == 'sinhala')
                    Spacer(),
                  if (viewModel.selectedLanguage == 'sinhala')
                    Icon(Icons.check, size: 16, color: Color(0xFF008F76)),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'tamil',
              child: Row(
                children: [
                  Text('🇱🇰', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('தமிழ்'),
                  if (viewModel.selectedLanguage == 'tamil')
                    Spacer(),
                  if (viewModel.selectedLanguage == 'tamil')
                    Icon(Icons.check, size: 16, color: Color(0xFF008F76)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}