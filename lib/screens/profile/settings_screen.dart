import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _showUpdatePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Şifre Güncelle", style: TextStyle(color: Colors.black)),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Yeni Şifre"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              _updatePassword(_passwordController.text.trim());
            },
            child: const Text("Güncelle"),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePassword(String newPassword) async {
    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Şifre en az 6 karakter olmalı.")));
      return;
    }

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    String? error = await authService.updatePassword(newPassword);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Şifre başarıyla güncellendi.")));
        _passwordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ayarlar")),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: Colors.white.withOpacity(0.05),
                  child: ListTile(
                    leading: const Icon(Icons.lock_outline, color: Colors.white70),
                    title: const Text("Şifre Değiştir", style: TextStyle(color: Colors.white)),
                    subtitle: const Text("Hesap şifrenizi güncelleyin", style: TextStyle(color: Colors.white54)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                    onTap: _showUpdatePasswordDialog,
                  ),
                ),
                const SizedBox(height: 12),
                 Card(
                  color: Colors.white.withOpacity(0.05),
                  child: ListTile(
                    leading: const Icon(Icons.info_outline, color: Colors.white70),
                    title: const Text("Hakkında", style: TextStyle(color: Colors.white)),
                    subtitle: const Text("EcoTrack v1.0.0", style: TextStyle(color: Colors.white54)),
                  ),
                ),
              ],
            ),
    );
  }
}
