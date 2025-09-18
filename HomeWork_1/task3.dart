import 'dart:math' as math;

void main() {
  double ac = 8.0;
  double cb = 6.0;

  double ab = math.sqrt(ac * ac + cb * cb);

  double area = (ac * cb) / 2;

  double perimeter = ac + cb + ab;

  print("Гипотенуза AB = ${ab.toStringAsFixed(2)}");
  print("Площадь S = ${area.toStringAsFixed(2)}");
  print("Периметр P = ${perimeter.toStringAsFixed(2)}");
}