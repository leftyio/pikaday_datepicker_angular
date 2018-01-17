import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:js/js.dart';
import 'package:pikaday/pikaday.dart';
import 'package:pikaday/pikaday_dart_helpers.dart';

import 'conversion.dart';

/// AngularDart component wrapper around the Pikaday-js lib. You will have to
/// link to pikaday.js (Get the latest version from it's
/// [GitHub page](https://github.com/dbushell/Pikaday) and if you want
/// a custom date format (which is highly likable) also to [moment.js](http://momentjs.com/)).
///
/// Attribute documentation adapted from the
/// [pikaday.js documentation](https://github.com/dbushell/Pikaday).
///
/// You can't set a container DOM node nore a callback, but you can listen to
/// dayChange to be informed about selected days (DateTime instances).

@Component(
    selector: 'pikaday',
    template:
        '<input type="text" #input [attr.class]="cssClasses" [attr.placeholder]="placeholder">')
class PikadayComponent extends _PikadayComponentBase {
  /// css-classes to be set on the pikaday-inputfield via <input class="{{cssClasses}}>
  @Input()
  String cssClasses = "";

  /// Sets the placeholder of the pikaday-inputfield.
  @Input()
  String placeholder;

  @ViewChild("input")
  ElementRef inputRef;

  @override
  void ngAfterViewInit() {
    _options.field = inputRef.nativeElement;
    super.ngAfterViewInit();
  }
}

@Component(
    selector: 'pikaday-inline',
    template: '''
    <input type="text" #input hidden/>
    <div [attr.class]="containerClasses" #container></div>
    ''',
    styles: const [":host { display: inline-block}"])
class PikadayInlineDirective extends _PikadayComponentBase {
  /// css-classes to be set on the pikaday-container via <div class="{{containerClasses}}>
  @Input()
  String containerClasses = "";

  @Input("linkedInput")
  var linkedInput;

  @ViewChild("input")
  ElementRef inputRef;

  @ViewChild("container")
  ElementRef containerRef;

  @override
  void ngAfterViewInit() {
    bound = false;
    if (linkedInput is HtmlElement) {
      _options.field = linkedInput;
    } else if (linkedInput is String && linkedInput.isNotEmpty) {
      _options.field = document.getElementById(linkedInput);
    } else {
      _options.field = inputRef.nativeElement;
    }
    _options.container = containerRef.nativeElement;
    super.ngAfterViewInit();
  }
}

abstract class _PikadayComponentBase implements AfterViewInit {
  Pikaday _pikaday;
  final PikadayOptions _options = new PikadayOptions();

  bool get _isInitPhase => _pikaday == null;

  /// Emits selected dates.
  final _dayChange = new StreamController<DateTime>();

  @Output()
  Stream<DateTime> get dayChange => _dayChange.stream;

  /// Combines [PikadayOptions.defaultDate] with [PikadayOptions.setDefaultDate]. Look there for more info.
  @Input()
  void set day(DateTime day) {
    if (_isInitPhase) {
      _options.defaultDate = day;
      _options.setDefaultDate = day != null;
    } else {
      if (day == null) {
        _pikaday.setDate(null);
      } else {
        final dayMillies = day?.millisecondsSinceEpoch;
        setPikadayMillisecondsSinceEpoch(_pikaday, dayMillies);
      }
    }
  }

  /// <bool> or <String>. Forwards to [PikadayOptions.bound]. Look there for more info.
  @Input()
  void set bound(bound) {
    _options.bound = boolValue(bound);
  }

  /// Forwards to [PikadayOptions.position]. Look there for more info.
  @Input()
  void set position(String position) {
    _options.position = position;
  }

  /// <bool> or <String>. Forwards to [PikadayOptions.reposition]. Look there for more info.
  @Input()
  void set reposition(reposition) {
    _options.reposition = boolValue(reposition);
  }

  /// Forwards to [PikadayOptions.format]. Look there for more info.
  @Input()
  void set format(String format) {
    _options.format = format;
  }

  /// <int> or <String>. Forwards to [PikadayOptions.firstDay]. Look there for more info.
  @Input()
  void set firstDay(firstDay) {
    _options.firstDay = intValue(firstDay);
  }

  /// <DateTime> or <String> with format YYYY-MM-DD. Forwards to [PikadayOptions.minDate]. Look there for more info.
  @Input()
  void set minDate(minDate) {
    if (minDate == null || minDate == "") {
      _options.minDate = null;
    } else {
      final minDateAsDateTime = dayValue(minDate);
      if (_isInitPhase) {
        _options.minDate = minDateAsDateTime;
      } else {
        if (minDate == null) {
          _pikaday.setMinDate(null);
        } else {
          final minDateMillies = minDateAsDateTime?.millisecondsSinceEpoch;
          setPikadayMinDateAsMillisecondsSinceEpoch(_pikaday, minDateMillies);
        }
      }
    }
  }

  /// <DateTime> or <String> with format YYYY-MM-DD. Forwards to [PikadayOptions.maxDate]. Look there for more info.
  @Input()
  void set maxDate(maxDate) {
    if (maxDate == null || maxDate == "") {
      _options.maxDate = null;
    } else {
      final maxDateAsDateTime = dayValue(maxDate);
      if (_isInitPhase) {
        _options.maxDate = maxDateAsDateTime;
      } else {
        if (maxDate == null) {
          _pikaday.setMaxDate(null);
        } else {
          final maxDateMillies = maxDateAsDateTime?.millisecondsSinceEpoch;
          setPikadayMaxDateAsMillisecondsSinceEpoch(_pikaday, maxDateMillies);
        }
      }
    }
  }

  /// Forwards to [PikadayOptions.disableWeekends]. Look there for more info.
  @Input()
  void set disableWeekends(disableWeekends) {
    _options.disableWeekends = boolValue(disableWeekends);
  }

  /// <int>, <List<int>> or <String> (single '1990' or double '1980,2020').
  /// Forwards to [PikadayOptions.yearRange]. Look there for more info.
  @Input()
  void set yearRange(yearRange) {
    _options.yearRange = yearRangeValue(yearRange);
  }

  /// <bool> or <String>. Forwards to [PikadayOptions.showWeekNumber]. Look there for more info.
  @Input()
  void set showWeekNumber(showWeekNumber) {
    _options.showWeekNumber = boolValue(showWeekNumber);
  }

  /// <bool> or <String>. Forwards to [PikadayOptions.isRTL]. Look there for more info.
  @Input()
  void set isRTL(isRTL) {
    _options.isRTL = boolValue(isRTL);
  }

  /// Forwards to [PikadayOptions.i18n]. Look there for more info.
  @Input()
  void set i18n(PikadayI18nConfig i18n) {
    _options.i18n = i18n;
  }

  /// Forwards to [PikadayOptions.yearSuffix]. Look there for more info.
  @Input()
  void set yearSuffix(String yearSuffix) {
    _options.yearSuffix = yearSuffix;
  }

  /// <bool> or <String>. Forwards to [PikadayOptions.showMonthAfterYear]. Look there for more info.
  @Input()
  void set showMonthAfterYear(showMonthAfterYear) {
    _options.showMonthAfterYear = boolValue(showMonthAfterYear);
  }

  /// <bool> or <String>. Forwards to [PikadayOptions.showDaysInNextAndPreviousMonths]. Look there for more info.
  @Input()
  void set showDaysInNextAndPreviousMonths(showDaysInNextAndPreviousMonths) {
    _options.showDaysInNextAndPreviousMonths =
        boolValue(showDaysInNextAndPreviousMonths);
  }

  /// <int> or <String>. Forwards to [PikadayOptions.numberOfMonths]. Look there for more info.
  @Input()
  void set numberOfMonths(numberOfMonths) {
    _options.numberOfMonths = intValue(numberOfMonths);
  }

  /// Forwards to [PikadayOptions.mainCalendar]. Look there for more info.
  /// permitted values: "left", "right";
  @Input()
  void set mainCalendar(String mainCalendar) {
    if (mainCalendar == "right" || mainCalendar == "left") {
      _options.mainCalendar = mainCalendar;
    }
    throw new ArgumentError(
        "should only be 'left' or 'right', but was: $mainCalendar");
  }

  /// Forwards to [PikadayOptions.theme]. Look there for more info.
  @Input()
  void set theme(String theme) {
    _options.theme = theme;
  }

  @override
  void ngAfterViewInit() {
    _options.onSelect = allowInterop((dateTimeOrDate) {
      final day = dateTimeOrDate is DateTime
          ? dateTimeOrDate
          : new DateTime.fromMillisecondsSinceEpoch(
              getPikadayMillisecondsSinceEpoch(_pikaday));

      if (day != _options.defaultDate) {
        _options.defaultDate = day;
        _dayChange.add(day);
      }
    });

    _pikaday = new Pikaday(_options);

    // Currently Dart's DateTime is not correctly mapped to JS's Date
    // so they are converted to millies as transferred as int values.
    workaroundDateTimeConversionIssue(
      DateTime day,
      DateTime minDate,
      DateTime maxDate,
    ) {
      if (day != null) {
        final millies = day.millisecondsSinceEpoch;
        setPikadayMillisecondsSinceEpoch(_pikaday, millies);
      }
      if (minDate != null) {
        final millies = minDate.millisecondsSinceEpoch;
        setPikadayMinDateAsMillisecondsSinceEpoch(_pikaday, millies);
      }
      if (maxDate != null) {
        final millies = maxDate.millisecondsSinceEpoch;
        setPikadayMaxDateAsMillisecondsSinceEpoch(_pikaday, millies);
      }
    }

    workaroundDateTimeConversionIssue(
        _options.defaultDate, _options.minDate, _options.maxDate);
  }
}
