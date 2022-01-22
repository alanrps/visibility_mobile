import 'dart:async';
import 'package:location/location.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_visibility/models/marker.dart';
import 'package:app_visibility/routes/routes.dart';

class FormCreateMark extends StatefulWidget {
  @override
  _FormCreateMark createState() => _FormCreateMark();
}

class _FormCreateMark extends State<FormCreateMark> {
  Dio dio = new Dio();
  Marker marker = new Marker();
  bool _inProgress = false;
  String baseUrl = "https://visibility-production-api.herokuapp.com";
  bool _isValid = true;
  String _dropDownErrorMarkerType;
  String _dropDownErrorAcessibilityType;
  String _dropDownErrorCategory;
  String _dropDownErrorSpaceType;

  @override
  void initState() {
    super.initState();
  }

  Future<LocationData> _getCurrentUserLocation() async {
    final LocationData location = await Location().getLocation();

    return location;
  }

  String _selectedAcessibilityType;
  Map<String, String> accessibilityTypes = {
    'Acessível': 'ACCESSIBLE',
    'Não acessível': 'NOT ACCESSIBLE',
    'Parcialmente': 'PARTIALLY'
  };

  String _selectedMarkerType;
  Map<String, String> markerTypes = {
    'Lugar': 'PLACE',
    'Vaga de cadeirante': 'WHEELCHAIR_PARKING'
  };

  String _selectedScapeType;
  Map<String, String> spaceTypes = {'Privado': 'PRIVATE', 'Público': 'PUBLIC'};

  String _selectedCategory;
  Map<String, String> categories = {
    'Viagem': 'TRAVEL',
    'Transporte': 'TRANSPORT',
    'Supermercado': 'SUPERMARKET',
    'Serviços': 'SERVICES',
    'Lazer': 'LEISURE',
    'Educação': 'EDUCATION',
    'Alimentação': 'FOOD',
    'Hospitais': 'HOSPITALS',
    'Hospedagem': 'ACCOMMODATION',
  };

  void _setPosition(double latitude, double longitude) {
    setState(() {
      marker.latitude = latitude;
      marker.longitude = longitude;
    });
  }

  // talvez adicionar verificação para quando estiver falso e passar para true
  _verifyDropDownMarkerType() {
    if (_selectedMarkerType != null && _dropDownErrorMarkerType != null) {
      setState(() {
        _dropDownErrorMarkerType = '';
        _isValid = true;
      });
    }
    if (_selectedMarkerType == null) {
      setState(() {
        _dropDownErrorMarkerType = "Por Favor, Selecione um Local";
        _isValid = false;
      });
    }
  }

  _verifyDropDownAcessibilityType() {
    if (_selectedAcessibilityType != null &&
        _dropDownErrorAcessibilityType != null) {
      setState(() {
        _dropDownErrorAcessibilityType = '';
        _isValid = true;
      });
    }
    if (_selectedAcessibilityType == null) {
      setState(() {
        _dropDownErrorAcessibilityType =
            "Por Favor, Selecione o Nível de acessibilidade";
        _isValid = false;
      });
    }
  }

  _verifyDropDownCategory() {
    if (_selectedCategory != null && _dropDownErrorCategory != null) {
      setState(() {
        _dropDownErrorCategory = '';
        _isValid = true;
      });
    }
    if (_selectedCategory == null) {
      setState(() {
        _dropDownErrorCategory = "Por Favor, Selecione a Categoria";
        _isValid = false;
      });
    }
  }

  _verifyDropDownSpaceType() {
    if (_selectedScapeType != null && _dropDownErrorSpaceType != null) {
      setState(() {
        _dropDownErrorSpaceType = '';
        _isValid = true;
      });
    }
    if (_selectedScapeType == null) {
      setState(() {
        _dropDownErrorSpaceType = "Por Favor, Selecione o Tipo de Espaço";
        _isValid = false;
      });
    }
  }

  final _formKey = GlobalKey<FormState>();

  void _submitForm() async {
    _verifyDropDownMarkerType();

    if (_selectedMarkerType != null && _selectedMarkerType == 'PLACE') {
      _verifyDropDownAcessibilityType();
      _verifyDropDownCategory();
      _verifyDropDownSpaceType();
    }

    print("deu não");
    print(_isValid);

    if (_isValid && _formKey.currentState.validate()) {
      marker.typeMarker = markerTypes[_selectedMarkerType];
      marker.category = categories[_selectedCategory];
      marker.spaceType = spaceTypes[_selectedScapeType];
      _formKey.currentState.save();

      if (marker.typeMarker != '') {
        marker.classify = accessibilityTypes[_selectedAcessibilityType];
      }

      final markerData = {
        'marker': {
          'markers_type_id': marker.typeMarker,
          'category_id': marker.category,
        },
        'point_data': {
          'latitude': marker.latitude,
          'longitude': marker.longitude
        },
      };

      if (marker.typeMarker == 'PLACE') {
        markerData.addAll({
          'place': {
            'name': marker.name,
            'classify': marker.classify,
            'description': marker.description,
            'space_type': marker.spaceType,
          }
        });
      }

      try {
        final String url = '$baseUrl/markers';
        await dio.post(url, data: markerData);
      } catch (e) {
        print(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Marcação Adicionada com sucesso!'),
        duration: Duration(seconds: 2),
      ));
      Navigator.pushNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context).settings.arguments as Map;

    if (arguments != null) {
      print(arguments['latitude']);
      print(arguments['longitude']);

      _setPosition(arguments['latitude'], arguments['longitude']);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Localização'),
        backgroundColor: Colors.yellow[700],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
              child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          style: (arguments != null || marker.latitude != null)
                              ? TextButton.styleFrom(
                                  primary: Colors.black,
                                  backgroundColor: Colors.grey,
                                  elevation: 0,
                                  padding: const EdgeInsets.all(12),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                )
                              : TextButton.styleFrom(
                                  primary: Colors.black,
                                  backgroundColor: Colors.yellow[700],
                                  elevation: 0,
                                  padding: const EdgeInsets.all(12),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                          child: Text(
                            "Selecionar Localização",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 13),
                          ),
                          onPressed:
                              (arguments != null || marker.latitude != null)
                                  ? null
                                  : () {
                                      Navigator.of(context)
                                          .pushNamed(AppRoutes.MAP);
                                    },
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        TextButton(
                          style: (arguments != null || marker.latitude != null)
                              ? TextButton.styleFrom(
                                  primary: Colors.black,
                                  backgroundColor: Colors.grey,
                                  elevation: 0,
                                  padding: const EdgeInsets.all(12),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                )
                              : TextButton.styleFrom(
                                  primary: Colors.black,
                                  backgroundColor: Colors.yellow[700],
                                  elevation: 0,
                                  padding: const EdgeInsets.all(12),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                          child: Text(
                            "Usar Localização atual",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 13),
                          ),
                          onPressed: (arguments != null ||
                                  marker.latitude != null)
                              ? null
                              : () async {
                                  setState(() {
                                    _inProgress = true;
                                  });

                                  LocationData location =
                                      await this._getCurrentUserLocation();

                                  _setPosition(
                                      location.latitude, location.longitude);

                                  setState(() {
                                    _inProgress = false;
                                  });
                                },
                        ),
                      ],
                    ),
                    if (_inProgress != false) ...[
                      SizedBox(
                        height: 20,
                      ),
                      CircularProgressIndicator(
                        color: Colors.black,
                        value: null,
                      )
                    ],
                    SizedBox(
                      height: 20,
                    ),
                    if (arguments != null || marker.latitude != null) ...[
                      DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedMarkerType,
                          style: TextStyle(color: Colors.black),
                          underline: Container(
                            height: 2,
                            color: Colors.yellow,
                          ),
                          onChanged: (String selectedMarkerType) {
                            setState(() {
                              _selectedMarkerType = selectedMarkerType;
                            });
                          },
                          hint: Text(
                            "Tipo de local",
                            style: TextStyle(color: Colors.black),
                          ),
                          items:
                              (markerTypes.keys).toList().map((String items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Text(items),
                            );
                          }).toList()),
                      _dropDownErrorMarkerType == null
                          ? SizedBox.shrink()
                          : Text(
                              _dropDownErrorMarkerType ?? "",
                              style: TextStyle(color: Colors.red),
                            ),
                      if (_selectedMarkerType == 'Lugar') ...[
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          autofocus: true,
                          keyboardType: TextInputType.name,
                          style:
                              new TextStyle(color: Colors.black, fontSize: 20),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo Obrigatório';
                            }
                            return null;
                          },
                          onSaved: (String newName) =>
                              setState(() => marker.name = newName),
                          // onChanged: (String newName) {
                          //   marker.name = newName;
                          // },
                          decoration: InputDecoration(
                            labelText: "Nome do Lugar",
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          autofocus: true,
                          keyboardType: TextInputType.name,
                          style: new TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo Obrigatório';
                            }
                            return null;
                          },
                          onChanged: (String newDescriptionPlace) {
                            marker.description = newDescriptionPlace;
                          },
                          decoration: InputDecoration(
                            labelText: "Descrição do lugar",
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedAcessibilityType,
                            style: TextStyle(color: Colors.black),
                            underline: Container(
                              height: 2,
                              color: Colors.yellow[700],
                            ),
                            onChanged: (String selectedAcessibleType) {
                              setState(() {
                                _selectedAcessibilityType =
                                    selectedAcessibleType;
                              });
                            },
                            hint: Text(
                              "Nível de acessibilidade",
                              style: TextStyle(color: Colors.black),
                            ),
                            items: (accessibilityTypes.keys)
                                .toList()
                                .map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items),
                              );
                            }).toList()),
                        _dropDownErrorAcessibilityType == null
                            ? SizedBox.shrink()
                            : Text(
                                _dropDownErrorAcessibilityType ?? "",
                                style: TextStyle(color: Colors.red),
                              ),
                        SizedBox(
                          height: 20,
                        ),
                        DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedCategory, //selectedCategory.first,
                            style: TextStyle(color: Colors.black),
                            underline: Container(
                              height: 2,
                              color: Colors.yellow[700],
                            ),
                            onChanged: (String selectedCategory) {
                              print(selectedCategory);

                              setState(() {
                                _selectedCategory = selectedCategory;
                              });
                            },
                            hint: Text(
                              "Categorias",
                              style: TextStyle(color: Colors.black),
                            ),
                            items:
                                (categories.keys).toList().map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items),
                              );
                            }).toList()),
                        _dropDownErrorCategory == null
                            ? SizedBox.shrink()
                            : Text(
                                _dropDownErrorCategory ?? "",
                                style: TextStyle(color: Colors.red),
                              ),
                        SizedBox(
                          height: 20,
                        ),
                        DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedScapeType,
                            style: TextStyle(color: Colors.black),
                            underline: Container(
                              height: 2,
                              color: Colors.yellow[700],
                            ),
                            onChanged: (String selectedSpaceType) {
                              print(selectedSpaceType);

                              setState(() {
                                _selectedScapeType = selectedSpaceType;
                              });
                            },
                            hint: Text(
                              "Tipo de Espaço",
                              style: TextStyle(color: Colors.black),
                            ),
                            items:
                                (spaceTypes.keys).toList().map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items),
                              );
                            }).toList()),
                        _dropDownErrorSpaceType == null
                            ? SizedBox.shrink()
                            : Text(
                                _dropDownErrorSpaceType ?? "",
                                style: TextStyle(color: Colors.red),
                              ),
                      ]
                    ]
                  ],
                ),
              ),
            ),
          )),
          TextButton.icon(
            icon: Icon(Icons.add),
            label: Text('Adicionar'),
            style: TextButton.styleFrom(
              primary: Colors.black,
              backgroundColor: Colors.yellow[700],
              elevation: 0,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: _submitForm,
          ),
        ],
      ),
    );
  }
}
