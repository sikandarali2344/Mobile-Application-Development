import 'package:flutter_test/flutter_test.dart';

import 'package:second_flutter_app/main.dart';

void main() {
  testWidgets('App starts on the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialDarkMode: false));

    expect(find.text('Quran App'), findsOneWidget);
    expect(find.text('Read • Reflect • Renew'), findsOneWidget);
  });
}
