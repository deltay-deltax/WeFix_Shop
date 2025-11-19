import 'package:flutter/material.dart';

enum TermsDoc { termsOfUse, privacyPolicy }

// UI-only stub to avoid backend imports
class TermsViewModel extends ChangeNotifier {
  final TermsDoc doc;
  final bool returnToDashboard;
  TermsViewModel({required this.doc, this.returnToDashboard = false});

  bool accepted = false;
  bool declined = false;

  void onAgree(BuildContext context) {
    if (returnToDashboard) return;
    accepted = true;
    declined = false;
    notifyListeners();
    if (doc == TermsDoc.termsOfUse) {
      Navigator.of(context).pushNamed('/privacy');
    } else {
      Navigator.of(context).pushNamed('/register');
    }
  }

  void onDisagree(BuildContext context) {
    accepted = false;
    declined = true;
    notifyListeners();
    Navigator.of(context).maybePop();
  }
}
