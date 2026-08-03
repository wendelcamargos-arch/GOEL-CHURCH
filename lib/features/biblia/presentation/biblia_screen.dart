import 'package:flutter/material.dart';
import 'package:goel_domain/goel_domain.dart';

import '../data/asset_bible_repository.dart';
import '../data/reading_store.dart';
import 'busca_screen.dart';
import 'capitulos_screen.dart';
import 'favoritos_screen.dart';

/// Aba "Bíblia" — lista os 66 livros (Almeida 1911, domínio público), agrupados
/// por Testamento, carregados do manifest via [BibleRepository]. Busca e
/// favoritos no topo; tocar um livro abre os capítulos; o capítulo abre a
/// leitura real.
class BibliaScreen extends StatefulWidget {
  final BibleRepository? repository;
  final ReadingStore? store;
  const BibliaScreen({super.key, this.repository, this.store});

  @override
  State<BibliaScreen> createState() => _BibliaScreenState();
}

class _Dados {
  final List<BibleBookMeta> livros;
  final ReadingStore store;
  _Dados(this.livros, this.store);
}

class _BibliaScreenState extends State<BibliaScreen> {
  late final BibleRepository _repo = widget.repository ?? AssetBibleRepository();
  late final Future<_Dados> _future = _carregar();

  Future<_Dados> _carregar() async {
    final livros = await _repo.livros();
    final store = widget.store ?? await ReadingStore.abrir();
    return _Dados(livros, store);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, topInset + 24, 20, 32),
          children: [
            Text(
              'Bíblia',
              style:
                  textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'A Palavra de Deus, sempre à mão.',
              style:
                  textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FutureBuilder<_Dados>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!snap.hasData || snap.data!.livros.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text('Não foi possível carregar a Bíblia agora.',
                        style: textTheme.titleMedium,),
                  );
                }
                final livros = snap.data!.livros;
                final store = snap.data!.store;
                final at = livros.where((l) => l.isAntigoTestamento).toList();
                final nt = livros.where((l) => !l.isAntigoTestamento).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BuscaBar(repo: _repo, store: store, livros: livros),
                    const SizedBox(height: 10),
                    _FavoritosBar(repo: _repo, store: store, livros: livros),
                    const SizedBox(height: 20),
                    const _SecaoTitulo(texto: 'Antigo Testamento'),
                    const SizedBox(height: 8),
                    for (final l in at)
                      _LivroTile(
                          repo: _repo, store: store, livros: livros, livro: l,),
                    const SizedBox(height: 20),
                    const _SecaoTitulo(texto: 'Novo Testamento'),
                    const SizedBox(height: 8),
                    for (final l in nt)
                      _LivroTile(
                          repo: _repo, store: store, livros: livros, livro: l,),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BuscaBar extends StatelessWidget {
  final BibleRepository repo;
  final ReadingStore store;
  final List<BibleBookMeta> livros;
  const _BuscaBar({required this.repo, required this.store, required this.livros});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Buscar na Bíblia',
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                BuscaScreen(repository: repo, store: store, livros: livros),
          ),
        ),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: scheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Text(
                'Buscar palavra, capítulo ou versículo',
                style: textTheme.bodyLarge
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoritosBar extends StatelessWidget {
  final BibleRepository repo;
  final ReadingStore store;
  final List<BibleBookMeta> livros;
  const _FavoritosBar(
      {required this.repo, required this.store, required this.livros,});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Meus favoritos',
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                FavoritosScreen(repository: repo, store: store, livros: livros),
          ),
        ),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 12),
              Text(
                'Meus favoritos',
                style: textTheme.bodyLarge
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecaoTitulo extends StatelessWidget {
  final String texto;
  const _SecaoTitulo({required this.texto});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      texto,
      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _LivroTile extends StatelessWidget {
  final BibleRepository repo;
  final ReadingStore store;
  final List<BibleBookMeta> livros;
  final BibleBookMeta livro;
  const _LivroTile({
    required this.repo,
    required this.store,
    required this.livros,
    required this.livro,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        label: 'Abrir ${livro.nome}',
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CapitulosScreen(
                  repository: repo,
                  store: store,
                  livros: livros,
                  livro: livro,
                ),
              ),
            ),
            child: SizedBox(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.menu_book_outlined,
                        size: 22, color: scheme.onSurfaceVariant,),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        livro.nome,
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '${livro.totalCapitulos} cap.',
                      style: textTheme.labelMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
