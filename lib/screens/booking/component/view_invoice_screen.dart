import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hands_user_app/component/base_scaffold_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_file/open_file.dart';

class ViewInvoiceScreen extends StatefulWidget {
  final String path;

  const ViewInvoiceScreen({super.key, required this.path});

  @override
  State<ViewInvoiceScreen> createState() => _ViewInvoiceScreenState();
}

class _ViewInvoiceScreenState extends State<ViewInvoiceScreen> {
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.invoice,
      child: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false, // if set to true the link is handled in flutter
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {
              print('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              print('page change: $page/$total');
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()
              : Center(
                  child: Text(errorMessage),
                )
        ],
      ),
      floatingActionButton: FutureBuilder<PDFViewController>(
        future: _controller.future,
        builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
          if (snapshot.hasData) {
            return FloatingActionButton.extended(
              backgroundColor: primaryColor,
              label: Text(
                language.showInvoice,
                style: primaryTextStyle(color: white),
              ),
              onPressed: () async {
                // await snapshot.data!.setPage(pages! ~/ 2);
                print('Opening file now...');
                final result = await OpenFile.open(widget.path.toString());
                print('invoice file is ${widget.path}');
                print('Result ${result.message}');
                print('Result ${result.type}');
                print('Result ${result.toString()}');
                if (result.message.isNotEmpty) {
                  print('Error opening file: ${result.message}');
                  // Handle opening error (optional)
                }
              },
            );
          }

          return Container();
        },
      ),
    );
  }
}
