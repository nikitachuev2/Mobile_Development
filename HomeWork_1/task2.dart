void main() {

  int myAge = 23;

  int myAgeInTenYears = myAge + 10;

  double daysInYear = 365.25;

  double daysPassed = myAgeInTenYears * daysInYear;

  print(
    "Мой возраст $myAge лет. "
    "Через 10 лет, мне будет $myAgeInTenYears лет, "
    "с момента моего рождения пройдет ${daysPassed.toStringAsFixed(2)} дней."
  );
}