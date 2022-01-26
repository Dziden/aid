///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Отправляет SMS через SMS.RU.
//
// Параметры:
//  НомераПолучателей - Массив - номера получателей в формате +7ХХХХХХХХХХ;
//  Текст 			  - Строка - текст сообщения, длиной не более 480 символов;
//  ИмяОтправителя 	  - Строка - имя отправителя, которое будет отображаться вместо номера входящего SMS;
//  Логин			  - Строка - логин пользователя услуги отправки sms;
//  Пароль			  - Строка - пароль пользователя услуги отправки sms.
//  СпособАвторизации - Строка - строка со значением "ПоКлючу" или "ПоЛогинуИПаролю".
//
// Возвращаемое значение:
//  Структура: ОтправленныеСообщения - Массив структур: НомерОтправителя.
//                                                  ИдентификаторСообщения.
//             ОписаниеОшибки        - Строка - пользовательское представление ошибки, если пустая строка,
//                                          то ошибки нет.
Функция ОтправитьSMS(НомераПолучателей, Текст, ИмяОтправителя, Логин, Пароль, СпособАвторизации = неопределено) Экспорт
	
	Результат = Новый Структура("ОтправленныеСообщения,ОписаниеОшибки", Новый Массив, "");
	
	// Подготовка строки получателей.
	СтрокаПолучателей = МассивПолучателейСтрокой(НомераПолучателей);
	
	// Проверка на заполнение обязательных параметров.
	Если ПустаяСтрока(СтрокаПолучателей) Или ПустаяСтрока(Текст) Тогда
		Результат.ОписаниеОшибки = НСтр("ru = 'Неверные параметры сообщения'");
		Возврат Результат;
	КонецЕсли;
	
	// Подготовка параметров запроса.
	// +табАид
	Если СпособАвторизации = "ПоКлючу" Тогда
		ПараметрыЗапроса = Новый Структура;
		ПараметрыЗапроса.Вставить("api_id", Пароль);
		ПараметрыЗапроса.Вставить("msg", Текст);
		ПараметрыЗапроса.Вставить("to", СтрокаПолучателей);
		ПараметрыЗапроса.Вставить("from", ИмяОтправителя);
	Иначе
		// -табАид
		ПараметрыЗапроса = Новый Структура;
		ПараметрыЗапроса.Вставить("login", Логин);
		ПараметрыЗапроса.Вставить("password", Пароль);
		ПараметрыЗапроса.Вставить("text", Текст);
		ПараметрыЗапроса.Вставить("to", СтрокаПолучателей);
		ПараметрыЗапроса.Вставить("from", ИмяОтправителя);
	КонецЕсли;
	
	// отправка запроса
	//ТекстОтвета = ВыполнитьЗапрос("sms/send", ПараметрыЗапроса);
	//Если Не ЗначениеЗаполнено(ТекстОтвета) Тогда
	//	Результат.ОписаниеОшибки = Результат.ОписаниеОшибки + НСтр("ru = 'Соединение не установлено'");
	//	Возврат Результат;
	//КонецЕсли;
	
			 //Костя
	Логин = "webservice";
	Пароль = "*5leAeqE}Y";
	ПутьКСерверу = "msk.tab-is.ru/aid_database";
	ПутьКСервису = "/hs/AID_API/w1/SendSMS";
	
	
		//передача параметров
	СтруктураПараметров = Новый Структура;	
	
	//**********
	Набор = РегистрыСведений.табАид_Настройки.СоздатьНаборЗаписей();
	Набор.Отбор.Организация.Установить(Справочники.Организации.ПустаяСсылка());
	
	Набор.Прочитать();
	
	Если Набор.Количество() = 1 Тогда
		 keyBS= Набор[0].КлючБС;
	КонецЕсли;

	//**********
	
	СтруктураПараметров.Вставить("keyBS",keyBS);
	
	СтруктураПараметров.Вставить("messageparameters",ПараметрыЗапроса);
	ЗаписьJSON = Новый ЗаписьJSON;		
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, СтруктураПараметров);
	СтрокаJSON = ЗаписьJSON.Закрыть();
	
	//выполнение веб-запроса
	HTTPСоединение = Новый HTTPСоединение(ПутьКСерверу,,Логин,Пароль,,,Новый ЗащищенноеСоединениеOpenSSL);	
	HTTPЗапрос = Новый HTTPЗапрос(ПутьКСервису);
	HTTPЗапрос.УстановитьТелоИзСтроки(СтрокаJSON);	
	HTTPОтвет = HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос);	
	
	//Чтение результатов запроса		
	ТелоЗапроса = HTTPОтвет.ПолучитьТелоКакСтроку("UTF-8");
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(ТелоЗапроса);
	Попытка
		ТекстОтвета = ПрочитатьJSON(ЧтениеJSON);	
	Исключение
		Сообщить(ТелоЗапроса);
	КонецПопытки;
	//************

	
	ИдентификаторыСообщений = СтрРазделить(ТекстОтвета, Символы.ПС);
	
	ОтветСервера = ИдентификаторыСообщений[0];
	ИдентификаторыСообщений.Удалить(0);
	
	Если ОтветСервера = "100" Тогда
		НомераПолучателей = СтрРазделить(СтрокаПолучателей, ",", Ложь);
		Если ИдентификаторыСообщений.Количество() < НомераПолучателей.Количество() Тогда
			Результат.ОписаниеОшибки = НСтр("ru = 'Ответ сервера не распознан'");
			Возврат Результат;
		КонецЕсли;
		// +табАид
		СообщениеОбОшибках = "";
		// -табАид
		Для Индекс = 0 По НомераПолучателей.ВГраница() Цикл
			НомерПолучателя = НомераПолучателей[Индекс];
			ИдентификаторСообщения = ИдентификаторыСообщений[Индекс];
			// +табАид
			Если СтрДлина(ИдентификаторСообщения) <=3 Тогда
				ОписаниеОшибки = "Получатель <" + НомерПолучателя + "> :" + ОписаниеОшибкиОтправки(ИдентификаторСообщения);
				СообщениеОбОшибках = СообщениеОбОшибках + ОписаниеОшибки + Символы.ПС;
			Иначе
				// -табАид
				Если Не ПустаяСтрока(НомерПолучателя) Тогда
					ОтправленноеСообщение = Новый Структура("НомерПолучателя,ИдентификаторСообщения",
					НомерПолучателя,ИдентификаторСообщения);
					Результат.ОтправленныеСообщения.Добавить(ОтправленноеСообщение);
				КонецЕсли;
			КонецЕсли;
			
			// +табАид
			Если ЗначениеЗаполнено(СообщениеОбОшибках) Тогда
				Результат.ОписаниеОшибки = СообщениеОбОшибках;
				ЗаписьЖурналаРегистрации(НСтр("ru = 'Отправка SMS'", ОбщегоНазначения.КодОсновногоЯзыка()),
				УровеньЖурналаРегистрации.Ошибка, , , СообщениеОбОшибках);
			КонецЕсли;
			// -табАид
		КонецЦикла;
	Иначе
		Результат.ОписаниеОшибки = ОписаниеОшибкиОтправки(ОтветСервера);
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Отправка SMS'", ОбщегоНазначения.КодОсновногоЯзыка()),
		УровеньЖурналаРегистрации.Ошибка, , , Результат.ОписаниеОшибки);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Возвращает текстовое представление статуса доставки сообщения.
//
// Параметры:
//  ИдентификаторСообщения - Строка - идентификатор, присвоенный sms при отправке;
//  НастройкиОтправкиSMS   - Структура - см. ОтправкаSMSПовтИсп.НастройкиОтправкиSMS;
//
// Возвращаемое значение:
//  Строка - статус доставки. См. описание функции ОтправкаSMS.СтатусДоставки.
Функция СтатусДоставкиСтарая(ИдентификаторСообщения, НастройкиОтправкиSMS) Экспорт
	
	Логин = НастройкиОтправкиSMS.ЛогинДляОтправкиSMS;
	Пароль = НастройкиОтправкиSMS.ПарольДляОтправкиSMS;
	
	// Подготовка параметров запроса.
	// +табАид
	Если НастройкиОтправкиSMS.СпособАвторизацииSMS = "ПоКлючу" Тогда
		ПараметрыЗапроса = Новый Структура;
		ПараметрыЗапроса.Вставить("api_id", Пароль);
	Иначе
		// -табАид
		ПараметрыЗапроса = Новый Структура;
		ПараметрыЗапроса.Вставить("login", Логин);
		ПараметрыЗапроса.Вставить("password", Пароль);
		ПараметрыЗапроса.Вставить("id", ИдентификаторСообщения);
	КонецЕсли;
	ПараметрыЗапроса.Вставить("sms_id", ИдентификаторСообщения);
	
	// отправка запроса
	КодСостояния = ВыполнитьЗапрос("sms/status", ПараметрыЗапроса);
	Если Не ЗначениеЗаполнено(КодСостояния) Тогда
		Результат = "Ошибка";
	КонецЕсли;
	
	КодыСостоянийМассив = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(КодСостояния, Символы.ПС);
	Если КодыСостоянийМассив.Количество() = 1 Тогда
		КодСостояния = "-1";
	Иначе
		КодСостояния = КодыСостоянийМассив[1];
	КонецЕсли;
	
	Результат = СтатусДоставкиSMS(КодСостояния);
	СтатусДоставки = Ложь;
	ОписаниеОшибки = "";
	Если Результат = "Ошибка" Тогда
		ОписаниеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр(
		"ru = 'Не удалось получить статус доставки SMS (id: ""%3""):
		|%1 (код ошибки: %2)'"), ОписаниеОшибкиПолученияСтатуса(КодСостояния), КодСостояния, ИдентификаторСообщения);
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Отправка SMS'", ОбщегоНазначения.КодОсновногоЯзыка()),
		УровеньЖурналаРегистрации.Ошибка, , , ОписаниеОшибки);
		
	Иначе
		Если Результат = "Доставлено" Тогда
			СтатусДоставки = Истина;	
		Иначе
			ОписаниеОшибки = ОписаниеОшибкиПолученияСтатуса(КодСостояния);
		КонецЕсли;
	КонецЕсли;
	
	ТипСообщения = Перечисления.табАид_ТипыСообщений.SMS;
	табАид_ОбщегоНазначенияПереопределяемый.ОбновитьСтатусДоставкиСообщения(ТипСообщения, ИдентификаторСообщения, СтатусДоставки, ОписаниеОшибки);			
	
	Возврат Результат;
	
КонецФункции

Функция СтатусДоставки(ИдентификаторСообщения, НастройкиОтправкиSMS) Экспорт
	
	Логин = "webservice";
	Пароль = "*5leAeqE}Y";
	ПутьКСерверу = "msk.tab-is.ru/aid_database";
	ПутьКСервису = "/hs/AID_API/w1/DeliveryStatusSMS";
	
	//передача параметров
	СтруктураПараметров = Новый Структура;	
	СтруктураПараметров.Вставить("messageId",ИдентификаторСообщения);
	СтруктураПараметров.Вставить("keyBS",НастройкиОтправкиSMS.КлючБС);
	СтруктураПараметров.Вставить("ИмяМетода","DeliveryStatusSMS");

	ЗаписьJSON = Новый ЗаписьJSON;		
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, СтруктураПараметров);
	СтрокаJSON = ЗаписьJSON.Закрыть();
	
	//выполнение веб-запроса
	//HTTPСоединение = Новый HTTPСоединение(ПутьКСерверу,,Логин,Пароль,,,Новый ЗащищенноеСоединениеOpenSSL);	
	//HTTPЗапрос = Новый HTTPЗапрос(ПутьКСервису);
	//HTTPЗапрос.УстановитьТелоИзСтроки(СтрокаJSON);	
	//HTTPОтвет = HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос);	
	//
	////Чтение результатов запроса		
	//ТелоЗапроса = HTTPОтвет.ПолучитьТелоКакСтроку("UTF-8");
	ПроксиАИД = WSСсылки.ТабАид_WSСсылка1.СоздатьWSПрокси("https://msk.tab-is.ru/", "АИД", "АИДSoap");  //
	ПроксиАИД.Пользователь = Логин;
	ПроксиАИД.Пароль = Пароль;
	//}Руслан 20.12.2021
	//ЧтениеJSON = Новый ЧтениеJSON;
	//ЧтениеJSON.УстановитьСтроку(СтрокаJSON);
	ТелоЗапроса = ПроксиАИД.method(СтрокаJSON);	//Руслан 20.12.2021
	
	
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(ТелоЗапроса);
	Попытка
		ПараметрыРезультат = ПрочитатьJSON(ЧтениеJSON);	
	Исключение
		Сообщить(ТелоЗапроса);
	КонецПопытки;
	Если ПараметрыРезультат <> Неопределено Тогда 
		ТипСообщения = Перечисления.ТабАИД_ТипыСообщений.SMS;
		Результат =  ПараметрыРезультат.Результат;
		СтатусДоставки = ПараметрыРезультат.СтатусДоставки;
		ОписаниеОшибки = ПараметрыРезультат.ОписаниеОшибки;
		ТекстДиалога =  ПараметрыРезультат.ТекстДиалога;
		ФайлОтветов = ПараметрыРезультат.ФайлОтветов;
		
		Если Результат = "Ошибка" Тогда
			ОписаниеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр(
			"ru = 'Не удалось получить статус доставки ГП (id: ""%1"")'"), ИдентификаторСообщения);
			ЗаписьЖурналаРегистрации(НСтр("ru = 'Отправка ГП'", ОбщегоНазначения.КодОсновногоЯзыка()),
			УровеньЖурналаРегистрации.Ошибка, , , ОписаниеОшибки);
		КонецЕсли;
		
		табАид_ОбщегоНазначенияПереопределяемый.ОбновитьСтатусДоставкиСообщения(ТипСообщения, ИдентификаторСообщения, СтатусДоставки, ОписаниеОшибки, ТекстДиалога, ФайлОтветов);			
		
		Возврат Результат;
	КонецЕсли;

КонецФункции


Функция СтатусДоставкиSMS(КодСостояния)
	
	СоответствиеСтатусов = Новый Соответствие;
	СоответствиеСтатусов.Вставить("-1", "НеОтправлялось");
	СоответствиеСтатусов.Вставить("100", "НеОтправлялось");
	СоответствиеСтатусов.Вставить("101", "Отправляется");
	СоответствиеСтатусов.Вставить("102", "Отправлено");
	СоответствиеСтатусов.Вставить("103", "Доставлено");
	СоответствиеСтатусов.Вставить("104", "НеДоставлено");
	СоответствиеСтатусов.Вставить("105", "НеДоставлено");
	СоответствиеСтатусов.Вставить("106", "НеДоставлено");
	СоответствиеСтатусов.Вставить("107", "НеДоставлено");
	СоответствиеСтатусов.Вставить("108", "НеДоставлено");
	СоответствиеСтатусов.Вставить("110", "Доставлено");
	СоответствиеСтатусов.Вставить("150", "НеДоставлено");
	
	Результат = СоответствиеСтатусов[НРег(КодСостояния)];
	Возврат ?(Результат = Неопределено, "Ошибка", Результат);
КонецФункции

Функция ОписанияОшибок()
	
	ОписанияОшибок = Новый Соответствие;
	ОписанияОшибок.Вставить("-1", НСтр("ru = 'Сообщение не найдено.'"));
	ОписанияОшибок.Вставить("100", НСтр("ru = 'Запрос выполнен или сообщение находится в нашей очереди.'"));
	ОписанияОшибок.Вставить("101", НСтр("ru = 'Сообщение передается оператору.'"));
	ОписанияОшибок.Вставить("102", НСтр("ru = 'Сообщение отправлено (в пути).'"));
	ОписанияОшибок.Вставить("103", НСтр("ru = 'Сообщение доставлено.'"));
	ОписанияОшибок.Вставить("104", НСтр("ru = 'Не может быть доставлено: время жизни истекло.'"));
	ОписанияОшибок.Вставить("105", НСтр("ru = 'Не может быть доставлено: удалено оператором.'"));
	ОписанияОшибок.Вставить("106", НСтр("ru = 'Не может быть доставлено: сбой в телефоне.'"));
	ОписанияОшибок.Вставить("107", НСтр("ru = 'Не может быть доставлено: неизвестная причина.'"));
	ОписанияОшибок.Вставить("108", НСтр("ru = 'Не может быть доставлено: отклонено.'"));
	ОписанияОшибок.Вставить("110", НСтр("ru = 'Сообщение прочитано (для Viber, временно не работает).'"));
	ОписанияОшибок.Вставить("150", НСтр("ru = 'Не может быть доставлено: не найден маршрут на данный номер.'"));
	ОписанияОшибок.Вставить("200", НСтр("ru = 'Неправильный api_id.'"));
	ОписанияОшибок.Вставить("201", НСтр("ru = 'Не хватает средств на лицевом счету.'"));
	ОписанияОшибок.Вставить("202", НСтр("ru = 'Неправильно указан номер телефона получателя, либо на него нет маршрута.'"));
	ОписанияОшибок.Вставить("203", НСтр("ru = 'Нет текста сообщения.'"));
	ОписанияОшибок.Вставить("204", НСтр("ru = 'Имя отправителя не согласовано с администрацией.'"));
	ОписанияОшибок.Вставить("205", НСтр("ru = 'Сообщение слишком длинное (превышает 8 СМС).'"));
	ОписанияОшибок.Вставить("206", НСтр("ru = 'Будет превышен или уже превышен дневной лимит на отправку сообщений.'"));
	ОписанияОшибок.Вставить("207", НСтр("ru = 'На этот номер нет маршрута для доставки сообщений.'"));
	ОписанияОшибок.Вставить("208", НСтр("ru = 'Параметр time указан неправильно.'"));
	ОписанияОшибок.Вставить("209", НСтр("ru = 'Вы добавили этот номер (или один из номеров) в стоп-лист.'"));
	ОписанияОшибок.Вставить("210", НСтр("ru = 'Используется GET, где необходимо использовать POST.'"));
	ОписанияОшибок.Вставить("211", НСтр("ru = 'Метод не найден.'"));
	ОписанияОшибок.Вставить("212", НСтр("ru = 'Текст сообщения необходимо передать в кодировке UTF-8 (вы передали в другой кодировке).'"));
	ОписанияОшибок.Вставить("213", НСтр("ru = 'Указано более 100 номеров в списке получателей.'"));
	ОписанияОшибок.Вставить("220", НСтр("ru = 'Сервис временно недоступен, попробуйте чуть позже.'"));
	ОписанияОшибок.Вставить("230", НСтр("ru = 'Превышен общий лимит количества сообщений на этот номер в день.'"));
	ОписанияОшибок.Вставить("231", НСтр("ru = 'Превышен лимит одинаковых сообщений на этот номер в минуту.'"));
	ОписанияОшибок.Вставить("232", НСтр("ru = 'Превышен лимит одинаковых сообщений на этот номер в день.'"));
	ОписанияОшибок.Вставить("233", НСтр("ru = 'Превышен лимит отправки повторных сообщений с кодом на этот номер за короткий промежуток времени (""защита от мошенников"", можно отключить в разделе ""Настройки"").'"));
	ОписанияОшибок.Вставить("300", НСтр("ru = 'Неправильный token (возможно истек срок действия, либо ваш IP изменился).'"));
	ОписанияОшибок.Вставить("301", НСтр("ru = 'Неправильный api_id, либо логин/пароль.'"));
	ОписанияОшибок.Вставить("302", НСтр("ru = 'Пользователь авторизован, но аккаунт не подтвержден (пользователь не ввел код, присланный в регистрационной смс).'"));
	ОписанияОшибок.Вставить("303", НСтр("ru = 'Код подтверждения неверен.'"));
	ОписанияОшибок.Вставить("304", НСтр("ru = 'Отправлено слишком много кодов подтверждения. Пожалуйста, повторите запрос позднее.'"));
	ОписанияОшибок.Вставить("305", НСтр("ru = 'Слишком много неверных вводов кода, повторите попытку позднее.'"));
	ОписанияОшибок.Вставить("500", НСтр("ru = 'Ошибка на сервере. Повторите запрос.'"));
	ОписанияОшибок.Вставить("901", НСтр("ru = 'Callback: URL неверный (не начинается на http://).'"));
	ОписанияОшибок.Вставить("902", НСтр("ru = 'Callback: Обработчик не найден (возможно был удален ранее).'"));
	
	Возврат ОписанияОшибок;
	
КонецФункции

Функция ОписаниеОшибкиОтправки(КодОшибки)
	ОписанияОшибок = ОписанияОшибок();
	ТекстСообщения = ОписанияОшибок[КодОшибки];
	Если ТекстСообщения = Неопределено Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Сообщение не отправлено (код ошибки: %1).'"), КодОшибки);
	КонецЕсли;
	Возврат ТекстСообщения;
КонецФункции

Функция ОписаниеОшибкиПолученияСтатуса(КодОшибки)
	ОписанияОшибок =ОписанияОшибок();
	ТекстСообщения = ОписанияОшибок[КодОшибки];
	Если ТекстСообщения = Неопределено Тогда
		ТекстСообщения = НСтр("ru = 'Отказ выполнения операции'");
	КонецЕсли;
	Возврат ТекстСообщения;
КонецФункции

Функция ВыполнитьЗапрос(ИмяМетода, ПараметрыЗапроса)
	
	HTTPЗапрос = табАид_ОтправкаSMS.ПодготовитьHTTPЗапрос("/" + ИмяМетода, ПараметрыЗапроса);
	HTTPОтвет = Неопределено;
	
	Попытка
		Соединение = Новый HTTPСоединение("sms.ru", , , , ПолучениеФайловИзИнтернета.ПолучитьПрокси("https"),
		60, ОбщегоНазначенияКлиентСервер.НовоеЗащищенноеСоединение());
		
		HTTPОтвет = Соединение.ОтправитьДляОбработки(HTTPЗапрос);
	Исключение
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Отправка SMS'", ОбщегоНазначения.КодОсновногоЯзыка()),
		УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
	Если HTTPОтвет <> Неопределено Тогда
		Возврат СокрЛП(HTTPОтвет.ПолучитьТелоКакСтроку());
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

Функция МассивПолучателейСтрокой(Массив)
	Получатели = Новый Массив;
	ОбщегоНазначенияКлиентСервер.ДополнитьМассив(Получатели, Массив, Истина);
	
	Результат = "";
	Для Каждого Получатель Из Получатели Цикл
		Номер = ФорматироватьНомер(Получатель);
		Если НЕ ПустаяСтрока(Номер) Тогда 
			Если Не ПустаяСтрока(Результат) Тогда
				Результат = Результат + ",";
			КонецЕсли;
			Результат = Результат + Номер;
		КонецЕсли;
	КонецЦикла;
	Возврат Результат;
КонецФункции

Функция ФорматироватьНомер(Номер)
	Результат = "";
	ДопустимыеСимволы = "+1234567890";
	Для Позиция = 1 По СтрДлина(Номер) Цикл
		Символ = Сред(Номер,Позиция,1);
		Если СтрНайти(ДопустимыеСимволы, Символ) > 0 Тогда
			Результат = Результат + Символ;
		КонецЕсли;
	КонецЦикла;
	Возврат Результат;	
КонецФункции

// Возвращает список разрешений для отправки SMS с использованием всех доступных провайдеров.
//
// Возвращаемое значение:
//  Массив.
//
Функция Разрешения() Экспорт
	
	Протокол = "HTTP";
	Адрес = "sms.ru";
	Порт = Неопределено;
	Описание = НСтр("ru = 'Отправка SMS через ""SMS.RU"".'");
	
	МодульРаботаВБезопасномРежиме = ОбщегоНазначения.ОбщийМодуль("РаботаВБезопасномРежиме");
	
	Разрешения = Новый Массив;
	Разрешения.Добавить(
	МодульРаботаВБезопасномРежиме.РазрешениеНаИспользованиеИнтернетРесурса(Протокол, Адрес, Порт, Описание));
	
	Возврат Разрешения;
КонецФункции

Процедура ПриОпределенииНастроек(Настройки) Экспорт
	
	Настройки.АдресОписанияУслугиВИнтернете = "http://sms.ru";
	Настройки.ПриОпределенииСпособовАвторизации = Истина;
	
КонецПроцедуры

Процедура ПриОпределенииСпособовАвторизации(СпособыАвторизации) Экспорт
	
	СпособыАвторизации.Очистить();
	
	ПоляАвторизации = Новый СписокЗначений;
	ПоляАвторизации.Добавить("Логин", НСтр("ru = 'Логин'"));
	ПоляАвторизации.Добавить("Пароль", НСтр("ru = 'Пароль'"), Истина);
	
	СпособыАвторизации.Вставить("ПоЛогинуИПаролю", ПоляАвторизации);
	
	ПоляАвторизации = Новый СписокЗначений;
	ПоляАвторизации.Добавить("Пароль", НСтр("ru = 'api_id'"));
	
	СпособыАвторизации.Вставить("ПоКлючу", ПоляАвторизации);
	
КонецПроцедуры

#КонецОбласти

