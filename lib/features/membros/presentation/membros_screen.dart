import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Um membro da igreja (modelo de apresentação).
class Membro {
  final String nome;
  final String contato; // telefone/WhatsApp exibido
  const Membro(this.nome, this.contato);
}

/// Membros — diretório de membros da Goel Church (nome + contato).
///
/// Camada de apresentação: os membros chegam por parâmetro (com exemplos).
/// Toque no contato abre o WhatsApp. Dado sensível: em produção, exibir só a
/// membros autenticados e conforme consentimento (LGPD).
class MembrosScreen extends StatefulWidget {
  final List<Membro>? membros;
  const MembrosScreen({super.key, this.membros});

  static const _exemplo = <Membro>[
    Membro('Ana Maria Souza', '(11) 90000-0001'),
    Membro('Bruno Lima', '(11) 90000-0002'),
    Membro('Cleuza Ferreira', '(11) 90000-0003'),
    Membro('Davi Nascimento', '(11) 90000-0004'),
    Membro('Ester Rodrigues', '(11) 90000-0005'),
    Membro('João Batista', '(11) 90000-0006'),
    Membro('Marina Alves', '(11) 90000-0007'),
    Membro('Rafael Gomes', '(11) 90000-0008'),
  ];

  @override
  State<MembrosScreen> createState() => _MembrosScreenState();
}

class _MembrosScreenState extends State<MembrosScreen> {
  String _busca = '';

  /// Exporta a lista (nome + telefone) em CSV. Interino: copia para a área de
  /// transferência. O download/exportação de arquivo definitivo (e o controle
  /// de acesso "somente administradores") entram com o backend.
  void _exportar(List<Membro> todos) {
    final csv = StringBuffer('Nome,Telefone\n');
    for (final m in [...todos]..sort((a, b) => a.nome.compareTo(b.nome))) {
      csv.writeln('"${m.nome}","${m.contato}"');
    }
    Clipboard.setData(ClipboardData(text: csv.toString()));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Lista de ${todos.length} membros copiada (CSV).'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final todos = widget.membros ?? MembrosScreen._exemplo;
    final lista = todos
        .where((m) => m.nome.toLowerCase().contains(_busca.toLowerCase()))
        .toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Membros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Baixar lista (administradores)',
            onPressed: () => _exportar(todos),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Icon(Icons.groups_outlined,
                          size: 18, color: scheme.onSurfaceVariant,),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Quem acessa o app já entra na lista de membros. '
                          'Administradores podem baixar (nome + telefone).',
                          style: textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    onChanged: (v) => setState(() => _busca = v),
                    decoration: const InputDecoration(
                      labelText: 'Buscar membro',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: lista.isEmpty
                      ? Center(
                          child: Text('Nenhum membro encontrado.',
                              style: textTheme.titleMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                          itemCount: lista.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) =>
                              _MembroCard(membro: lista[i]),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MembroCard extends StatelessWidget {
  final Membro membro;
  const _MembroCard({required this.membro});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: scheme.primaryContainer, shape: BoxShape.circle,),
              child: Text(
                _iniciais(membro.nome),
                style: textTheme.titleMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    membro.nome,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    membro.contato,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chat_outlined),
              tooltip: 'WhatsApp de ${membro.nome}',
              onPressed: () => _whatsapp(context, membro.contato),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _whatsapp(BuildContext context, String contato) async {
    final digits = contato.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/55$digits');
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('falha');
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Não foi possível abrir o WhatsApp agora.'),
          behavior: SnackBarBehavior.floating,
        ),);
    }
  }
}

String _iniciais(String nome) {
  final p = nome.trim().split(RegExp(r'\s+'));
  if (p.isEmpty || p.first.isEmpty) return '?';
  if (p.length == 1) return p.first[0].toUpperCase();
  return (p.first[0] + p.last[0]).toUpperCase();
}
