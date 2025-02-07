import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:stylehub/screens/specialist_pages/provider/specialist_provider.dart';

final List<SingleChildWidget> changeNotifierProvider = [
  ChangeNotifierProvider<SpecialistProvider>(create: (context) => SpecialistProvider()),
];
