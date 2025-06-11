import 'package:shared_preferences/shared_preferences.dart';
class FavoritesService {
  static const _favoritesKey = 'favoriteCryptos';

  // Pega a lista de IDs de moedas favoritas
  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  // Adiciona uma moeda aos favoritos
  Future<void> addFavorite(String coinId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = await getFavorites();
    if (!favorites.contains(coinId)) {
      favorites.add(coinId);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  // Remove uma moeda dos favoritos
  Future<void> removeFavorite(String coinId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = await getFavorites();
    if (favorites.contains(coinId)) {
      favorites.remove(coinId);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  // Verifica se uma moeda específica é favorita
  Future<bool> isFavorite(String coinId) async {
    List<String> favorites = await getFavorites();
    return favorites.contains(coinId);
  }
}
