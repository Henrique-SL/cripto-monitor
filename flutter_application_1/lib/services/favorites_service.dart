import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class FavoritesService {
  final _portfoliosCollection = FirebaseFirestore.instance.collection('portfolios');
  final FirebaseAuth _auth = FirebaseAuth.instance; // Pega a instância do Auth

  // Pega o ID do usuário atualmente logado. Se não houver, retorna nulo.
  String? get _userId => _auth.currentUser?.uid;

  // Ouve as mudanças nos favoritos do usuário LOGADO
  Stream<Set<String>> getFavoritesStream() {
    final userId = _userId;
    if (userId == null) {
      // Se não há usuário logado, retorna um stream vazio.
      return Stream.value(<String>{});
    }
    return _portfoliosCollection.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return <String>{};
      }
      final List<dynamic> favoriteIds = snapshot.data()!['favorite_ids'] ?? [];
      return favoriteIds.map((id) => id.toString()).toSet();
    });
  }

  // Adiciona um favorito para o usuário LOGADO
  Future<void> addFavorite(String coinId) async {
    final userId = _userId;
    if (userId == null) return; // Não faz nada se não houver usuário

    await _portfoliosCollection.doc(userId).set({
      'favorite_ids': FieldValue.arrayUnion([coinId])
    }, SetOptions(merge: true));
  }

  // Remove um favorito do usuário LOGADO
  Future<void> removeFavorite(String coinId) async {
    final userId = _userId;
    if (userId == null) return; // Não faz nada se não houver usuário

    await _portfoliosCollection.doc(userId).update({
      'favorite_ids': FieldValue.arrayRemove([coinId])
    });
  }
}