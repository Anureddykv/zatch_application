import 'package:flutter/material.dart';
import 'package:zatch_app/model/login_response.dart';
import 'package:zatch_app/model/user_profile_response.dart';
import 'package:zatch_app/view/cart_screen.dart';
import 'package:zatch_app/view/search_view/search_screen.dart';

import '../view/setting_view/profile_screen.dart';

class HeaderWidget extends StatelessWidget {
  UserProfileResponse? userProfile;
  final VoidCallback? onSearchTap;


  HeaderWidget(this.userProfile, {super.key,this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Color(0xFFD0FB52),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hello, Zatcher 👋',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(userProfile),
                      ),
                    );
                  },
                    child: Text(
                      userProfile?.user.username ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.bookmark_border,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(userProfile),
                        ),
                      );                    },
                  ),
                  IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_none,
                          color: Colors.black,
                        ),
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            height: 8,
                            width: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notification');
                    },
                  ),
                  IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.black,
                        ),
                        Positioned(
                          right: -2,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CartScreen(),
                        ),
                      );                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          GestureDetector(
            onTap: onSearchTap
            ,
            child: AbsorbPointer(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    hintText: 'Search Products or People...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
