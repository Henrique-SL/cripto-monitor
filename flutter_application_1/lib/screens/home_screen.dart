import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadFavorites(); 
    _fetchData();

    _searchController.addListener(_filterCryptos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _favoritesService.getFavorites();
    setState(() {
      _favoriteIds = favorites.toSet();
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final cryptos = await _apiService.getCryptoList();
      setState(() {
        _allCryptos = cryptos;
        _filteredCryptos = cryptos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
    if (_favoriteIds.contains(coinId)) {
      await _favoritesService.removeFavorite(coinId);
    } else {
      await _favoritesService.addFavorite(coinId);
    }    
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {    
    const Color corLaranja = Color(0xFFF4A921);
    final Color corFundoBusca = Colors.grey[850]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking de Moedas'),
        backgroundColor: corLaranja,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome...',
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () { _searchController.clear(); },
                      )
                    : null,
                filled: true,
                fillColor: corFundoBusca,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
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
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [          
          IconButton(            
            icon: Icon(isFavorite ? Icons.star : Icons.star_outline),            
            color: isFavorite ? Colors.amber : Colors.white54,
            onPressed: () {
              
              _toggleFavorite(crypto.id);
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          alertIcon,
          Column(
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