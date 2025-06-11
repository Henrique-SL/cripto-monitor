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
  late Future<List<Crypto>> _portfolioFuture;

  @override
  void initState() {
    super.initState();
    _portfolioFuture = _loadPortfolio();
  }

  Future<List<Crypto>> _loadPortfolio() async {
    // 1. Pega os IDs das moedas favoritas salvas
    final favoriteIds = await _favoritesService.getFavorites();

    // Se não houver favoritos, retorna uma lista vazia
    if (favoriteIds.isEmpty) {
      return [];
    }

    // 2. Busca a lista completa de moedas da API
    final allCryptos = await _apiService.getCryptoList();

    // 3. Filtra a lista completa, mantendo apenas os favoritos
    final portfolioCryptos = allCryptos.where((crypto) {
      return favoriteIds.contains(crypto.id);
    }).toList();

    return portfolioCryptos;
  }

  @override
  Widget build(BuildContext context) {
    const Color corLaranja = Color(0xFFF4A921);
    final Color corFundoBusca = Colors.grey[850]!;
        
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Portfólio'),
        backgroundColor: corLaranja,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Crypto>>(
        future: _portfolioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final portfolioCryptos = snapshot.data!;           
            return ListView.builder(
              itemCount: portfolioCryptos.length,
              itemBuilder: (context, index) {
                final crypto = portfolioCryptos[index];               
                return _buildCryptoListTile(crypto);
              },
            );
          }
          // Se não houver favoritos ou a lista estiver vazia
          return const Center(
            child: Text(
              'Você ainda não adicionou moedas favoritas.\nToque na estrela (⭐) na tela de ranking.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
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
            onPressed: () async {              
              await _favoritesService.removeFavorite(crypto.id);
              setState(() {
                _portfolioFuture = _loadPortfolio();
              });
            },
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
          Text(
            '\$${crypto.currentPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '${crypto.priceChangePercentage24h.toStringAsFixed(2)}%',
            style: TextStyle(color: priceChangeColor),
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(crypto: crypto)),
        ).then((_) {      
          
          setState(() {
            _portfolioFuture = _loadPortfolio();
          });
        });
      },
    );
  }
}