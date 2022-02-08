&НаКлиенте
Перем ТекущаяСтрока;

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПриАктивизацииЯчейки(Элемент)

    Если ТекущаяСтрока = Элементы.Список.ТекущаяСтрока Тогда
        Возврат;
	КонецЕсли;
	
    ТекущаяСтрока = Элементы.Список.ТекущаяСтрока;
    Если ТекущаяСтрока = Неопределено Тогда
        Возврат;
	КонецЕсли;
	
    ДобавитьРегЗаданияВМенюСписка(ТекущаяСтрока);
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьРегЗаданияВМенюСписка(Правило)
	
	//Удаляем команды и очищаем таблицу связей.
	Для Каждого стрКоманда из СвязьКомандыИРегЗадания Цикл
	    ИмяКоманды = стрКоманда.ИмяКоманды;
	    ИмяКнопки  = "КнопкаКоманды" + ИмяКоманды;
	    Команды.Удалить(Команды[ИмяКоманды]);
	    Элементы.Удалить(Элементы[ИмяКнопки]);
	КонецЦикла;
	СвязьКомандыИРегЗадания.Очистить();

	//Получаем регл. задания по ключу.
	УстановитьПривилегированныйРежим(Истина);
	ОтборРегЗаданий = Новый Структура;
	ОтборРегЗаданий.Вставить("Ключ", СокрЛП(Правило.КлючРегламентногоЗадания));
	ОтборРегЗаданий.Вставить("Метаданные", Метаданные.РегламентныеЗадания.ЗапускДополнительныхОбработок);
	МассивРегЗаданий = РегламентныеЗадания.ПолучитьРегламентныеЗадания(ОтборРегЗаданий);
	УстановитьПривилегированныйРежим(Ложь);
	
	//Формируем список действий в контекстном меню.
	Для каждого РегЗадание из МассивРегЗаданий Цикл
		ИмяКоманды = "ОткрытиеРЗ_" + СтрЗаменить(СокрЛП(РегЗадание.УникальныйИдентификатор), "-", "");

	    Команда = Команды.Добавить(ИмяКоманды);
	    Команда.Заголовок = "Открыть регламетное задание: " + РегЗадание.Наименование;
	    Команда.Действие  = "ОткрытиеФормыРегЗаданияИзКонтекстногоМеню";

	    КнопкаКоманды = Элементы.Добавить("КнопкаКоманды" + ИмяКоманды, Тип("КнопкаФормы"),Элементы.Список.КонтекстноеМеню);
	    КнопкаКоманды.ИмяКоманды = ИмяКоманды;	
		
		НовСтрока = СвязьКомандыИРегЗадания.Добавить();
		НовСтрока.ИмяКоманды = ИмяКоманды;
		НовСтрока.ИдентификаторРегЗадания = РегЗадание.УникальныйИдентификатор;
КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытиеФормыРегЗаданияИзКонтекстногоМеню(Элемент)
	
    ИмяКоманды = Элемент.Имя;
    Отбор = Новый Структура("ИмяКоманды", ИмяКоманды);
    МассивРегЗаданий = СвязьКомандыИРегЗадания.НайтиСтроки(Отбор);

    Если МассивРегЗаданий.Количество() = 0 Тогда
        Возврат;
    КонецЕсли;

    ИдентификаторРЗ = МассивРегЗаданий[0].ИдентификаторРегЗадания;
	ОткрытьФорму("Обработка.РегламентныеИФоновыеЗадания.Форма.РегламентноеЗадание",Новый Структура("Идентификатор, Действие", ИдентификаторРЗ, "Изменить"), ЭтотОбъект);
				 
КонецПроцедуры

&НаКлиенте
Процедура СписокПередУдалением(Элемент, Отказ)
	//Удаляем регл. задания по текущему правилу.
	УдалитьРеглЗаданияПередУдалениемПравила();
КонецПроцедуры

&НаСервере
Процедура УдалитьРеглЗаданияПередУдалениемПравила()
	
	МассивКлючей = Новый Массив;
	СтрокиДляУдаления = ЭтаФорма.Элементы.Список.ВыделенныеСтроки;
	Для каждого СтрокаКУдалению из СтрокиДляУдаления Цикл
		МассивКлючей.Добавить(СтрокаКУдалению.КлючРегламентногоЗадания);
	КонецЦикла;
	
	Аид_ОбщегоНазначенияПереопределяемый.УдалениеРегламентныхЗаданийАИД(МассивКлючей);
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	Если Не НастройкаРегЗаданийВыполнена() Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru = 'Выполните настройку регламентных заданий АИД!'"));
		
		КлючЗаписиНастроек = ПолучитьКлючЗаписиНастроекРегЗаданий();
		Если КлючЗаписиНастроек = неопределено Тогда
			ОткрытьФорму("РегистрСведений.Аид_Настройки.ФормаЗаписи");
		Иначе
			ОткрытьФорму("РегистрСведений.Аид_Настройки.ФормаЗаписи", Новый Структура("Ключ", КлючЗаписиНастроек));
		КонецЕсли;
		
		Отказ = Истина;	
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция НастройкаРегЗаданийВыполнена()
	Возврат Аид_ОбщегоНазначенияПереопределяемый.НастройкаРегЗаданийВыполнена();
КонецФункции

&НаСервере
Функция ПолучитьКлючЗаписиНастроекРегЗаданий()
	
	Набор = РегистрыСведений.Аид_Настройки.СоздатьНаборЗаписей();
    Набор.Отбор.Организация.Установить(Справочники.Организации.ПустаяСсылка());
    
    Набор.Прочитать();
	
	Если Набор.Количество() = 1 Тогда
	    Возврат РегистрыСведений.Аид_Настройки.СоздатьКлючЗаписи(Новый Структура("Организация", Справочники.Организации.ПустаяСсылка()));
	КонецЕсли;
	
	Возврат неопределено;
	
КонецФункции


