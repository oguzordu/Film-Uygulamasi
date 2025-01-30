import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final List<String> imageUrls; // Tüm görsellerin URL'leri
  final int initialIndex; // Başlangıçtaki görselin indeks numarası

  // FullScreenImagePage constructor
  const FullScreenImagePage({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Arka plan siyah olacak
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar şeffaf olacak
        elevation: 0, // AppBar'ın gölgesini kaldırıyoruz
        actions: [
          Padding(
            padding: const EdgeInsets.only(
                top: 10.0, right: 20.0), // Biraz aşağı kaydırdık
            child: IconButton(
              icon: const Icon(Icons.close),
              color: Colors.white, // Kapama butonu beyaz olacak
              iconSize: 35.0, // Daha büyük yapmak için iconSize'ı artırdık
              onPressed: () => Navigator.pop(context), // Geri gitmek için
            ),
          ),
        ],
      ),
      body: Center(
        child: PageView.builder(
          itemCount: imageUrls.length, // Fotoğraf sayısı kadar sayfa var
          controller: PageController(
              initialPage: initialIndex), // Başlangıçtaki görseli ayarla
          itemBuilder: (context, index) {
            return InteractiveViewer(
              child: Image.network(imageUrls[index],
                  fit: BoxFit.contain), // Full screen görseli göster
            );
          },
        ),
      ),
    );
  }
}
