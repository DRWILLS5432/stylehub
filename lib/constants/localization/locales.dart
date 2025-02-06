import 'package:flutter_localization/flutter_localization.dart';

const List<MapLocale> LOCALES = [
  MapLocale('en', LocaleData.EN),
  MapLocale('ar', LocaleData.AR),
  MapLocale('ru', LocaleData.RU),
];

mixin LocaleData {
  static const String changeLanguage = 'Choose your language';
  static const String find = 'Find';
  static const String stylists = 'Stylists';
  static const String stylist = 'Stylist';
  static const String nearYou = 'Near You';
  static const String next = 'Next';
  static const String getStarted = 'Get Started';
  static const String createAccount = 'Create Account';
  static const String login = 'Login';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String selectRole = 'Select between customer and stylist';
  static const String register = 'Register';
  static const String customer = 'Customer';
  static const String termsAndConditions = 'Terms & Conditions apply';
  static const String welcomeBack = 'Welcome Back';
  static const String passwordRequired = 'Password field is required';
  static const String firstNameRequired = 'First name field is required';
  static const String lastNameRequired = 'Last name field is required';
  static const String emailRequired = 'Email field is required';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordInvalid = 'Password must be at least 6 characters';
  static const String roleRequired = 'Role field is required';

// FOR ENGLISH
  static const Map<String, dynamic> EN = {
    changeLanguage: 'Choose your language ',
    find: 'Find',
    stylists: 'Stylists',
    nearYou: 'Near You',
    next: 'Next',
    getStarted: 'Get Started',
    createAccount: 'Create Account',
    login: 'Login',
    email: 'Email',
    password: 'Password',
    firstName: 'First Name',
    lastName: 'Last Name',
    selectRole: 'Select between customer and stylist',
    register: 'Register',
    termsAndConditions: 'Terms & Conditions apply',
    stylist: 'Stylist',
    welcomeBack: 'Welcome Back',
    customer: 'Customer',
    passwordRequired: 'Password field is required',
    firstNameRequired: 'First name field is required',
    lastNameRequired: 'Last name field is required',
    emailRequired: 'Email field is required',
    emailInvalid: 'Please enter a valid email',
    passwordInvalid: 'Password must be at least 6 characters',
    roleRequired: 'Role field is required',
  };

  static const Map<String, dynamic> AR = {
    changeLanguage: 'اختر اللغة ',
    find: 'ابحث',
    stylists: 'استيليستات',
    nearYou: 'قريبا',
    next: 'التالي',
    getStarted: 'ابدأ',
    createAccount: 'انشاء حساب',
    login: 'تسجيل الدخول',
    email: 'البريد الالكتروني',
    password: 'كلمة المرور',
    firstName: 'الاسم الاول',
    lastName: 'الاسم الاخير',
    selectRole: 'اختر بين عميل واستيليست',
    register: 'تسجيل',
    termsAndConditions: 'الشروط والاحكام يتيح',
    stylist: 'استيليست',
    welcomeBack: 'مرحبا بعودتك',
    customer: 'عميل',
    passwordRequired: 'حقل كلمة المرور مطلوب',
    firstNameRequired: 'حقل الاسم الاول مطلوب',
    lastNameRequired: 'حقل الاسم الاخير مطلوب',
    emailRequired: 'حقل البريد الالكتروني مطلوب',
    emailInvalid: 'يرجى ادخال بريد الكتروني صحيح',
    passwordInvalid: 'كلمة المرور يجب ان تكون على الاقل 6 حروف',
    roleRequired: 'حقل الدور مطلوب',
  };

  // FOR RUSSIAN
  static const Map<String, dynamic> RU = {
    changeLanguage: 'Выберите язык  ',
    find: 'Найти',
    stylists: 'Стилисты',
    nearYou: 'Рядом',
    next: 'Далее',
    getStarted: 'Начать',
    createAccount: 'Создать аккаунт',
    login: 'Войти',
    email: 'Электронная почта',
    password: 'Пароль',
    firstName: 'Имя',
    lastName: 'Фамилия',
    selectRole: 'Выберите между клиентом и стилистом',
    register: 'Регистрация',
    termsAndConditions: 'Правила и условия применяются',
    stylist: 'Стилист',
    welcomeBack: 'Добро пожаловать обратно',
    customer: 'Клиент',
    passwordRequired: 'Поле пароля обязательно',
    firstNameRequired: 'Поле имени обязательно',
    lastNameRequired: 'Поле фамилии обязательно',
    emailRequired: 'Поле электронной почты обязательно',
    emailInvalid: 'Пожалуйста, введите действительный адрес электронной почты',
    passwordInvalid: 'Пароль должен содержать не менее 6 символов',
    roleRequired: 'Поле роли обязательно',
  };
}
