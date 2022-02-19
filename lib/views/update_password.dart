import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_visibility/models/update_password.dart'
    as updatePasswordModel;

class UpdatePassword extends StatefulWidget {
  @override
  _UpdatePasswordState createState() => new _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  Dio dio = new Dio();
  final _formData = Map<String, Object>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String baseUrl = "https://visibility-production-api.herokuapp.com";

  void _submitForm() async {
    print(_formData);

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatePassword = new updatePasswordModel.UpdatePassword(
          currentPassword: _formData['currentPassword'] as String,
          newPassword: _formData['newPassword'] as String);

      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt('token');

      print(userId);
      print(updatePassword.toJson());

      try {
        String url = '$baseUrl/users/passwords/$userId';

        await dio.patch(url, data: updatePassword.toJson());

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Senha atualizada com sucesso'),
          duration: Duration(seconds: 2),
        ));

        Navigator.pop(context);

      } on DioError catch (error) {
        print(error);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Senhas inválidas"),
                content: Text("Não foi possível atualizar a senha."),
                actions: [
                  TextButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    return Material(
        child: Container(
            padding: EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 0),
            color: Colors.grey[100],
            child: Form(
              key: _formKey,
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  Text(
                    "Redefinir minha senha",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      "Preencha os campos abaixo.",
                      style: const TextStyle(
                          fontSize: 20,
                          decorationStyle: TextDecorationStyle.solid),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 10.0),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo Obrigatório';
                        }
                        return null;
                      },
                      onChanged: (String currentPassword) {
                        _formData['currentPassword'] = currentPassword;
                      },
                      decoration: InputDecoration(
                        labelText: "Digite a senha atual",
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 250),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo Obrigatório';
                        }
                        return null;
                      },
                      onChanged: (String newPassword) {
                        _formData['newPassword'] = newPassword;
                      },
                      decoration: InputDecoration(
                        labelText: "Digite a senha nova",
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.all(12),
                      width: deviceWidth < 200 ? 80 : deviceWidth * 0.4,
                      height: deviceHeight < 500
                          ? 50
                          : deviceHeight > 800
                              ? 80
                              : deviceHeight * 0.09,
                      margin: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton(
                          style: TextButton.styleFrom(
                            primary: Colors.black,
                            backgroundColor: Colors.yellow[700],
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          child: Text("Redefinir senha"),
                          onPressed: _submitForm)),
                ],
              ),
            )));
  }
}
