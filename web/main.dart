import 'package:angular/angular.dart';

import 'package:pikaday_datepicker_angular/pikaday_datepicker_angular.dart';

void main() {
  bootstrapStatic(AppComponent);
}

// example app to showcase the PikadayComponent.
@Component(
    selector: 'showcase-pikadate-component',
    template: '''
<pikaday [(day)]="selectedDay" format="DD-MM-YYYY"
          firstDay="1" minDate="2010-1-1" maxDate="2025-12-31"
          placeholder="select a day" showDayOnInit="true">
</pikaday>
<div>selectedDay: {{selectedDay | date}}</div>
<br>
<br>
<pikaday-inline 
    [(day)]="selectedDayInline" format="DD-MM-YYYY"
    firstDay="1" 
    placeholder="select a day" showDayOnInit="true">
</pikaday-inline>
<div>selectedDay: {{selectedDayInline | date}}</div>
<br>
<br>
<input #inputRef/>
<pikaday-inline 
    [(day)]="selectedDayInlineLinked" format="DD-MM-YYYY"
    [linkedInput]="inputRef"
    firstDay="1" 
    placeholder="select a day" showDayOnInit="true">
</pikaday-inline>
<div>selectedDay: {{selectedDayInlineLinked | date}}</div>
<button (click)="clear()">clear</button>
                 ''',
    directives: const [PikadayComponent, PikadayInlineDirective],
    pipes: const [commonPipes])
class AppComponent {
  DateTime selectedDay = new DateTime(2015, 2, 1);
  DateTime selectedDayInline = new DateTime(2015, 2, 1);
  DateTime selectedDayInlineLinked = new DateTime(2015, 2, 1);

  void clear() {
    selectedDay = null;
    selectedDayInline = null;
    selectedDayInlineLinked = null;
  }
}
