import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Contribua (dízimos e ofertas) — camada de apresentação apenas.
///
/// NÃO há cobrança, gateway de pagamento nem persistência: a tela apenas
/// apresenta a chave Pix e os dados para a pessoa contribuir pelo app do seu
/// banco. Todos os dados chegam por parâmetro, com PLACEHOLDERS como padrão —
/// o Owner injeta os valores reais na composição (main.dart) quando quiser,
/// sem editar esta tela.
class ContribuaScreen extends StatelessWidget {
  /// Chave Pix (ex.: CNPJ, e-mail, telefone). PLACEHOLDER por padrão.
  final String pixKey;

  /// Tipo da chave, exibido como etiqueta (ex.: "CNPJ", "E-mail").
  final String pixKeyLabel;

  /// Nome do favorecido (titular da conta).
  final String favorecido;

  /// Imagem do QR Code do Pix (asset). Nulo → mostra um espaço reservado.
  final String? qrAsset;

  /// Dados bancários opcionais (quando informados, exibe o bloco).
  final String? banco;
  final String? agencia;
  final String? conta;

  const ContribuaScreen({
    super.key,
    this.pixKey = 'goel.missao@gmail.com',
    this.pixKeyLabel = 'E-mail',
    this.favorecido = 'Goel Church',
    this.qrAsset = 'assets/contribua/qr_pix.png',
    this.banco,
    this.agencia,
    this.conta,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final hasBank = (banco != null && banco!.isNotEmpty);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, topInset + 24, 20, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Intro(),
              const SizedBox(height: 24),
              _PixCard(
                pixKey: pixKey,
                pixKeyLabel: pixKeyLabel,
                favorecido: favorecido,
                onCopy: () => _copy(context, pixKey, 'Chave Pix'),
              ),
              const SizedBox(height: 16),
              _QrCard(qrAsset: qrAsset),
              if (hasBank) ...[
                const SizedBox(height: 16),
                _BankCard(
                  banco: banco!,
                  agencia: agencia,
                  conta: conta,
                  favorecido: favorecido,
                  onCopy: (v, w) => _copy(context, v, w),
                ),
              ],
              const SizedBox(height: 24),
              const _Thanks(),
            ],
          ),
        ),
      ),
    );
  }

  void _copy(BuildContext context, String value, String what) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$what copiada.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.volunteer_activism_outlined,
              size: 32, color: scheme.onPrimaryContainer,),
        ),
        const SizedBox(height: 16),
        Text(
          'Generosidade',
          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Cada um contribua segundo propôs no seu coração; porque Deus ama '
          'a quem dá com alegria.',
          style: textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.45,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '2 Coríntios 9:7',
          style: textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _PixCard extends StatelessWidget {
  final String pixKey;
  final String pixKeyLabel;
  final String favorecido;
  final VoidCallback onCopy;

  const _PixCard({
    required this.pixKey,
    required this.pixKeyLabel,
    required this.favorecido,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pix, size: 22, color: scheme.onSurface),
                const SizedBox(width: 8),
                Text(
                  'Chave Pix',
                  style:
                      textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    pixKeyLabel,
                    style: textTheme.labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                pixKey,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Favorecido: $favorecido',
              style:
                  textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCopy,
              icon: const Icon(Icons.copy),
              label: const Text('Copiar chave'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  final String? qrAsset;
  const _QrCard({required this.qrAsset});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'QR Code Pix',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240, maxHeight: 240),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    // Fundo branco: garante contraste do QR e cantos limpos
                    // (sem "triângulos" escuros ao arredondar as bordas).
                    color: qrAsset == null ? scheme.surfaceContainerHighest : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: qrAsset == null
                      ? _placeholder(context)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            qrAsset!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => _placeholder(context),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Abra o app do seu banco e aponte a câmera na opção Pix.',
              textAlign: TextAlign.center,
              style:
                  textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_2, size: 96, color: scheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            'QR a adicionar',
            style: textTheme.labelMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _BankCard extends StatelessWidget {
  final String banco;
  final String? agencia;
  final String? conta;
  final String favorecido;
  final void Function(String value, String what) onCopy;

  const _BankCard({
    required this.banco,
    required this.agencia,
    required this.conta,
    required this.favorecido,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_outlined,
                    size: 22, color: scheme.onSurface,),
                const SizedBox(width: 8),
                Text(
                  'Dados bancários',
                  style:
                      textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(label: 'Favorecido', value: favorecido, onCopy: onCopy),
            _InfoRow(label: 'Banco', value: banco, onCopy: onCopy),
            if (agencia != null && agencia!.isNotEmpty)
              _InfoRow(label: 'Agência', value: agencia!, onCopy: onCopy),
            if (conta != null && conta!.isNotEmpty)
              _InfoRow(label: 'Conta', value: conta!, onCopy: onCopy),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final void Function(String value, String what) onCopy;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style:
                      textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            tooltip: 'Copiar $label',
            onPressed: () => onCopy(value, label),
          ),
        ],
      ),
    );
  }
}

class _Thanks extends StatelessWidget {
  const _Thanks();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Text(
      'Que Deus abençoe a sua generosidade.',
      textAlign: TextAlign.center,
      style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
    );
  }
}
