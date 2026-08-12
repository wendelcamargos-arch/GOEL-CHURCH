import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:goel_domain/goel_domain.dart';

/// Metadados de um plano (do index).
class PlanoMeta {
  final String id;
  final String nome;
  final String descricao;
  final int dias;
  const PlanoMeta({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.dias,
  });
}

/// Um plano completo: cada dia é uma lista de referências (capítulos).
class Plano {
  final String id;
  final String nome;
  final String descricao;
  final List<List<VerseRef>> dias; // dias[d-1] = leituras do dia d
  const Plano({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.dias,
  });

  int get totalDias => dias.length;
}

/// Carrega os planos de leitura offline (assets/biblia/planos).
class PlanoRepository {
  static const _dir = 'assets/biblia/planos';

  Future<List<PlanoMeta>> listar() async {
    final raw = await rootBundle.loadString('$_dir/index.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return [
      for (final m in (data['planos'] as List).cast<Map<String, dynamic>>())
        PlanoMeta(
          id: m['id'] as String,
          nome: m['nome'] as String,
          descricao: m['descricao'] as String,
          dias: (m['dias'] as num).toInt(),
        ),
    ];
  }

  Future<Plano> carregar(String id) async {
    final raw = await rootBundle.loadString('$_dir/$id.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final leituras = (data['leituras'] as List)
        .map((dia) => (dia as List)
            .map((ch) => VerseRef.fromChave(ch as String))
            .whereType<VerseRef>()
            .toList(),)
        .toList();
    return Plano(
      id: data['id'] as String,
      nome: data['nome'] as String,
      descricao: data['descricao'] as String,
      dias: leituras,
    );
  }
}
