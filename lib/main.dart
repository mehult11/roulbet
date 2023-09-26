import 'dart:async';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:vtassignment/colorConst.dart';
import 'package:get/get.dart';
import 'package:vtassignment/keyConst.dart';
import 'package:vtassignment/valueConst.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'RoulBet'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final confettiController = ConfettiController();
  bool isPlaying = false;

  RxInt myAccountCoins = 1000.obs;
  List<Map<String, String>> chipCoinList = [
    {
      KeyConst.coinKey: "100",
      KeyConst.pathKey: "assets/images/100.png",
    },
    {
      KeyConst.coinKey: "200",
      KeyConst.pathKey: "assets/images/200.png",
    },
    {
      KeyConst.coinKey: "500",
      KeyConst.pathKey: "assets/images/500.png",
    },
    {
      KeyConst.coinKey: "1000",
      KeyConst.pathKey: "assets/images/1000.png",
    }
  ];
  int? luckyNumber;
  RxInt betCoin = 0.obs;
  RxBool isClickable = true.obs;
  RxInt selectedChip = 100.obs;
  String? alertDialogueLabel;
  String? alertDialogueDescription;
  String? alertDialogueImage;
  RxMap cardMap = {}.obs;
  bool isViewingHistory1 = false;
  List gameHistory = [];
  static const maxSeconds = 60;
  int seconds = maxSeconds;
  Timer? timer;

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isViewingHistory1) {
        setState(() {
          if (seconds == 0) {
            seconds = maxSeconds;
          } else {
            seconds--;
          }
        });
      }
      if (seconds == 10) {
        isClickable.value = false;
        luckyNumber = Random().nextInt(12);
        if (luckyNumber == 0) {
          luckyNumber = 1;
        }
        print("luckyNumber");
        print(luckyNumber);

        if (cardMap.containsKey(luckyNumber)) {
          int winCoins = int.parse(cardMap[luckyNumber].toString()) * 10;
          myAccountCoins.value = myAccountCoins.value + winCoins;
          // Set data for alert dialogue
          alertDialogueLabel = "Congratulation You Won";
          alertDialogueDescription = "$winCoins Coins";
          alertDialogueImage = "assets/images/win.png";
          // Adding gaming history
          Map<String, dynamic> map = Map<String, dynamic>();
          //"status"
          map[KeyConst.statusKey] = ValueConst.win;
          map[KeyConst.coinKey] = winCoins;
          gameHistory.add(map);
        } else if (betCoin.value == 0) {
          alertDialogueLabel = "You Didn't Bet Any Numbers";
          alertDialogueDescription = "${betCoin.value} Coins";
          alertDialogueImage = "assets/images/didnotbetemoji.png";
        } else {
          // Set data for alert dialogue
          alertDialogueLabel = "Better Luck Next Time";
          alertDialogueDescription = " - ${betCoin.value} Coins";
          alertDialogueImage = "assets/images/lose.png";
          // Adding gaming history
          Map<String, dynamic> map = Map<String, dynamic>();
          map[KeyConst.statusKey] = ValueConst.lose;
          map[KeyConst.coinKey] = betCoin.value;
          gameHistory.add(map);
        }
        displayResultWidget();
      }
      if (seconds == 0) {
        resetGame();
      }
    });
  }

  @override
  void initState() {
    startTimer();
    confettiController.addListener(() {
      setState(() {
        isPlaying = confettiController.state == ConfettiControllerState.playing;
      });
    });
    super.initState();
  }

  resetGame() {
    luckyNumber = null;
    betCoin.value = 0;
    isClickable.value = true;
    selectedChip.value = 100;
    cardMap.value = {};
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Scaffold(
            backgroundColor: ColorConst.appBackgroundColor,
            appBar: AppBar(
              backgroundColor: ColorConst.appBarBackgroundColor,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: ColorConst.appBackgroundColor)),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          isViewingHistory1 = true;
                        });
                        AwesomeDialog(
                            context: context,
                            dialogType: DialogType.noHeader,
                            animType: AnimType.rightSlide,
                            dismissOnTouchOutside: false,
                            btnOkOnPress: () {
                              setState(() {
                                isViewingHistory1 = false;
                              });
                            },
                            body: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text("Game History",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: ColorConst.blackColor)),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.3,
                                    child: (gameHistory.isNotEmpty)
                                        ? ListView.builder(
                                            itemCount: gameHistory.length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              int length = gameHistory.length - 1;
                                              String coin = gameHistory[length - index][KeyConst.coinKey].toString();
                                              String label =(gameHistory[length - index][KeyConst.statusKey] == ValueConst.win)
                                                      ? "You Won"
                                                      : "You Lose";
                                              return Center(
                                                child: Card(
                                                  color: (gameHistory[length - index][KeyConst.statusKey]! == ValueConst.win)
                                                      ? ColorConst.winCardBgColor
                                                      : ColorConst.loseCardBgColor,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                      width: double.infinity,
                                                      child: RichText(
                                                        overflow: TextOverflow.clip,
                                                        text: TextSpan(
                                                          text: label,
                                                          style: DefaultTextStyle.of(context).style,
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                                text: " $coin",
                                                                style: TextStyle(
                                                                    color: (gameHistory[length - index][KeyConst.statusKey]! == ValueConst.win)
                                                                        ? ColorConst.appBackgroundColor
                                                                        : ColorConst.evenTexBgtColor,
                                                                    fontWeight: FontWeight.bold),
                                                            ),
                                                            TextSpan(
                                                              text: " coins",
                                                              style: DefaultTextStyle.of(context).style,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.7,
                                            child: Image.asset(
                                                "assets/images/nodata.png"),
                                          ),
                                  ),
                                ],
                              ),
                            )).show();
                      },
                      icon: Icon(
                        size: 35,
                        Icons.history,
                        color: ColorConst.appBackgroundColor,
                      ))
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  getTimerAndCoinWidget(),
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 10.0,
                    shrinkWrap: true,
                    children: List.generate(
                      12,
                      (index) {
                        return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: GestureDetector(
                              onTap: () {
                                if (isClickable.value) {
                                  // validating amount is valid for bet or not
                                  if (myAccountCoins.value -
                                          selectedChip.value >
                                      -1) {
                                    if (cardMap[index + 1] != null) {
                                      cardMap[index + 1] = cardMap[index + 1] +
                                          selectedChip.value;
                                    } else {
                                      cardMap[index + 1] = selectedChip.value;
                                    }
                                    // deducting betting coin from account balance
                                    myAccountCoins.value -= selectedChip.value;
                                    // Incrementing total bet coin
                                    betCoin += selectedChip.value;
                                  }
                                }
                              },
                              child: Card(
                                color: getIndexColor(index),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        (index + 1).toString(),
                                        style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: ColorConst.cardTextColor),
                                      ),
                                    ),
                                    Obx(
                                      () => Visibility(
                                        visible: (cardMap[index + 1] != null &&
                                                cardMap[index + 1] > 0)
                                            ? true
                                            : false,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                                width: 25,
                                                child: Image.asset(
                                                  "assets/images/coinimage.png",
                                                )),
                                            Text(
                                              (cardMap[index + 1]).toString(),
                                              style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                  color:
                                                      ColorConst.cardTextColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ));
                      },
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  getCoinsWidget(int.parse(chipCoinList[0][KeyConst.coinKey]!),
                      chipCoinList[0][KeyConst.pathKey]!),
                  getCoinsWidget(int.parse(chipCoinList[1][KeyConst.coinKey]!),
                      chipCoinList[1][KeyConst.pathKey]!),
                  getCoinsWidget(int.parse(chipCoinList[2][KeyConst.coinKey]!),
                      chipCoinList[2][KeyConst.pathKey]!),
                  getCoinsWidget(int.parse(chipCoinList[3][KeyConst.coinKey]!),
                      chipCoinList[3][KeyConst.pathKey]!),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
          )
        ],
      ),
    );
  }

  Color getIndexColor(int index) {
    if (index == 0 || (index % 2 == 0)) {
      return ColorConst.evenTexBgtColor;
    } else {
      return ColorConst.oddTextBgColor;
    }
  }

  Widget getCoinsWidget(int coin, String imageLink) {
    return GestureDetector(
      onTap: () {
        if (isClickable.value) {
          selectedChip.value = coin;
        }
      },
      child: Obx(
        () => Container(
            decoration: BoxDecoration(
                color: (selectedChip.value == coin)
                    ? ColorConst.selectedChipColor
                    : ColorConst.appBarBackgroundColor,
                border: Border.all(color: Colors.transparent),
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            child: Row(
              children: [
                SizedBox(
                    width: 35,
                    child: Image.asset(
                      imageLink,
                    )),
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 8.0),
                  child: Text(coin.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: ColorConst.blackColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            )),
      ),
    );
  }

  Widget getTimerAndCoinWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          getTimerWidget(),
          getBetAmtWidget(),
          Container(
              width: 130,
              height: 50,
              decoration: BoxDecoration(
                  color: ColorConst.collectedCoinBgColor,
                  border: Border.all(color: Colors.transparent),
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Row(
                children: [
                  SizedBox(
                      width: 40,
                      child: Image.asset(
                        "assets/images/coinimage.png",
                      )),
                  Obx(
                    () => Text(myAccountCoins.value.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: ColorConst.collectedCoinTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  Widget getBetAmtWidget() {
    return Column(
      children: [
        Text("Your Bet",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: ColorConst.whiteColor,
                fontSize: 20,
                fontWeight: FontWeight.w500)),
        Obx(
          () => Text(betCoin.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: ColorConst.whiteColor,
                  fontSize: 18,
                  fontWeight: FontWeight.normal)),
        ),
      ],
    );
  }

  Widget getTimerWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 60,
        height: 60,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              color: ColorConst.whiteColor,
              backgroundColor: ColorConst.circleColorConst,
              value: seconds / maxSeconds,
              strokeWidth: 10,
            ),
            Center(
              child: Text(
                '$seconds',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  displayResultWidget() {
    // Only Show Confetti when user win the game
    if (gameHistory.isNotEmpty &&
        gameHistory.last[KeyConst.statusKey]! == ValueConst.win &&
        betCoin.value != 0) {
      confettiController.play();
    }
    AwesomeDialog(
        context: context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        autoHide: const Duration(seconds: 10),
        onDismissCallback: (type) {
          confettiController.stop();
        },
        dismissOnTouchOutside: false,
        btnOk: const SizedBox(),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(alertDialogueImage!, width: 100),
            ),
            Text(
              alertDialogueLabel!,
              style: const TextStyle(fontSize: 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/alertdialoguecoins.png", width: 40),
                Text(
                  alertDialogueDescription!,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Lucky Number is "!,
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  luckyNumber.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            )
          ],
        )).show();
  }
}
