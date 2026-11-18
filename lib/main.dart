import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';

Future<void> main() async {
  await GetStorage.init();
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.LOGIN, //Rota inicial
      getPages: AppPages
          .routes, // Seu array de navegação contendo as rotas e suas pages
    ),
  );
}
