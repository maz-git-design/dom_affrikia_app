import 'package:dom_affrikia_app/core/ui/widgets/dialog_box.dart';
import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/admin/features/presentation/widgets/admin_auth_view.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/widgets/customer_activation.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/widgets/customer_auth_view.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/bloc/navigation/bloc/navigation_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home-screen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      body: BlocConsumer<NavigationBloc, NavigationState>(
        listener: (context, state) {
          if (state is NavigationAdminLogin) {
            sl<DialogBox>().showSnackBar(context, "Vous êtes à présent sur la page d'authentification administrateur.");
          }
        },
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: state is NavigationAdminLogin
                ? const AdminAuthView()
                : state is NavigationCustomerActivation
                    ? const CustomerActivation()
                    : const CustomerAuthView(),
          );
        },
      ),
    );
  }
}
