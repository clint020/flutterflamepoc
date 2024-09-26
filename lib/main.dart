import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(game: myGame), // Flame'i mänguelement
            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  myGame.changeDirection();
                },
                child: Text('Change Direction (Blue)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Loome Flame'i mänguklassi instantsi globaalseks kasutamiseks
MyFlameGame myGame = MyFlameGame(numGreenCircles: 30); // Näiteks 5 rohelise ringiga

class GreenCircle {
  double x;
  double y;
  double speed;
  double angle;
  final double radius;

  GreenCircle({
    required this.x,
    required this.y,
    required this.speed,
    required this.angle,
    this.radius = 20,
  });

  // Uuenda ringi asukohta
  void update(double dt) {
    x += speed * cos(angle) * dt;
    y += speed * sin(angle) * dt;
  }
}

class MyFlameGame extends FlameGame {
  // Sinise ringi andmed
  double blueCircleX = 100;
  double blueCircleY = 100;
  double blueSpeed = 100;
  double blueAngle = 0;
  double blueCircleRadius = 30;

  // Rohelised ringid
  List<GreenCircle> greenCircles = [];
  final int numGreenCircles; // Roheliste ringide arv

  MyFlameGame({required this.numGreenCircles}) {
    // Initsialiseerime rohelised ringid suvaliste asukohtade ja liikumissuundadega
    final rand = Random();
    for (int i = 0; i < numGreenCircles; i++) {
      greenCircles.add(GreenCircle(
        x: rand.nextDouble() * 300 + 50,
        y: rand.nextDouble() * 300 + 50,
        speed: rand.nextDouble() * 100 + 50,
        angle: rand.nextDouble() * 2 * pi,
      ));
    }
  }

  // Funktsioon, mis muudab sinise ringi liikumissuunda
  void changeDirection() {
    blueAngle += 30 * pi / 180; // 30 kraadi võrra radiaanides
  }

  // Universaalne funktsioon põrkamise arvutamiseks
  double calculateBounceX(double position, double radius, double angle, double screenSize) {
    if (position > screenSize - radius || position < radius) {
      return pi - angle; // Peegeldame horisontaalselt
    }
    return angle;
  }

  double calculateBounceY(double position, double radius, double angle, double screenSize) {
    if (position > screenSize - radius || position < radius) {
      return -angle; // Peegeldame vertikaalselt
    }
    return angle;
  }

  // Kontrolli, kas kaks ringi põrkuvad
  bool checkCollision(double x1, double y1, double radius1, double x2, double y2, double radius2) {
    double distX = x1 - x2;
    double distY = y1 - y2;
    double distance = sqrt(distX * distX + distY * distY);
    return distance <= radius1 + radius2;
  }

  // Funktsioon, mis arvutab realistliku põrkamise kahe ringi vahel
  void handleCollision(GreenCircle circle1, GreenCircle circle2) {
    double distX = circle2.x - circle1.x;
    double distY = circle2.y - circle1.y;

    // Suuna vektor
    double collisionAngle = atan2(distY, distX);

    // Uued kiirused peale kokkupõrget
    circle1.angle = collisionAngle + pi;
    circle2.angle = collisionAngle;
  }

  // Funktsioon, mis arvutab sinise ja rohelise ringi kokkupõrke
  void handleCollisionWithBlue(GreenCircle circle) {
    double distX = circle.x - blueCircleX;
    double distY = circle.y - blueCircleY;

    // Suuna vektor
    double collisionAngle = atan2(distY, distX);

    // Uued kiirused peale kokkupõrget
    blueAngle = collisionAngle + pi;
    circle.angle = collisionAngle;
  }

  @override
  void update(double dt) {
    // Uuenda sinise ringi asukohta
    blueCircleX += blueSpeed * cos(blueAngle) * dt;
    blueCircleY += blueSpeed * sin(blueAngle) * dt;

    // Kontrolli, kas sinine ring põrkab ekraani servadelt tagasi
    blueAngle = calculateBounceX(blueCircleX, blueCircleRadius, blueAngle, size.x);
    blueAngle = calculateBounceY(blueCircleY, blueCircleRadius, blueAngle, size.y);

    // Uuenda kõikide roheliste ringide asukohti ja põrkamist ekraani servadega
    for (var greenCircle in greenCircles) {
      greenCircle.update(dt);

      // Põrkamine ekraani servadega
      greenCircle.angle = calculateBounceX(greenCircle.x, greenCircle.radius, greenCircle.angle, size.x);
      greenCircle.angle = calculateBounceY(greenCircle.y, greenCircle.radius, greenCircle.angle, size.y);

      // Kontrolli kokkupõrkeid sinise ringiga
      if (checkCollision(blueCircleX, blueCircleY, blueCircleRadius, greenCircle.x, greenCircle.y, greenCircle.radius)) {
        handleCollisionWithBlue(greenCircle);
      }
    }

    // Kontrolli roheliste ringide omavahelist põrkumist
    for (int i = 0; i < greenCircles.length; i++) {
      for (int j = i + 1; j < greenCircles.length; j++) {
        if (checkCollision(greenCircles[i].x, greenCircles[i].y, greenCircles[i].radius,
            greenCircles[j].x, greenCircles[j].y, greenCircles[j].radius)) {
          handleCollision(greenCircles[i], greenCircles[j]);
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Joonistame sinise ringi ekraanile
    final bluePaint = Paint()..color = Colors.blue;
    canvas.drawCircle(Offset(blueCircleX, blueCircleY), blueCircleRadius, bluePaint);

    // Joonistame kõik rohelised ringid ekraanile
    final greenPaint = Paint()..color = Colors.green;
    for (var greenCircle in greenCircles) {
      canvas.drawCircle(Offset(greenCircle.x, greenCircle.y), greenCircle.radius, greenPaint);
    }
  }
}
