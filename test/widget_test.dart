// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';

void main() {
  testWidgets('App starts test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // BabyBloomApp은 Firebase 초기화가 필요하므로 
    // 실제 위젯 테스트를 위해서는 추가적인 모킹 작업이 필요할 수 있습니다.
    // 여기서는 우선 컴파일 에러 해결을 위해 클래스 이름만 수정합니다.
    await tester.pumpWidget(const BabyBloomApp());

    // 현재 앱에는 '0'이나 '1' 텍스트가 없으므로 아래의 기본 카운터 테스트는 제거하거나 수정해야 합니다.
  });
}
