import 'package:flutter_test/flutter_test.dart';

import 'package:festmap/app.dart';

void main() {
  testWidgets('shows setup when Firebase is not configured', (tester) async {
    await tester.pumpWidget(const FestMapApp(firebaseReady: false));
    expect(find.text('FESTMAP setup'), findsOneWidget);
  });
}
