import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:goemployee/app/home/api/home_api.dart';
import 'package:goemployee/app/home/bloc/home_bloc.dart';
import 'package:goemployee/goemployee.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _currentUser;
  bool _isLoading = true;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final SessionManager _sessionManager = SessionManager();

  List<DataNotificationModels> notifList = [];

  late HomeBloc _bloc;

  @override
  void initState() {
    super.initState();

    _bloc = HomeBloc(
      homeApi: GetIt.I<HomeApi>(),
    );

    _loadUserData();
  }

  /// =========================================
  /// LOAD USER
  /// =========================================
  Future<void> _loadUserData() async {
    try {
      final User? user = await _dbHelper.getSingleUser();

      if (user != null) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });

        _fetchNotification();
      } else {
        _forceLogout();
      }
    } catch (e) {
      print("HomePage Error: $e");
      _forceLogout();
    }
  }

  /// =========================================
  /// FORCE LOGOUT
  /// =========================================
  Future<void> _forceLogout() async {
    await _dbHelper.deleteCurrentUserAndLogout();

    if (mounted) {
      AppNavigator.offAll(Routes.login);
    }
  }

  /// =========================================
  /// FETCH NOTIFICATION
  /// =========================================
  void _fetchNotification() {
    if (_currentUser == null) return;

    _bloc.add(
      NotificationFetchedEvent(
        userId: _currentUser!.id!,
      ),
    );
  }

  /// =========================================
  /// BUILD
  /// =========================================
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),

        body: BlocConsumer<HomeBloc, HomeState>(
          bloc: _bloc,

          listener: (context, state) {
            if (state is HomePageLoadingState) {
              LoadingDialog.show(
                context,
                message: "Tunggu Sebentar...",
              );
            }

            if (state is GetDataListNotificationSuccessState) {
              notifList.clear();

              setState(() {
                notifList.addAll(
                  state.notificationModel.data!
                      .dataNotificationModels,
                );

                _isLoading = false;
              });

              LoadingDialog.hide(context);
            }

            if (state is HomePageFailedState) {
              LoadingDialog.hide(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Gagal memuat data: ${state.error}',
                  ),
                ),
              );
            }
          },

          builder: (context, state) {
            if (_isLoading) {
              return _buildLoading();
            }

            return _buildHomeContent();
          },
        ),
      ),
    );
  }

  /// =========================================
  /// LOADING
  /// =========================================
  Widget _buildLoading() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0F9D58),
            Color(0xFF34A853),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  /// =========================================
  /// HOME CONTENT
  /// =========================================
  Widget _buildHomeContent() {
    final bool hasPhoto =
        _currentUser!.photo != null && _currentUser!.photo!.isNotEmpty;
    if (_currentUser == null) {
      return const Center(
        child: Text("Gagal memuat data"),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadUserData();
      },

      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            /// =========================================
            /// HEADER
            /// =========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                20,
                30,
                20,
                30,
              ),

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F9D58),
                    Color(0xFF34A853),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),

              child: Column(
                children: [
                  /// TOP BAR
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [

                      /// LOGO
                      Row(
                        children: [

                          Container(
                            padding: const EdgeInsets.all(10),

                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(0.15),

                              borderRadius:
                              BorderRadius.circular(16),
                            ),

                            child: const Icon(
                              Icons.business_center_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              Text(
                                "GoEmployee",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 2),

                              Text(
                                "Employee Management",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      /// ACTIONS
                      Row(
                        children: [

                          /// NOTIFICATION
                          Stack(
                            children: [

                              GestureDetector(
                                onTap: (){
                                  AppNavigator.to(Routes.notificationPage);
                                },
                                child: Container(
                                  padding:
                                  const EdgeInsets.all(10),

                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withOpacity(0.15),

                                    borderRadius:
                                    BorderRadius.circular(
                                        14),
                                  ),

                                  child: const Icon(
                                    Icons.notifications_none,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              if (notifList.isNotEmpty)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 18,
                                    height: 18,

                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius:
                                      BorderRadius.circular(
                                          20),
                                    ),

                                    child: Center(
                                      child: Text(
                                        notifList.length > 9
                                            ? "9+"
                                            : notifList.length
                                            .toString(),

                                        style:
                                        const TextStyle(
                                          color:
                                          Colors.white,
                                          fontSize: 10,
                                          fontWeight:
                                          FontWeight
                                              .bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(width: 10),

                          /// PROFILE
                          GestureDetector(
                            onTap: () {
                              AppNavigator.to(
                                Routes.profilePage,
                              );
                            },

                            child: Container(
                              padding:
                              const EdgeInsets.all(10),

                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.15),

                                borderRadius:
                                BorderRadius.circular(
                                    14),
                              ),

                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  /// USER CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),

                      borderRadius:
                      BorderRadius.circular(24),

                      border: Border.all(
                        color:
                        Colors.white.withOpacity(0.15),
                      ),
                    ),

                    child: Row(
                      children: [

                        /// AVATAR
                        ClipOval(
                          child: hasPhoto
                              ? Image.network(
                            _currentUser!.photo!,
                            width: 84,
                            height: 84,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) {
                              return _buildInitialAvatar(_currentUser!.nama[0]);
                            },
                          )
                              : _buildInitialAvatar(_currentUser!.nama[0]),
                        ),

                        const SizedBox(width: 14),

                        /// USER INFO
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              Text(
                                "Hallo 👋",

                                style: TextStyle(
                                  color: Colors.white
                                      .withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                _currentUser!.nama ?? "-",

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Container(
                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(0.15),

                                  borderRadius:
                                  BorderRadius.circular(
                                      30),
                                ),

                                child: Text(
                                  "${_currentUser!.role} • ${_currentUser!.division}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// =========================================
            /// CONTENT CARD
            /// =========================================
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              child: ContentCardHomePage(
                user: _currentUser!,
              ),
            ),

            const SizedBox(height: 16),

            /// =========================================
            /// MENU GRID
            /// =========================================
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              child: Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: MenuGridWidget(
                  canCheckIn:
                  _currentUser?.timeCheckin ==
                      null ||
                      _currentUser!
                          .timeCheckin!
                          .isEmpty, role: _currentUser!.role,
                ),
              ),
            ),

            const SizedBox(height: 18),

            /// =========================================
            /// NOTIFICATION
            /// =========================================
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    /// TITLE
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: [

                        const Text(
                          "Pemberitahuan",

                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    /// EMPTY STATE
                    if (notifList.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/image/null_notifcation.jpg',
                              width: 140,
                              height: 140,
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "Tidak ada pemberitahuan",

                              style: TextStyle(
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    /// LIST NOTIF
                    if (notifList.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),

                        // 🔥 BATAS MAX 5
                        itemCount: notifList.length > 5 ? 5 : notifList.length,

                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: NotificationCard(
                              notificationModels: notifList[index],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialAvatar(String initials) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade900,
            Colors.green.shade600,
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}