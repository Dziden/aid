&НаКлиенте
Процедура табАид_КонтактноеЛицоТАБАИДВместо(Команда)
	ТекДанные = Элементы.Список.ТекущаяСтрока;
	Если ТекДанные = неопределено Тогда
		Возврат;
	КонецЕсли;
	табАид_КонтактноеЛицоТАБАИДНаСервере(ТекДанные);
	Элементы.Список.Обновить();
КонецПроцедуры

&НаСервере
Процедура табАид_КонтактноеЛицоТАБАИДНаСервере(КонтактноеЛицо)
	ЗаписьКонтЛицоТАБАИД = РегистрыСведений.табАид_КонтактныеЛицаПартнеров.СоздатьМенеджерЗаписи();
	ЗаписьКонтЛицоТАБАИД.Партнер = КонтактноеЛицо.Владелец;
	ЗаписьКонтЛицоТАБАИД.КонтактноеЛицо = КонтактноеЛицо;
	ЗаписьКонтЛицоТАБАИД.Записать(Истина);
	табАид_УстановитьУсловноеОформление(КонтактноеЛицо.Владелец);
КонецПроцедуры

Процедура табАид_УстановитьУсловноеОформление(Партнер) Экспорт
	Список.УсловноеОформление.Элементы.Очистить();
	ЭлементУсловногоОформления = Список.УсловноеОформление.Элементы.Добавить();
	ОтборЭлемента = ЭлементУсловногоОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение  = Новый ПолеКомпоновкиДанных("Ссылка");
	ОтборЭлемента.ВидСравнения   = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = ПартнерыИКонтрагенты.табАид_ПолучитьКонтактноеЛицоПартнера(Партнер);
	ЭлементУсловногоОформления.Оформление.УстановитьЗначениеПараметра("Шрифт", Новый Шрифт(,,Истина,,,,));
КонецПроцедуры

&НаСервере
Процедура табАид_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	табАид_УстановитьУсловноеОформление(Параметры.Отбор.Владелец);
КонецПроцедуры

