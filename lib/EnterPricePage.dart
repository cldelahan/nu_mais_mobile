import 'package:flutter/material.dart';
import 'package:down/DataPage.dart';

class EnterPricePage extends StatefulWidget {

  @override
  _EnterPricePageState createState() => _EnterPricePageState();
}

class _EnterPricePageState extends State<EnterPricePage> {
  TextEditingController priceController = new TextEditingController();

  final _formKey = new GlobalKey<FormState>();

  void validateAndGoToDataPage() {
    if (!_formKey.currentState.validate()) {
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                DataPage(double.parse(priceController.text))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Insira o preço do item ",
              style: Theme.of(context).textTheme.headline4,
            ),
            new Container(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(100.0, 20.0, 100.0, 0.0),
                    child: Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: priceController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Por favor, insira um número";
                            }
                          },
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        )))),
            new RaisedButton(
                onPressed: validateAndGoToDataPage,
                child: Text(
                  "Simular parcelas",
                  style: Theme.of(context).textTheme.headline5,
                ))
          ],
        ),
      ),
    );
  }
}
