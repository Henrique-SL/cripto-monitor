import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../models/crypto.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final FavoritesService _favoritesService = FavoritesService();
  
  List<Crypto> _allCryptos = [];
  List<Crypto> _filteredCryptos = [];
  Set<String> _favoriteIds = {};
  bool _isLoading = true;
  String _error = '';

  final TextEditingController _searchController = TextEditingController();
  StreamSubscription? _favoritesSubscription;

  @override
  void initState() {
    super.initState();
    _listenToFavorites();
    _fetchData();
    _searchController.addListener(_filterCryptos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _favoritesSubscription?.cancel();
    super.dispose();
  }

  void _listenToFavorites() {
    _favoritesSubscription = _favoritesService.getFavoritesStream().listen((favoritesSet) {
      if (mounted) {
        setState(() {
          _favoriteIds = favoritesSet;
        });
      }
    });
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final cryptos = await _apiService.getCryptoList();
      if (mounted) {
        setState(() {
          _allCryptos = cryptos;
          _filteredCryptos = cryptos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _filterCryptos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCryptos = _allCryptos.where((crypto) {
        final nameLower = crypto.name.toLowerCase();
        final symbolLower = crypto.symbol.toLowerCase();
        return nameLower.contains(query) || symbolLower.contains(query);
      }).toList();
    });
  }

  Future<void> _toggleFavorite(String coinId) async {
    final isFavorite = _favoriteIds.contains(coinId);
    if (isFavorite) {
      await _favoritesService.removeFavorite(coinId);
    } else {
      await _favoritesService.addFavorite(coinId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking de Moedas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou símbolo...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(child: Text('Erro: $_error'))
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: _filteredCryptos.length,
                          itemBuilder: (context, index) {
                            final crypto = _filteredCryptos[index];
                            final isFavorite = _favoriteIds.contains(crypto.id);
                            return _buildCryptoListTile(crypto, isFavorite);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoListTile(Crypto crypto, bool isFavorite) {
    final priceChangeColor = crypto.priceChangePercentage24h >= 0 ? Colors.green : Colors.red;
    Widget alertIcon;
    if (crypto.priceChangePercentage24h.abs() > 5) {
      alertIcon = Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Icon(crypto.priceChangePercentage24h > 0 ? Icons.north : Icons.south, color: priceChangeColor, size: 18),
      );
    } else {
      alertIcon = const SizedBox.shrink();
    }
    
    // --- CRIANDO O FORMATADOR CUSTOMIZADO ---
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR', // Usa a formatação brasileira
      symbol: '\$',      // Mas define o símbolo como dólar
    );

    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(isFavorite ? Icons.star : Icons.star_outline),
            color: isFavorite ? Colors.amber : Colors.white54,
            onPressed: () => _toggleFavorite(crypto.id),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[900],
            backgroundImage: (crypto.imageUrl != null && crypto.imageUrl!.isNotEmpty) ? NetworkImage(crypto.imageUrl!) : null,
            child: (crypto.imageUrl == null || crypto.imageUrl!.isEmpty) ? const Icon(Icons.question_mark, size: 24, color: Colors.white70) : null,
          ),
        ],
      ),
      title: Text(crypto.name),
      subtitle: Text('Rank: #${crypto.marketCapRank}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          alertIcon,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                // Aplicando o novo formatador
                currencyFormatter.format(crypto.currentPrice),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              
              Text(
                // A formatação de porcentagem já estava correta
                NumberFormat.decimalPercentPattern(locale: 'pt_BR', decimalDigits: 2).format(crypto.priceChangePercentage24h / 100),
                style: TextStyle(color: priceChangeColor),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(crypto: crypto)),
        );
      },
    );
  }
}