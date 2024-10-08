import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hands_user_app/components/app_widgets.dart';
import 'package:hands_user_app/components/back_widget.dart';
import 'package:hands_user_app/components/empty_error_state_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/chat_message_model.dart';
import 'package:hands_user_app/models/user_data.dart';
import 'package:hands_user_app/provider/networks/firebase_services/notification_service.dart';
import 'package:hands_user_app/provider/screens/chat/components/chat_item_widget.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/configs.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

class UserChatScreen extends StatefulWidget {
  final UserDatas receiverUser;

  UserChatScreen({required this.receiverUser});

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen>
    with WidgetsBindingObserver {
  TextEditingController messageCont = TextEditingController();

  FocusNode messageFocus = FocusNode();

  UserDatas senderUser = UserDatas();

  StreamSubscription? _streamSubscription;

  int isReceiverOnline = 0;

  bool get isReceiverUserOnline => isReceiverOnline == 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    WidgetsBinding.instance.addObserver(this);

    if (widget.receiverUser.uid.validate().isEmpty) {
      await userService
          .getUser(email: widget.receiverUser.email.validate())
          .then((value) {
        widget.receiverUser.uid = value.uid;
      }).catchError((e) {
        log(e.toString());
      });
    }

    senderUser =
        await providerService.getUser(email: appStore.userEmail.validate());

    setState(() {});

    if (await providerService.isReceiverInContacts(
        senderUserId: appStore.uid.validate(),
        receiverUserId: widget.receiverUser.uid.validate())) {
      await providerChatServices
          .setUnReadStatusToTrue(
              senderId: appStore.uid.validate(),
              receiverId: widget.receiverUser.uid.validate())
          .catchError((e) {
        toast(e.toString());
      });

      log("receiver ID ${widget.receiverUser.uid}");
      providerChatServices.setOnlineCount(
          senderId: widget.receiverUser.uid.validate(),
          receiverId: appStore.uid.validate(),
          status: 1);
      //
      _streamSubscription = chatServices
          .isReceiverOnline(
              senderId: appStore.uid.validate(),
              receiverUserId: widget.receiverUser.uid.validate())
          .listen((event) {
        isReceiverOnline = event.isOnline.validate();
        log("=======*=======*=======*=======*=======* Provider $isReceiverOnline =======*=======*=======*=======*=======");
      });
    }
  }

  //region Widget
  Widget _buildChatFieldWidget() {
    return Row(
      children: [
        AppTextField(
          textFieldType: TextFieldType.OTHER,
          controller: messageCont,
          textStyle: primaryTextStyle(),
          minLines: 1,
          onFieldSubmitted: (s) {
            sendMessages();
          },
          focus: messageFocus,
          cursorHeight: 20,
          maxLines: 5,
          cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          decoration: inputDecoration(context).copyWith(
              hintText: languages.lblMessage, hintStyle: secondaryTextStyle()),
        ).expand(),
        8.width,
        Container(
          decoration: boxDecorationDefault(
              borderRadius: radius(80), color: primaryColor),
          child: IconButton(
            icon: Icon(Icons.send, color: Colors.white),
            onPressed: () {
              sendMessages();
            },
          ),
        )
      ],
    );
  }

  //endregion

  //region Methods
  Future<void> sendMessages() async {
    // If Message TextField is Empty.
    if (messageCont.text.trim().isEmpty) {
      messageFocus.requestFocus();
      return;
    }

    // Making Request for sending data to firebase
    ChatMessageModel data = ChatMessageModel();

    data.receiverId = widget.receiverUser.uid;
    data.senderId = appStore.uid;
    data.message = messageCont.text;
    data.isMessageRead = isReceiverOnline == 1;
    data.createdAt = DateTime.now().millisecondsSinceEpoch;
    data.createdAtTime = Timestamp.now();
    data.updatedAtTime = Timestamp.now();
    data.messageType = MessageType.TEXT.name;

    messageCont.clear();

    if (!(await providerService.isReceiverInContacts(
        senderUserId: appStore.uid.validate(),
        receiverUserId: widget.receiverUser.uid.validate()))) {
      log("========Adding To Contacts=========");
      await chatServices.addToContacts(
        senderId: data.senderId,
        receiverId: data.receiverId,
        receiverName: widget.receiverUser.displayName.validate(),
        senderName: senderUser.displayName.validate(),
      );
      _streamSubscription = chatServices
          .isReceiverOnline(
              senderId: appStore.uid.validate(),
              receiverUserId: widget.receiverUser.uid.validate())
          .listen((event) {
        isReceiverOnline = event.isOnline.validate();
        log("=======*=======*=======*=======*=======* User $isReceiverOnline =======*=======*=======*=======*=======");
      });
    }

    await providerChatServices.addMessage(data).then((value) async {
      log("--Message Successfully Added--");

      if (isReceiverOnline != 1) {
        /// Send Notification
        NotificationService()
            .sendPushNotifications(
          appStore.userFullName,
          data.message.validate(),
          // uid: senderUser.uid.validate(),
          // email: senderUser.email.validate(),
          // receiverPlayerId: widget.receiverUser.playerId.validate(),
          // receiverUserId: widget.receiverUser.id.validate().toString(),
          receiverUser: widget.receiverUser,
          senderUserDatas: senderUser,
        )
            .catchError((e) {
          log("Notification Error ${e.toString()}");
        });
      }

      /// Save receiverId to Sender Doc.
      providerService
          .saveToContacts(
              senderId: appStore.uid,
              receiverId: widget.receiverUser.uid.validate())
          .then((value) => log("---ReceiverId to Sender Doc.---"))
          .catchError((e) {
        log(e.toString());
      });

      /// Save senderId to Receiver Doc.
      providerService
          .saveToContacts(
              senderId: widget.receiverUser.uid.validate(),
              receiverId: appStore.uid)
          .then((value) => log("---SenderId to Receiver Doc.---"))
          .catchError((e) {
        log(e.toString());
      });

      /// ENd
    }).catchError((e) {
      log(e.toString());
    });
  }

  //endregion

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.detached) {
      providerChatServices.setOnlineCount(
          senderId: widget.receiverUser.uid.validate(),
          receiverId: appStore.uid.validate(),
          status: 0);
    }

    if (state == AppLifecycleState.paused) {
      providerChatServices.setOnlineCount(
          senderId: widget.receiverUser.uid.validate(),
          receiverId: appStore.uid.validate(),
          status: 0);
    }
    if (state == AppLifecycleState.resumed) {
      providerChatServices.setOnlineCount(
          senderId: widget.receiverUser.uid.validate(),
          receiverId: appStore.uid.validate(),
          status: 1);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    providerChatServices.setOnlineCount(
        senderId: widget.receiverUser.uid.validate(),
        receiverId: appStore.uid.validate(),
        status: 0);

    _streamSubscription?.cancel();

    setStatusBarColor(transparentColor,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "",
        backWidget: BackWidget(),
        color: context.primaryColor,
        systemUiOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: context.primaryColor,
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light),
        titleWidget: Text(
          widget.receiverUser.firstName.validate() +
              " " +
              widget.receiverUser.lastName.validate(),
          style: boldTextStyle(color: white, size: APP_BAR_TEXT_SIZE),
        ),
        actions: [
          PopupMenuButton(
            onSelected: (index) {
              if (index == 0) {
                showConfirmDialogCustom(
                  context,
                  positiveText: languages.lblYes,
                  negativeText: languages.lblNo,
                  primaryColor: context.primaryColor,
                  title: languages.clearChatMessage,
                  onAccept: (c) async {
                    appStore.setLoading(true);
                    await providerChatServices
                        .clearAllMessages(
                            senderId: appStore.uid,
                            receiverId: widget.receiverUser.uid.validate())
                        .then((value) {
                      toast(languages.chatCleared);
                      hideKeyboard(context);
                    }).catchError((e) {
                      toast(e);
                    });
                    appStore.setLoading(false);
                  },
                );
              }
            },
            icon: Icon(Icons.more_vert_sharp, color: Colors.white),
            color: context.cardColor,
            itemBuilder: (context) {
              List<PopupMenuItem> list = [];
              list.add(
                PopupMenuItem(
                  value: 0,
                  child: Text(languages.clearChat, style: primaryTextStyle()),
                ),
              );
              return list;
            },
          )
        ],
      ),
      body: SizedBox(
        height: context.height(),
        width: context.width(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 80),
              child: FirestorePagination(
                reverse: true,
                isLive: true,
                padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
                physics: BouncingScrollPhysics(),
                query: providerChatServices.chatMessagesWithPagination(
                    senderId: appStore.uid.validate(),
                    receiverUserId: widget.receiverUser.uid.validate()),
                initialLoader: LoaderWidget(),
                limit: PER_PAGE_CHAT_LIST_COUNT,
                onEmpty: NoDataWidget(
                  title: languages.noConversation,
                  imageWidget: EmptyStateWidget(),
                ),
                shrinkWrap: true,
                viewType: ViewType.list,
                itemBuilder: (context, snap, index) {
                  ChatMessageModel data = ChatMessageModel.fromJson(
                      snap.data() as Map<String, dynamic>);
                  data.isMe = data.senderId == appStore.uid;
                  data.chatDocumentReference = snap.reference;

                  return ChatItemWidget(chatItemData: data);
                },
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildChatFieldWidget(),
            )
          ],
        ),
      ),
    );
  }
}
