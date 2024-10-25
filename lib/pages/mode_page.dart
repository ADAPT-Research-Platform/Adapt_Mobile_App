import 'package:adapt/utils/app_colors.dart';
import 'package:adapt/widgets/app_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ModePage extends StatefulWidget {
  const ModePage({super.key});

  @override
  _ModePageState createState() => _ModePageState();
}

class _ModePageState extends State<ModePage> {

  final ScrollController _scrollController = ScrollController();

  // Example Markdown content
  final String markdownData =  """
# Biologie der Angst – eine Reise in die faszinierende Welt der Angst

Körperliche Veränderungen sind ein wichtiges Mittel, um uns oder anderen etwas mitzuteilen oder sich an Situationen anzupassen. Der Körper kann anfangen zu schwitzen, wenn die Temperatur warm ist, um nicht zu überhitzen. Andererseits kann der Körper auch mit Schwindel reagieren, weil wir zu wenig getrunken haben. Es kann also viele verschiedene Ursachen geben, warum der Körper andere Reaktionen auslöst. Eine Ursache können Emotionen sein. Es ist insgesamt so, dass jede Emotion mit körperlichen Veränderungen einhergeht. Bei Ekel wird einer Person beispielsweise übel oder bei Scham wird sie rot und fängt an zu Schwitzen. Es ist also ganz normal, dass sich im Körper etwas verändert. Dazu nutzt der Körper verschiedene Teile, um diese Reaktion oder Veränderung möglich zu machen – nämlich unser Nervensystem.

Das Nervensystem ist für die Übertragung von Informationen und die Koordination der Körperfunktionen zuständig. Dabei wird in zwei Teile des Nervensystems unterschieden. Es gibt das somatische Nervensystem, das für alle bewussten Vorgänge in unserem Körper verantwortlich ist und wir willentlich beeinflussen können. Dazu gehören zum Beispiel das Sprechen oder die Bewegung von Armen und Beinen. Daneben gibt es noch das vegetative Nervensystem, das selbstständig und weitestgehend unbeeinflussbar arbeitet. Es ist ständig aktiv und reguliert die inneren Organe, wie zum Beispiel den Herzschlag, die Atmung und den Blutdruck. Dazu gehört auch die Steuerung der Hormone. Dies ist bei Angst insofern relevant, dass der Körper in einen ähnlichen Zustand wie bei Stress versetzt wird und dabei dieselben Stresshormone (Adrenalin, Noradrenalin, Cortisol und Kortison) ausgeschüttet werden. Die Ausschüttung dieser Hormone bewirkt die Veränderung der Körperfunktionen im Sinne der Angst. Dazu wird der Sympathikus aktiviert, ein Teil des vegetativen Nervensystems, der für die Aktivierung und Anspannung des Körpers notwendig ist. Die Blutgefäße werden zusammengezogen, damit sich der Blutdruck erhöht und der Herzschlag wird beschleunigt, damit das Blut schneller durch den Körper fließen kann. Die Bronchien weiten sich und die Atmung wird schneller. Alles, damit der Körper die Muskelgruppen gut durchbluten kann und noch mehr Sauerstoff aufgenommen werden kann, um den Körper auf die benötigte Energie und Kraft vorzubereiten. Andere Funktionen des Körpers wie Hunger, Schlaf oder Darmfunktionen werden für eine Weile heruntergefahren, um Energie zu sparen. Es geht darum, den Körper auf Höchstleistung zu bringen, damit Angriffs- und/oder Fluchtverhalten möglich sind. Dies geschieht in der Regel innerhalb von wenigen Minuten.

![M7](https://firebasestorage.googleapis.com/v0/b/adapt-4703c.appspot.com/o/module_01/excercise_01%2FM1_P7.png?alt=media&token=b6e87e7e-f5db-4c54-92bc-a6ff252a7ed4)

Diese Höchstleistung ist für den Körper anstrengend und kräftezehrend. Daher benötigt der Körper dann Entspannung und Erholung. Dies wird über den Parasympathikus des vegetativen Nervensystems gesteuert. Die Ausschüttung der Stresshormone wird gestoppt. Die Blutgefäße werden wieder geweitet und der Blutdruck senkt sich ab. Der Herzschlag wird verlangsamt. Die Bronchien ziehen sich zusammen, die Atmung wird langsamer. Das Hunger- und Schlafgefühl werden wahrnehmbar, genauso wie die Darmfunktion wieder hochgefahren wird. Selten kann es dann zu Erbrechen, Übelkeit, Durchfall oder Harndrang kommen. Danach folgt häufig ein Gefühl der Erschöpfung, das mit Müdigkeit einhergehen kann. Mit dieser Reaktion versucht der Körper sich wieder in ein Gleichgewicht zu bringen.

![M8](https://firebasestorage.googleapis.com/v0/b/adapt-4703c.appspot.com/o/module_01/excercise_01%2FM1_P8.png?alt=media&token=79a3ed43-3a37-4751-92e4-46fd73b6e267)

Zusammenfassend lässt sich sagen, dass der Körper alle Funktionen und Veränderungen nicht ohne Grund macht, sondern den Körper möglichst gut an die Situation anzupassen versucht und dazu Gefühle als Grund nutzen kann.

""";

  double position = 0;

  void _scroll(double offset) {
    position = position + offset;

    if(position < 0) {
      position = 0;
    }else if(position > _scrollController.position.maxScrollExtent){
      position = _scrollController.position.maxScrollExtent;
    }

    _scrollController.jumpTo(
      position,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTitleBar(title: 'Mode Temp'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: MarkdownBody(
                data: markdownData,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: AppColors.darkYellow, size: 25), // Static color
                  onPressed: () => _scroll(-250),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: AppColors.darkYellow, size: 25), // Static color
                  onPressed: () => _scroll(250),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
