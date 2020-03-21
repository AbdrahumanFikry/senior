import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:expandable/expandable.dart';
import '../widgets/qrReader.dart';
import 'package:easy_localization/easy_localization.dart';
import '../sells/testStore.dart';

class ItemTargetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      shrinkWrap: true,
      itemBuilder: (ctx, index) {
        return index == 4
            ? Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      tr('field_force_profile.extra'),
                    ),
                    leading: ClipRRect(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 30.0,
                        )),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QrReader(whereTo: TestStore()),
                        ),
                      );
                    },
                  ),
                  Divider(
                    height: 2,
                    indent: 0,
                    endIndent: 50,
                  )
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: ExpandablePanel(
                  theme: ExpandableThemeData(
                    animationDuration: Duration(milliseconds: 200),
                  ),
                  header: Row(
                    children: <Widget>[
                      Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.0,
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.all(15.0),
                        child: new LinearPercentIndicator(
                          width: 170.0,
                          animation: true,
                          animationDuration: 1000,
                          lineHeight: 20.0,
                          percent: 0.5,
                          center: Text("50.0%"),
                          linearStrokeCap: LinearStrokeCap.butt,
                          progressColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  expanded: Column(
                    children: <Widget>[
                      ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return Column(
                              children: <Widget>[
                                ListTile(
                                  onTap: () {},
                                  subtitle: Row(
                                    children: <Widget>[
                                      Text('150 point'),
                                      Spacer(),
                                    ],
                                  ),
                                  title: Text('Cabury'),
                                ),
                                Divider(
                                  height: 2,
                                )
                              ],
                            );
                          }),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
