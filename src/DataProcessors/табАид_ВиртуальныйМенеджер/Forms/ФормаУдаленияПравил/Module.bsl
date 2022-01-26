
&НаКлиенте
Процедура СписокПравилВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	Режим = РежимДиалогаВопрос.ДаНет;
	Оповещение = Новый ОписаниеОповещения("ПослеЗакрытияВопроса", ЭтотОбъект, Параметры);
	ПоказатьВопрос(Оповещение,"Выбраная строка будет удалена вместе с регламентными заданиями. Продолжить?", Режим, 0);
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗакрытияВопроса(Результат, Параметры) Экспорт
	Если Результат = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	МассивКлючей = Новый Массив;
	Стр = Элементы.СписокПравил.ТекущиеДанные;
	Если Стр <> Неопределено Тогда
		 УдалитьНаСервере(Элементы.СписокПравил.ТекущиеДанные.КлючПравила);
	КонецЕсли;
	
	Элементы.СписокПравил.Обновить();
	
КонецПроцедуры

&НаСервере
Процедура  УдалитьНаСервере(Ключ)
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	табАид_ПравилаФормированияСобытий.КлючРегламентногоЗадания КАК КлючРегламентногоЗадания,
	               |	табАид_ПравилаФормированияСобытий.КлючПравила КАК КлючПравила
	               |ИЗ
	               |	РегистрСведений.табАид_ПравилаФормированияСобытий КАК табАид_ПравилаФормированияСобытий
	               |ГДЕ
	               |	табАид_ПравилаФормированияСобытий.КлючПравила = &КлючПравила";
	Запрос.УстановитьПараметр("КлючПравила",Ключ);
	Результат = Запрос.Выполнить().Выгрузить();
	Масс = Результат.ВыгрузитьКолонку("КлючРегламентногоЗадания");
	
	табАид_ОбщегоНазначенияПереопределяемый.УдалениеРегламентныхЗаданийТАБАИД(Масс);
	
	табАид_ОбщегоНазначенияПереопределяемый.УдалениеСпискаСообщенийТАБАИД(Результат);
	
	табАид_ОбщегоНазначенияПереопределяемый.УдалениеПравилФормированияСобытийТАБАИД(Результат);
	
	
КонецПроцедуры

&НаКлиенте
Процедура ЗакрытьФорму(Команда)
	Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура Удалить(Команда)
	Режим = РежимДиалогаВопрос.ДаНет;
	Оповещение = Новый ОписаниеОповещения("ПослеЗакрытияВопроса", ЭтотОбъект, Параметры);
	ПоказатьВопрос(Оповещение,"Выбраная строка будет удалена вместе с регламентными заданиями. Продолжить?", Режим, 0);

КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
		 
	Если Параметры.Свойство("ДополнительныеПараметры") и ТипЗнч(Параметры.ДополнительныеПараметры) = Тип("Структура") тогда
		ГруппаОтбора = СписокПравил.Отбор.Элементы.Добавить(Тип("ГруппаЭлементовОтбораКомпоновкиДанных"));
		ГруппаОтбора.ТипГруппы = ТипГруппыЭлементовОтбораКомпоновкиДанных.ГруппаИ;
		
		ЭлементОтбора =  ГруппаОтбора.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		// ЭлементОтбора.Родитель = ГруппаОтбора;
		ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("КлючПравила");
		ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.ВСписке;
		ЭлементОтбора.Использование = Истина;
		ЭлементОтбора.ПравоеЗначение = Параметры.ДополнительныеПараметры.СписокПравил;
		
		ЭлементОтбора =  ГруппаОтбора.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		// ЭлементОтбора.Родитель = ГруппаОтбора;
		ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ДеньНедели");
		ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
		ЭлементОтбора.Использование = Истина;
		ЭлементОтбора.ПравоеЗначение = Параметры.ДополнительныеПараметры.ДеньНедели;
		
	КонецЕсли;

КонецПроцедуры
