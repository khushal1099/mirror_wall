import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mirror_wall/controller/provider/bookmark_provider.dart';
import 'package:mirror_wall/controller/provider/connectivity_provider.dart';
import 'package:provider/provider.dart';

class MyWebView extends StatefulWidget {
  final String url;

  const MyWebView({super.key, required this.url});

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  bool? isBookmark;
  String? namelist;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
          pullToRefreshController?.endRefreshing();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Web View"),
        actions: [
          PopupMenuButton(
            constraints: const BoxConstraints.expand(height: 110, width: 200),
            offset: const Offset(30, 50),
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(Icons.bookmark_add_outlined),
                        SizedBox(
                          width: 10,
                        ),
                        Text("BookMark"),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(Icons.screen_search_desktop_outlined),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Search Engine"),
                      ],
                    ),
                  ),
                ),
              ];
            },
            onSelected: (value) {
              if (value == 1) {
                showModalBottomSheet(
                  isScrollControlled: true,
                  isDismissible: false,
                  context: context,
                  builder: (context) {
                    return Container(
                      height: MediaQuery.sizeOf(context).height * 0.9,
                      color: Colors.white,
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 50,
                              color: Colors.grey,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.close),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Dismiss",
                                      style: TextStyle(fontSize: 23),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Consumer<BookMarkProvider>(
                                builder: (context, bookmarkprovider, child) {
                              return ListView.separated(
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text("Hello"),
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return Divider();
                                  },
                                  itemCount:
                                      bookmarkprovider.sitenamelist.length);
                            }),
                          )
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer<ConnectivityProvider>(
            builder: (context, ConnectivityProvider, child) {
              if (ConnectivityProvider.progress >= 1) {
                return SizedBox.shrink();
              }
              return LinearProgressIndicator(
                minHeight: 8,
                value: ConnectivityProvider.progress,
                color: Colors.yellow,
              );
            },
          ),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              pullToRefreshController: pullToRefreshController,
              onLoadStop: (controller, url) async {
                var canGoBack = await controller.canGoBack();
                var canGoForward = await controller.canGoForward();
                print("mounted $mounted");

                if (mounted) {
                  Provider.of<ConnectivityProvider>(context, listen: false)
                      .backForwardStatus(canGoBack, canGoForward);
                }

                print("canGoBack $canGoBack");
              },
              onProgressChanged: (controller, progress) {
                Provider.of<ConnectivityProvider>(context, listen: false)
                    .changeProgress(progress / 100);
                print("progress => $progress");
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.all(10),
                border:
                    OutlineInputBorder(), // enabledBorder: InputBorder.none,
              ),
              onFieldSubmitted: (value) {
                var searchtext = "https://www.google.com/search?q=$value";
                webViewController?.loadUrl(
                  urlRequest: URLRequest(
                    url: WebUri(searchtext),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Consumer2<ConnectivityProvider, BookMarkProvider>(builder:
              (context, connectivityprovider, bookmarkprovider, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            MyWebView(url: "https://www.google.com"),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.home_filled,
                    size: 30,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    namelist = webViewController.toString();
                    bookmarkprovider.addBookmark(namelist!);
                    print(bookmarkprovider.sitenamelist.length);
                  },
                  icon: bookmarkprovider.isBookmark
                      ? Icon(
                          Icons.bookmark,
                          size: 30,
                        )
                      : Icon(
                          Icons.bookmark_add_outlined,
                          size: 30,
                        ),
                ),
                IconButton(
                  onPressed: () {
                    webViewController?.goBack();
                  },
                  icon: connectivityprovider.canGoBack
                      ? Icon(
                          Icons.arrow_back_ios,
                          size: 30,
                        )
                      : Icon(
                          Icons.arrow_back_ios,
                          size: 30,
                          color: Colors.black12,
                        ),
                ),
                IconButton(
                  onPressed: () {
                    webViewController?.reload();
                  },
                  icon: Icon(
                    Icons.refresh_sharp,
                    size: 30,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    webViewController?.goForward();
                  },
                  icon: connectivityprovider.canGoForward
                      ? Icon(
                          Icons.arrow_forward_ios,
                          size: 30,
                        )
                      : Icon(
                          Icons.arrow_forward_ios,
                          size: 30,
                          color: Colors.black12,
                        ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
