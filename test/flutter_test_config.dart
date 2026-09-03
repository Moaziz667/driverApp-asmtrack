import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Chargé automatiquement par `flutter test` pour tous les fichiers de ce dossier.
///
/// Il n'existe que pour rendre les comparaisons golden portables. Une image de référence est un
/// rendu, et un rendu dépend du système qui l'a produit : le lissage des polices n'est pas le même
/// sous Windows, où les références ont été générées, et sous Linux, où tourne l'intégration
/// continue. Le comparateur par défaut refuse le moindre pixel d'écart, si bien qu'un test golden
/// juste échoue dès qu'il change de machine. Flutter documente d'ailleurs que les goldens ne sont
/// pas garantis d'une plateforme à l'autre.
///
/// La tolérance ci-dessous laisse passer cette différence de rendu sans desarmer le test : un vrai
/// changement de mise en page, une couleur ou un libellé déplacé, dépasse largement un pour cent.
/// L'écart observé entre Windows et Linux est de 0,46 %.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final defaut = goldenFileComparator as LocalFileComparator;
  goldenFileComparator = _ComparateurTolerant(defaut.basedir);
  await testMain();
}

class _ComparateurTolerant extends LocalFileComparator {
  _ComparateurTolerant(Uri basedir)
    : super(Uri.parse('$basedir/comparateur_tolerant.dart'));

  /// Un pour cent des pixels. Au-dela, l'echec est reel et le rapport habituel est produit.
  static const double _seuil = 0.01;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final resultat = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (resultat.passed || resultat.diffPercent <= _seuil) {
      resultat.dispose();
      return true;
    }
    final message = await generateFailureOutput(resultat, golden, basedir);
    throw FlutterError(message);
  }
}
