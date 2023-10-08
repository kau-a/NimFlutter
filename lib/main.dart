import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(NimGame());
}

class NimGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text('Jogo Nim'),
          actions: <Widget>[
            Text(
              'KAUÃ OLIVEIRA DE SOUZA - 1431432312014',
              style: TextStyle(
                fontSize: 30.0,
              ),
            )
          ],
        ),
        body: NIM(),
      ),
    );
  }
}

class NIM extends StatefulWidget {
  @override
  _NIMGameState createState() => _NIMGameState();
}

class _NIMGameState extends State<NIM> {
  int numeromaxpecas = 0;
  int numerosmaxpecasrem = 0;
  int pecasRestantes = 0;
  int pecasRetiradas = 0;
  int pecasIAretiradas = 0;
  String errorTextNumeroMaximo = '';
  String errorTextNumeroRetiradas = '';
  bool isGameStarted = false;
  bool jogadorComeca = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Coloque o número máximo de peças e o número de peças que podem ser retiradas por jogada:',
            textAlign: TextAlign.center,
          ),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              setState(() {
                numeromaxpecas = int.tryParse(value) ?? 0;
                if (numeromaxpecas < 2) {
                  errorTextNumeroMaximo = 'Mínimo de 2 peças';
                } else {
                  errorTextNumeroMaximo = '';
                }
                pecasRestantes = numeromaxpecas;
              });
            },
            decoration: InputDecoration(
              labelText: 'Número máximo de peças',
              errorText: (isGameStarted || errorTextNumeroMaximo.isNotEmpty)
                  ? errorTextNumeroMaximo
                  : null,
            ),
          ),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              setState(() {
                numerosmaxpecasrem = int.tryParse(value) ?? 0;
                if (numerosmaxpecasrem < 1) {
                  errorTextNumeroRetiradas = 'O mínimo de peças a retirar é 1';
                } else if (numerosmaxpecasrem > pecasRestantes) {
                  errorTextNumeroRetiradas = 'Número inválido';
                } else {
                  errorTextNumeroRetiradas = '';
                }
              });
            },
            decoration: InputDecoration(
              labelText: 'Número máximo de peças a retirar',
              errorText: (isGameStarted || errorTextNumeroRetiradas.isNotEmpty)
                  ? errorTextNumeroRetiradas
                  : null,
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              if (errorTextNumeroMaximo.isEmpty &&
                  errorTextNumeroRetiradas.isEmpty &&
                  numeromaxpecas > 0 &&
                  numerosmaxpecasrem > 0) {
                isGameStarted = true;
                jogadorComeca =
                    (numeromaxpecas % (numerosmaxpecasrem + 1)) == 0;
                _showInformacoesDialog(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple, 
            ),
            child: Text('Começar Partida'),
            
          ),
        ],
      ),
    );
  }

  void _showInformacoesDialog(BuildContext context) {
    if (!jogadorComeca) {
      _computadorMove();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Número restante de peças: $pecasRestantes'),
                  if (!jogadorComeca)
                    Text(
                        'O computador começou e retirou $pecasIAretiradas peças.'),
                  SizedBox(height: 16.0),
                  Text('Retirar Quantidade de Peças:'),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List.generate(
                      pecasRestantes > numerosmaxpecasrem
                          ? numerosmaxpecasrem
                          : pecasRestantes,
                      (index) {
                        int pecasARetirar = index + 1;
                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              pecasRetiradas = pecasARetirar;
                              pecasRestantes -= pecasARetirar;

                              if (pecasRestantes <= 0) {
                                _showDerrotaDialog(context);
                                return;
                              }

                              _computadorMove();

                              if (pecasRestantes <= 0) {
                                _showVitoriaDialog(context, false);
                              }
                            });

                            _showQuantidadePecasRetiradasDialog(context);
                          },
                          child: Text('$pecasARetirar'),
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _computadorMove() {
    int diferenca = pecasRestantes % (numerosmaxpecasrem + 1);
    int pecasARetirar = 0;
    if (diferenca == 0 || diferenca == 1) {
      pecasARetirar = max(1, numerosmaxpecasrem);
    } else {
      pecasARetirar = diferenca - 1;
    }
    pecasRestantes -= pecasARetirar;
    pecasIAretiradas = pecasARetirar;
  }

  void _showDerrotaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Você Perdeu!'),
          content: Text('Você retirou a última peça.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Recomecar()),
                );
              },
              child: Text('Reiniciar'),
            ),
          ],
        );
      },
    );
  }

  void _showQuantidadePecasRetiradasDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Quantidade de Peças Retiradas'),
          content: Text('Você retirou $pecasRetiradas peças.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (pecasRestantes > 0) {
                  _showMensagemDoComputador(context);
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showMensagemDoComputador(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Mensagem do Computador'),
          content: Text('O computador retirou $pecasIAretiradas peças.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (pecasRestantes <= 0) {
                  _showVitoriaDialog(context, true);
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showVitoriaDialog(BuildContext context, bool computadorVenceu) {
    String titulo = computadorVenceu ? 'Você Perdeu!' : 'Você venceu!';
    String conteudo = computadorVenceu
        ? 'O computador retirou a última peça.'
        : 'Voçê venceu!!';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(conteudo),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Recomecar()),
                );
              },
              child: Text('Reiniciar'),
            ),
          ],
        );
      },
    );
  }
}

class Recomecar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text('Jogo Nim'),
        actions: <Widget>[
            Text(
              'KAUÃ OLIVEIRA DE SOUZA - 1431432312014',
              style: TextStyle(
                fontSize: 30.0,
              ),
            )
          ],
        ),
        body: NIM(),
      ),
    );
  }
}
