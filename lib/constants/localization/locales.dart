import 'package:flutter_localization/flutter_localization.dart';

const List<MapLocale> LOCALES = [
  MapLocale('en', LocaleData.EN),
  MapLocale('uk', LocaleData.UK),
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
  static const String forgotPassword = 'Forgot Password?';
  static const String sendOTP = 'Send OTP';
  static const String enterRegisteredEmail = 'Enter Registered Email Address';
  static const String resetPassword = 'Reset Password';
  static const String newPassword = 'Enter New Password';
  static const String confirmNewPassword = 'Confirm New Password';
  static const String emailAddress = 'Email Address';
  static const String resendCode = 'Resend Code';
  static const String confirm = 'Confirm';
  static const String checkEmail = 'Check your email, An OTP wiil be sent to you to reset your password';
  static const String seconds = 'Seconds';
  static const String editProfile = 'Edit Profile';
  static const String logout = 'Logout';
  static const String changePassword = 'Change Password';
  static const String updateService = 'Update Service';
  static const String editProfileDetail = 'Update your profile details';
  static const String updateServiceDetail = 'Update services you render';
  static const String settings = 'Settings';
  static const String updateSettings = 'Update your settings';
  static const String changePhoneLanguage = 'Change your system language';
  static const String category = 'Categories';
  static const String findProfessional = 'Find beauty professionals near you';
  static const String likes = 'Likes';
  static const String appointments = 'Appointments';
  static const String view = 'view';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String wantToCancelAppointment = 'Are you sure you want to cancel your appointment?';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String changeProfilePics = 'Change profile picture';
  static const String personalDetails = 'Personal Details';
  static const String specialistDetails = 'Specialist Details';
  static const String appSettings = 'App Settings';

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
    forgotPassword: 'Forgot Password?',
    sendOTP: 'Send OTP',
    enterRegisteredEmail: 'Enter Registered Email Address',
    resetPassword: 'Reset Password',
    newPassword: 'Enter New Password',
    confirmNewPassword: 'Confirm New Password',
    emailAddress: 'Email Address',
    resendCode: 'Resend Code',
    confirm: 'Confirm',
    checkEmail: 'Check your email, An OTP wiil be sent to you to reset your password',
    seconds: 'Seconds',
    editProfile: 'Edit Profile',
    logout: 'Logout',
    changePassword: 'Change Password',
    updateService: 'Update Service',
    editProfileDetail: 'Update your profile details',
    updateServiceDetail: 'Update services you render',
    settings: 'Settings',
    updateSettings: 'Update your settings',
    changePhoneLanguage: 'Change your system language',
    category: 'Categories',
    findProfessional: 'Find beauty professionals near you',
    likes: 'Likes',
    appointments: 'Appointments',
    view: 'view',
    ok: 'OK',
    cancel: 'Cancel',
    wantToCancelAppointment: 'Are you sure you want to cancel your appointment?',
    yes: 'Yes',
    no: 'No',
    changeProfilePics: 'Change profile picture',
    personalDetails: 'Personal Details',
    specialistDetails: 'Specialist Details',
    appSettings: 'App Settings',
  };

  static const Map<String, dynamic> UK = {
    changeLanguage: 'Виберіть мову',
    find: 'Пошук',
    stylists: 'Стилісти',
    nearYou: 'Поруч з вами',
    next: 'Далі',
    getStarted: 'Почніть',
    createAccount: 'Створити обліковий запис',
    login: 'Увійти',
    email: 'Електронна пошта',
    password: 'Пароль',
    firstName: "Ім'я",
    lastName: 'Прізвище',
    selectRole: 'Оберіть між клієнтом та стилістом',
    register: 'Зареєструватися',
    termsAndConditions: 'Умови використання',
    stylist: 'Стиліст',
    welcomeBack: 'З поверненням',
    customer: 'Клієнт',
    passwordRequired: 'Поле "Пароль" обов’язкове для заповнення',
    firstNameRequired: "Поле 'Ім'я' обов’язкове для заповнення",
    lastNameRequired: "Поле 'Прізвище' обов’язкове для заповнення",
    emailRequired: 'Поле "Електронна пошта" обов’язкове для заповнення',
    emailInvalid: 'Будь ласка, введіть коректну електронну пошту',
    passwordInvalid: 'Пароль повинен містити не менше 6 символів',
    roleRequired: 'Поле "Роль" обов’язкове для заповнення',
    forgotPassword: 'Забули пароль?',
    sendOTP: 'Відправити OTP',
    enterRegisteredEmail: 'Введіть зареєстровану електронну пошту',
    resetPassword: 'Скинути пароль',
    newPassword: 'Введіть новий пароль',
    confirmNewPassword: 'Підтвердіть новий пароль',
    emailAddress: 'Електронна пошта',
    resendCode: 'Надіслати код ще раз',
    confirm: 'Підтвердити',
    checkEmail: 'Перевірте свою електронну пошту, OTP було відправлено вам, щоб скинути ваш пароль',
    seconds: 'Секунд',
    editProfile: 'Редагувати профіль',
    logout: 'Вихід',
    changePassword: 'Змінити пароль',
    updateService: 'Оновити послугу',
    editProfileDetail: 'Оновити деталі профілю',
    updateServiceDetail: 'Оновити послуги, які ви робите',
    settings: 'Налаштування',
    updateSettings: 'Оновити налаштування',
    changePhoneLanguage: 'Змінити мову телефону',
    category: 'Категорії',
    findProfessional: 'Знайти професіоналів бізнесу',
    likes: 'Лайки',
    appointments: 'Записи',
    view: 'переглянути',
    ok: 'OK',
    cancel: 'Скасувати',
    wantToCancelAppointment: 'Ви впевнені, що хочете скасувати запис?',
    yes: 'Так',
    no: 'Ні',
    changeProfilePics: 'Змінити фото профілю',
    personalDetails: 'Персональні деталі',
    specialistDetails: 'Деталі спеціаліста',
    appSettings: 'Налаштування програми',
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
    forgotPassword: 'Забыли пароль?',
    sendOTP: 'Отправить OTP',
    enterRegisteredEmail: 'Введите зарегистрированную электронную почту',
    resetPassword: 'Сбросить пароль',
    newPassword: 'Введите новый пароль',
    confirmNewPassword: 'Подтвердите новый пароль',
    emailAddress: 'Электронная почта',
    resendCode: 'Отправить код повторно',
    confirm: 'Подтвердить',
    checkEmail: 'Проверьте свою электронную почту, OTP был отправлен вам, чтобы сбросить ваш пароль',
    seconds: 'Секунд',
    editProfile: 'Редактировать профиль',
    logout: 'Выход',
    changePassword: 'Изменить пароль',
    updateService: 'Обновить услугу',
    editProfileDetail: 'Обновить детали профиля',
    updateServiceDetail: 'Обновить услуги, которые вы предоставляете',
    settings: 'Настройки',
    updateSettings: 'Обновить настройки',
    changePhoneLanguage: 'Изменить язык телефона',
    category: 'Категории',
    findProfessional: 'Найти профессионалов бизнеса',
    likes: 'Лайки',
    appointments: 'Записи',
    view: 'посмотреть',
    ok: 'OK',
    cancel: 'Отменить',
    wantToCancelAppointment: 'Вы уверены, что хотите отменить запись?',
    yes: 'Да',
    no: 'Нет',
    changeProfilePics: 'Изменить фото профиля',
    personalDetails: 'Персональные данные',
    specialistDetails: 'Детали специалиста',
    appSettings: 'Настройки приложения',
  };
}
