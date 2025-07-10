import 'package:flutter/material.dart';
import '../models/crypto.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import 'detail_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final ApiService _apiService = ApiService();
  final FavoritesService _favoritesService = FavoritesService();

  
  Future<void> _unfavorite(String coinId) async {
    await _favoritesService.removeFavorite(coinId);
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Portfólio'),
      ),
      
      body: StreamBuilder<Set<String>>(
        stream: _favoritesService.getFavoritesStream(),
        builder: (context, snapshotFavorites) {
          if (snapshotFavorites.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshotFavorites.hasData || snapshotFavorites.data!.isEmpty) {
            return const Center(
              child: Text(
                'Você ainda não favoritou nenhuma moeda.\nToque na estrela (⭐) na tela de ranking.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            );
          }

          final favoriteIds = snapshotFavorites.data!;

          
          return FutureBuilder<List<Crypto>>(
            future: _apiService.getCryptoList(), 
            builder: (context, snapshotCryptos) {
              if (snapshotCryptos.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshotCryptos.hasError) {
                return Center(child: Text('Erro ao carregar dados: ${snapshotCryptos.error}'));
              }
              if (snapshotCryptos.hasData) {                
                final portfolioCryptos = snapshotCryptos.data!
                    .where((crypto) => favoriteIds.contains(crypto.id))
                    .toList();

                if (portfolioCryptos.isEmpty) {
                   return const Center(
                    child: Text(
                      'Seu portfólio está vazio.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {}); 
                  },
                  child: ListView.builder(
                    itemCount: portfolioCryptos.length,
                    itemBuilder: (context, index) {
                      final crypto = portfolioCryptos[index];
                      return _buildCryptoListTile(crypto);
                    },
                  ),
                );
              }
              return const Center(child: Text('Nenhuma criptomoeda encontrada.'));
            },
          );
        },
      ),
    );
  }

  Widget _buildCryptoListTile(Crypto crypto) {
    final priceChangeColor = crypto.priceChangePercentage24h >= 0 ? Colors.green : Colors.red;
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.star), 
            color: Colors.amber,
            onPressed: () => _unfavorite(crypto.id),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[700],
            backgroundImage: (crypto.imageUrl != null && crypto.imageUrl!.isNotEmpty) ? NetworkImage(crypto.imageUrl!) : null,
            child: (crypto.imageUrl == null || crypto.imageUrl!.isEmpty) ? const Icon(Icons.question_mark, size: 24, color: Colors.white70) : null,
          ),
        ],
      ),
      title: Text(crypto.name),
      subtitle: Text('Rank: #${crypto.marketCapRank}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('\$${crypto.currentPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('${crypto.priceChangePercentage24h.toStringAsFixed(2)}%', style: TextStyle(color: priceChangeColor)),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(crypto: crypto)),
        ).then((_) => setState(() {})); 
      },
    );
  }
}