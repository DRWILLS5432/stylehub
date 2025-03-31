import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:stylehub/screens/specialist_pages/provider/edit_category_provider.dart';
import 'package:stylehub/screens/specialist_pages/provider/language_provider.dart';
import 'package:stylehub/screens/specialist_pages/provider/services_provider.dart';
import 'package:stylehub/screens/specialist_pages/provider/specialist_provider.dart';

final List<SingleChildWidget> changeNotifierProvider = [
  ChangeNotifierProvider<SpecialistProvider>(create: (context) => SpecialistProvider()),
  ChangeNotifierProvider<ServicesProvider>(create: (context) => ServicesProvider()),
  ChangeNotifierProvider<EditCategoryProvider>(create: (context) => EditCategoryProvider()),
  ChangeNotifierProvider<LanguageProvider>(create: (context) => LanguageProvider()),
];
