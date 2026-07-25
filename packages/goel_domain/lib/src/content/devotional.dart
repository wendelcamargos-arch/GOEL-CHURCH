/// Um devocional publicado pela igreja (conteúdo próprio — sem licenciamento
/// externo, diferente do texto bíblico).
class Devotional {
  final String id;
  final String title;
  final String body;
  final DateTime publishedAt;
  final String? author;

  const Devotional({
    required this.id,
    required this.title,
    required this.body,
    required this.publishedAt,
    this.author,
  });
}

/// Contrato de acesso aos devocionais (Stable Module Boundaries).
///
/// Origem: Supabase (leitura pública dos publicados) com fallback offline.
/// O domínio não conhece HTTP nem Supabase.
abstract interface class DevotionalRepository {
  Future<List<Devotional>> list();
}
