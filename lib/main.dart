import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/data/models/case_model.dart';
import 'app/data/models/client_model.dart';
import 'app/data/models/expense_model.dart';
import 'app/data/models/invoice_model.dart';
import 'app/data/models/task_model.dart';
import 'app/data/models/time_entry_model.dart';
import 'app/data/models/user_model.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  await Hive.initFlutter();
  //  await NotificationService.init();
  MobileAds.instance.initialize();
  Hive.registerAdapter(CaseModelAdapter());
  Hive.registerAdapter(ClientModelAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(TimeEntryModelAdapter());
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(InvoiceModelAdapter());
  Hive.registerAdapter(UserModelAdapter());

  await Hive.openBox<InvoiceModel>('invoices');
  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox<CaseModel>('cases');
  await Hive.openBox<ClientModel>('clients');
  await Hive.openBox<TimeEntryModel>('time_entries');
  await Hive.openBox<ExpenseModel>('expenses'); 
  await Hive.openBox<UserModel>('user');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Legal Desk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme, 
      themeMode: ThemeMode.system, 
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
