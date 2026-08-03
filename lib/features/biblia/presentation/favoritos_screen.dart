import 'package:flutter/material.dart';
import 'package:goel_domain/goel_domain.dart';

import '../data/reading_store.dart';
import 'leitura_screen.dart';

/// Lista dos versículos favoritados (EU-01). Toca para abrir a leitura.
class FavoritosScreen extends StatefulWidget {
  final BibleRepository repository;
  final ReadingStore store;
  final List<BibleBookMeta> livros;

  const FavoritosScreen({
    super.key,
    required this.repository,
    required this.store,
    required this.livros,
  });

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _Fav {
  final VerseRef ref;
  final String nome;
  final String texto;
  _Fav(this.ref, this.nome, this.texto);
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  late final Future<List<_Fav>> _future = _carregar();

  Future<List<_Fav>> _carregar() async {
    final res = <_Fav>[];
    for (final chave in widget.store.favoritos()) {
      final ref = VerseRef.fromChave(chave);
      if (ref == null || ref.versiculo == null) continue;
      final meta = widget.livros.where((b) => b.id == ref.bookId).firstOrNull;
      if (meta == null) continue;
      var texto = '';
      try {
        final cap = await widget.repository.capitulo(ref.bookId, ref.capitulo);
        if (ref.versiculo! >= 1 && ref.versiculo! <= cap.versiculos.length) {
          texto = cap.versiculos[ref.versiculo! - 1];
        }
      } catch (_) {}
      res.add(_Fav(ref, meta.nome, texto));
    }
    return res.reversed.toList(); // mais recentes primeiro
  }

  void _abrir(VerseRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LeituraScreen(
          repository: widget.repository,
          store: widget.store,
          livros: widget.livros,
          bookId: ref.bookId,
          capitulo: ref.capitulo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: FutureBuilder<List<_Fav>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final favs = snap.data ?? const [];
                if (favs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(28),
                    child: Center(
                      child: Text(
                        'Você ainda não favoritou versículos.\nAbra um capítulo, '
                        'toque em um versículo e escolha "Favoritar".',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: favs.length,
                  itemBuilder: (context, i) {
                    final f = favs[i];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: const Icon(Icons.star, color: Colors.amber),
                        title: Text(
                          '${f.nome} ${f.ref.capitulo}:${f.ref.versiculo}',
                          style: textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        subtitle: f.texto.isEmpty
                            ? null
                            : Text(f.texto,
                                maxLines: 3, overflow: TextOverflow.ellipsis,),
                        onTap: () => _abrir(f.ref),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
