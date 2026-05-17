import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:goemployee/app/home/api/home_api.dart';
import 'package:goemployee/app/home/bloc/home_bloc.dart';
import 'package:goemployee/goemployee.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late HomeBloc _bloc;
  User? _currentUser;
  List<DataNotificationModels> notifList = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bloc = HomeBloc(homeApi: GetIt.I<HomeApi>());
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final User? user = await _dbHelper.getSingleUser();

      if (user != null) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });

        _fetch();
      } else {
        _forceLogout();
      }
    } catch (e) {
      print("HomePage Error: $e");
      _forceLogout();
    }
  }

  Future<void> _forceLogout() async {
    await _dbHelper.deleteCurrentUserAndLogout();

    if (mounted) {
      AppNavigator.offAll(Routes.login);
    }
  }

  void _fetch() {
    _bloc.add(NotificationFetchedEvent(
      userId: _currentUser!.id!,
    ),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        title: const Text("Notifikasi", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),

      ),

      body: BlocConsumer<HomeBloc, HomeState>(
        bloc: _bloc,

        listener: (context, state) {
          if (state is GetDataListNotificationSuccessState) {
            setState(() {
              notifList.addAll(
                state.notificationModel.data!
                    .dataNotificationModels,
              );
              _isLoading = false;
            });
          }
        },

        builder: (context, state) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notifList.isEmpty) {
            return const Center(
              child: Text("Tidak ada notifikasi"),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _fetch(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notifList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: NotificationCard(
                    notificationModels: notifList[index],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}