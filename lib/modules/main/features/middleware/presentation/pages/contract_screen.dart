import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:flutter/material.dart';

class ContractScreen extends StatelessWidget {
  static const routeName = '/contract-screen';
  const ContractScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accord de Financement'),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Accord de Financement de l\'Appareil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            Text(
              'En signant cet Accord de Financement de l\'Appareil (l\'"Accord"), vous, l\'acheteur identifié ci-dessous ("vous" ou "Acheteur"), choisissez d\'acheter l\'appareil associé au numéro IMEI identifié ci-dessus ${sl<MainDataProvider>().getDeviceID} (l\'"Appareil") à crédit selon les termes divulgués dans cet accord. Vous acceptez de payer Smart Information Exchange, une société sud-africaine ("nous" ou "SIX"), le montant financé en dollars américains selon le calendrier de paiement ci-dessus.',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            const Text(
              'Termes Importants',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Les parties conviennent de résoudre tout différend pouvant survenir dans le cadre de cet Accord via le service client de SIX. En cas d\'échec, les différends seront résolus par arbitrage contraignant à Anchorage, Alaska.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '2. "Vous" ou "Acheteur" désigne un individu ou une entité commerciale. Si l\'Acheteur est une entité commerciale, la personne signant cet Accord garantit qu\'elle est autorisée à le faire.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '3. Nous vous fournirons un relevé mensuel indiquant les paiements dus et appliqués. Après le paiement final, un relevé final sera délivré.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '4. Vous pouvez payer le montant total dû à tout moment avant la date de paiement finale prévue.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '5. Vous assumez tous les risques de perte, vol ou dommage de l\'Appareil pendant toute la durée de cet Accord. Nous recommandons de souscrire une assurance ou une protection pour l\'Appareil.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '6. Défaut : Vous serez en défaut si vous ne respectez pas les termes de cet Accord, notamment en cas de non-paiement ou de violation des garanties.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '7. Recours en cas de défaut : En cas de défaut, nous pouvons désactiver l\'Appareil, exiger le paiement immédiat du solde restant, et recouvrer les frais raisonnables de recouvrement.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '8. Cession : Nous pouvons céder cet Accord sans votre consentement. Vous ne pouvez pas céder cet Accord sans notre consentement écrit préalable.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '9. Droit applicable : Cet Accord est régi par les lois de la Guinée.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '10. Langue anglaise : La version originale de cet Accord est en anglais. En cas de conflit, la version anglaise prévaut.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '11. Exclusion de garanties : Nous ne faisons aucune garantie, expresse ou implicite, concernant l\'Appareil. Les garanties sont celles des fabricants tiers.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '12. Indemnité : Vous êtes responsable de toutes les pertes ou dommages directement attribuables à vous ou à vos actes ou omissions pendant que l\'Appareil est en votre possession.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            const Text(
              'Avis à l\'Acheteur :',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Ne signez pas cet Accord avant de l\'avoir lu ou s\'il contient des espaces vides.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '2. Vous avez droit à une copie exacte et complète de l\'Accord que vous signez.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '3. Vous avez le droit de rembourser à l\'avance le montant total dû à tout moment.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '4. Cet Accord est régi par les lois de la Guinée.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '5. Tout détenteur de ce contrat est soumis à toutes les réclamations et défenses que le débiteur pourrait opposer au vendeur des biens ou services obtenus.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '6. Le taux de financement n\'excède pas 0% par an, calculé mensuellement.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            const Text(
              '7. Vous devez maintenir un plan de service vocal et/ou de données actif tant qu\'il reste un solde dû en vertu de cet Accord.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            const Text(
              'En signant cet Accord, vous reconnaissez avoir lu cet Accord et en avoir reçu une copie.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            const Text(
              'SIX : Smart Information Exchange',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
