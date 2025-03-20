import 'package:flutter/material.dart';
import 'package:whispering_time/services/http/base.dart';
import 'package:whispering_time/utils/ui.dart';
import 'package:whispering_time/utils/env.dart';

import 'package:whispering_time/services/sp/sp.dart';
import 'package:whispering_time/services/http/index.dart';

const double iconsize = 25;

class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPage();
}

class _UserPage extends State<UserPage> {
  late Future<UserBasicInfo> _userInfoFuture;
  UserBasicInfo user = UserBasicInfo(
      email: "",
      profile:
          Profile(nickname: "", avatar: Avatar(name: "", url: ""))); // 初始化 user

  @override
  void initState() {
    super.initState();
    _userInfoFuture = init();
  }

  @override
  void didUpdateWidget(covariant UserPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    SP().setIsAutoLogin(false);
  
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserBasicInfo>(
      future: _userInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text("Error loading user info");
        }

        final nickname = snapshot.data?.profile.nickname ?? "";

        return Column(
          spacing: 20,
          children: [

            avatarIcon(),
            Text(
              nickname,
              style: TextStyle(letterSpacing: 2.0),
            ),
          ],
        );
      },
    );
  }



  Future<UserBasicInfo> init() async {
    final value = await Http().userInfo();
    if (value.isNotOK) {
      if (mounted) {
        showErrMsg(context, "服务器连接失败");
        return user;
      }
      return user;
    }
    setState(() {
      user = UserBasicInfo(email: value.email, profile: value.profile);
    });
    return user;
  }

  Widget avatarIcon() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: FutureBuilder<UserBasicInfo>(
                        future: _userInfoFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return const Icon(
                              Icons.error,
                              size: 100,
                              color: Colors.white,
                            );
                          }

                          final avatarUrl = snapshot.data?.profile.avatar.url;
                          return avatarUrl != null
                              ? Image.network(
                                  "${HTTPConfig.indexServerAddress}$avatarUrl",
                                  fit: BoxFit.contain,
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 100,
                                  color: Colors.white,
                                );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        child: FutureBuilder<UserBasicInfo>(
          future: _userInfoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return const CircleAvatar(
                radius: iconsize,
                child: Icon(Icons.person),
              );
            }

            final avatarUrl = snapshot.data?.profile.avatar.url;
            return CircleAvatar(
              radius: iconsize,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(
                      "${HTTPConfig.indexServerAddress}$avatarUrl",
                    )
                  : null,
              child: avatarUrl == null ? const Icon(Icons.person) : null,
            );
          },
        ),
      ),
    );
  }
}
