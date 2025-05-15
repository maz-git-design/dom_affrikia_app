import 'package:dom_affrikia_app/core/ui/widgets/affrikia_app_bar.dart';
import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/admin/features/presentation/widgets/admin_view.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/widgets/customer_view.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/errors/bloc/error_bloc.dart';
import '../../../../../../core/ui/widgets/dialog_box.dart';

class AuthenticatedScreen extends StatefulWidget {
  static const routeName = '/authenticated-screen';
  const AuthenticatedScreen({super.key});

  @override
  State<AuthenticatedScreen> createState() => _AuthenticatedScreenState();
}

class _AuthenticatedScreenState extends State<AuthenticatedScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ErrorBloc, ErrorState>(
        listener: (context, state) {
          if (state is Error) {
            //print(state.message);
            sl<DialogBox>().showSnackBar(context, state.message);
          }
        },
        child: Scaffold(
          appBar: const AffrikiaAppBar(),
          body: sl<MainDataProvider>().isAdmin() ? const AdminView() : const CustomerView(),
          resizeToAvoidBottomInset: false,
        ),
      ),
    );
  }
}
