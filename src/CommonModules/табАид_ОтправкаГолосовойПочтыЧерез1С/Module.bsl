Функция ОтправитьГП(МассивНомеров, ТекстСообщения, Знач Организация = Неопределено, КешНастроекПровайдера = Неопределено) Экспорт
	
	Результат = Новый Структура("ОтправленныеСообщения, ОписаниеОшибки", Новый Массив, "");
	
	// Подготовка строки получателей.
	СтрокаПолучателей = МассивПолучателейСтрокой(МассивНомеров);
	
	// Проверка на заполнение обязательных параметров.
	Если ПустаяСтрока(СтрокаПолучателей) Или ПустаяСтрока(ТекстСообщения) Тогда
		Результат.ОписаниеОшибки = НСтр("ru = 'Неверные параметры сообщения'");
		Возврат Результат;
	КонецЕсли;
	
	Если КешНастроекПровайдера = Неопределено тогда
		КешНастроекПровайдера = табАид_ОтправкаГолосовойПочты.НастройкиОтправкиГП(Организация);
	КонецЕсли;
	
	// Подготовка параметров запроса.
	ПараметрыЗапроса = Новый Структура;
	ПараметрыЗапроса.Вставить("МассивНомеров", МассивНомеров);
	Если КешНастроекПровайдера.ПереводВызова Тогда
		ПараметрыЗапроса.Вставить("Сообщение",     ТекстСообщения + ?(прав(ТекстСообщения,СтрДлина(ТекстСообщения)) = "." , "",".") +" Если у Вас остались вопросы, то я могу перевести звонок на нашего менеджера. Перевести звонок?");  //из переписки с 1С
	иначе
		ПараметрыЗапроса.Вставить("Сообщение",     ТекстСообщения);
	КонецЕсли;
	
	
	ПараметрыЗапроса.Вставить("Прощание", "Спасибо за ответ.");
	
	// Отправка запроса.
	Ответ = ВыполнитьЗапрос(ПараметрыЗапроса, КешНастроекПровайдера);
	Если Ответ = Неопределено Тогда
		Результат.ОписаниеОшибки = Результат.ОписаниеОшибки + НСтр("ru = 'Соединение не установлено'");
		Возврат Результат;
	КонецЕсли;
	
	Если Ответ.Результат.ОтветСервера = "Отключен" Тогда 
		Результат.ОписаниеОшибки = НСтр("ru = 'Ключ БС не активирован, обратитесь в техническую поддержку'");
		Возврат Результат;
	КонецЕсли;

	ОтправленноеСообщение = Новый Структура("НомерПолучателя,ИдентификаторСообщения",Ответ.НомерПолучателя, Ответ.Результат.ОтветСервера);
  	Результат.ОтправленныеСообщения.Добавить(ОтправленноеСообщение);

	//Для Каждого КлючИзначение из Ответ Цикл
	//	ОтправленноеСообщение = Новый Структура("НомерПолучателя,ИдентификаторСообщения",
	//	КлючИзначение.Ключ, КлючИзначение.Значение.ОтветСервера);
	//	Результат.ОтправленныеСообщения.Добавить(ОтправленноеСообщение);	
	//КонецЦикла;
	Возврат Результат;
	
КонецФункции

// Возвращает текстовое представление статуса доставки сообщения.
//
// Параметры:
//  ИдентификаторСообщения - Строка - идентификатор, присвоенный sms при отправке;
//  НастройкиОтправкиГП   - Структура - см. удз_ОтправкаГолосовойПочты.НастройкиОтправкиГП;
//
// Возвращаемое значение:
//  Строка - статус доставки. См. описание функции удз_ОтправкаГолосовойПочты.СтатусДоставки.
Функция СтатусДоставки(ИдентификаторСообщения, НастройкиОтправкиГП) Экспорт
	
	Логин = "webservice";
	Пароль = "*5leAeqE}Y";
	ПутьКСерверу = "msk.tab-is.ru/aid_database";
	ПутьКСервису = "/hs/AID_API/w1/DeliveryStatus";
	
	//передача параметров
	СтруктураПараметров = Новый Структура;	
	СтруктураПараметров.Вставить("messageId",ИдентификаторСообщения);
	СтруктураПараметров.Вставить("keyBS",НастройкиОтправкиГП.КлючБС);

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
		ПараметрыРезультат = ПрочитатьJSON(ЧтениеJSON);	
	Исключение
		Сообщить(ТелоЗапроса);
	КонецПопытки;
	Если ПараметрыРезультат <> Неопределено Тогда 
		ТипСообщения = Перечисления.табАид_ТипыСообщений.ГолосовоеСообщение;
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
		
		ТабАид_ОбщегоНазначенияПереопределяемый.ОбновитьСтатусДоставкиСообщения(ТипСообщения, ИдентификаторСообщения, СтатусДоставки, ОписаниеОшибки, ТекстДиалога, ФайлОтветов);			
		
		Возврат Результат;
	КонецЕсли;

КонецФункции

Функция ВыполнитьЗапрос(ПараметрыЗапроса, КешНастроекПровайдера)
	
	//соотвОтвет = Новый Соответствие;
	//
	////HTTPСоединение = Новый HTTPСоединение("api-aid.tab-is.ru", 80);
	//HTTPСоединение = Новый HTTPСоединение("caller.1c.ai", 80);//,"tb3","Ga5bHri3Dwtf");
	////caller.1c.ai/TAB3/
	//Заголовки = Новый Соответствие();
	//Заголовки.Вставить("Authorization", "Basic " + "dGI6a2dlS3ZVUlN2bDBKcFFkKw=="); 
	////Заголовки.Вставить("Authorization", "Basic " + "tb3"+"Ga5bHri3Dwtf"); 

	//Заголовки.Вставить("Content-Type",  "application/json");
	//
	//ЗапросHTTP = Новый HTTPЗапрос("/TiB/hs/PhoneBot/addTask", Заголовки);
	//
	//ЧтениеJSON    = Новый ЧтениеJSON;
	//ЗаписьJSON    = Новый ЗаписьJSON; 
	//ПараметрыJSON = Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Авто, "", Истина);	
	//ЗаписьJSON.УстановитьСтроку(ПараметрыJSON);
	//
	//стррПараметры      = новый Структура;
	//стррПараметры.Вставить("Фраза",    ПараметрыЗапроса.Сообщение);
	//стррПараметры.Вставить("Прощание", ПараметрыЗапроса.Прощание);
	//
	//
	//
	//Для Каждого ТекущийНомер из ПараметрыЗапроса.МассивНомеров Цикл
	//	
	//	Если ПустаяСтрока(ТекущийНомер) тогда
	//		Продолжить;
	//	КонецЕсли;
	//	
	//	стррРезультат = Новый Структура;
	//	стррРезультат.Вставить("ЗапросВыполнен", Ложь);
	//	стррРезультат.Вставить("ОтветСервера", "");
	//	
	//	ОтправляемыеДанные = новый Структура;
	//	
	//	Если КешНастроекПровайдера.ПровайдерТелефония = Перечисления.табАид_ПровайдерыТелефонии.Женский Тогда
	//		Если КешНастроекПровайдера.ПереводВызова Тогда
	//			ОтправляемыеДанные.Вставить("taskId",          КешНастроекПровайдера.ТокенЖенскийПеревод);
	//		иначе
	//			ОтправляемыеДанные.Вставить("taskId",          КешНастроекПровайдера.ТокенЖенский);
	//		КонецЕсли;
	//	иначе
	//		Если КешНастроекПровайдера.ПереводВызова Тогда
	//			ОтправляемыеДанные.Вставить("taskId",          КешНастроекПровайдера.ТокенМужскойПеревод);
	//		иначе
	//			ОтправляемыеДанные.Вставить("taskId",          КешНастроекПровайдера.ТокенМужской);  
	//		КонецЕсли;			
	//	КонецЕсли;
	//	
	//	Если СтрНайти(ТекущийНомер, ", доб.") тогда
	//		ПозицияОсновнойТелефон   = СтрНайти(ТекущийНомер, ", доб.") - 1;   //без запятой
	//		ПозицияДобавочныйТелефон = ПозицияОсновнойТелефон + 8;
	//		ОтправляемыеДанные.Вставить("phone",           Лев(ТекущийНомер, ПозицияОсновнойТелефон));
	//		ОтправляемыеДанные.Вставить("extension",       Сред(ТекущийНомер, ПозицияДобавочныйТелефон));
	//		ОтправляемыеДанные.Вставить("extension_delay", 3000); //по умолчанию, в мс
	//	ИначеЕсли СтрНайти(ТекущийНомер, ",доб.") тогда
	//		ПозицияОсновнойТелефон   = СтрНайти(ТекущийНомер, ",доб.") - 1;   //без запятой
	//		ПозицияДобавочныйТелефон = ПозицияОсновнойТелефон + 6;
	//		ОтправляемыеДанные.Вставить("phone",           Лев(ТекущийНомер, ПозицияОсновнойТелефон));
	//		ОтправляемыеДанные.Вставить("extension",       Сред(ТекущийНомер, ПозицияДобавочныйТелефон));
	//		ОтправляемыеДанные.Вставить("extension_delay", 3000); //по умолчанию, в мс
	//	иначе	
	//		ОтправляемыеДанные.Вставить("phone",      ТекущийНомер); 
	//		ОтправляемыеДанные.Вставить("parameters", стррПараметры); 
	//	КонецЕсли;
	//	
	//	ЗаписатьJSON(ЗаписьJSON, ОтправляемыеДанные); 
	//	СтрокаДляТела = ЗаписьJSON.Закрыть();
	//	ЗапросHTTP.УстановитьТелоИзСтроки(СтрокаДляТела, КодировкаТекста.UTF8, ИспользованиеByteOrderMark.НеИспользовать);
	//	
	//	Попытка
	//		ОтветHTTP = HTTPСоединение.ВызватьHTTPМетод("POST", ЗапросHTTP);
	//		стррРезультат.ЗапросВыполнен = ОтветHTTP.КодСостояния = 200;
	//		Если стррРезультат.ЗапросВыполнен тогда
	//			ОтветСтрока = ОтветHTTP.ПолучитьТелоКакСтроку("UTF-8");
	//			стррРезультат.ОтветСервера = ОтветСтрока; //ГУИД для запроса о статусе сообщения
	//		иначе
	//			стррРезультат.ОтветСервера = ОписаниеОшибкиОтправки(ОтветHTTP.КодСостояния);
	//		КонецЕсли;
	//	Исключение
	//		стррРезультат.ОтветСервера = ОписаниеОшибки();
	//	КонецПопытки;
	//	
	//	соотвОтвет.Вставить(ТекущийНомер, стррРезультат);
	//	
	//КонецЦикла;
	//
	//Возврат соотвОтвет;
	
//БП	
	Логин = "webservice";
	Пароль = "*5leAeqE}Y";
	ПутьКСерверу = "msk.tab-is.ru/aid_database";
	ПутьКСервису = "/hs/AID_API/w1/PhoneCall";
	
	//передача параметров
	СтруктураПараметров = Новый Структура;	
	СтруктураПараметров.Вставить("keyBS",КешНастроекПровайдера.КлючБС);
	СтруктураПараметров.Вставить("messageparameters",ПараметрыЗапроса);
	СтруктураПараметров.Вставить("voice",Строка(КешНастроекПровайдера.ПровайдерТелефония));

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
		ПараметрыРезультат = ПрочитатьJSON(ЧтениеJSON);	
	Исключение
		Сообщить(ТелоЗапроса);
	КонецПопытки;

		Возврат ПараметрыРезультат;
	
	
КонецФункции

Функция СтатусДоставкиГП(КодСостояния)
	СоответствиеСтатусов = Новый Соответствие;
	СоответствиеСтатусов.Вставить("200", "Доставлено");
	СоответствиеСтатусов.Вставить("202", "Отправляется");
	СоответствиеСтатусов.Вставить("400", "НеОтправлялось");
	СоответствиеСтатусов.Вставить("404", "НеОтправлялось");
	СоответствиеСтатусов.Вставить("500", "НеДоставлено");
	
	Результат = СоответствиеСтатусов[НРег(КодСостояния)];
	Возврат ?(Результат = Неопределено, "Ошибка", Результат);
	
КонецФункции

Функция ОписанияОшибок()
	
	ОписанияОшибокОтправки = Новый Соответствие;
	ОписанияОшибокОтправки.Вставить("400", НСтр("ru = 'Неверный идентификатор задачи.'"));
	ОписанияОшибокОтправки.Вставить("500", НСтр("ru = 'Внутренняя ошибка сервиса.'"));
	
	ОписанияОшибокДоставки = Новый Соответствие;
	ОписанияОшибокДоставки.Вставить("202", НСтр("ru = 'Звонок еще в очереди.'"));
	ОписанияОшибокДоставки.Вставить("400", НСтр("ru = 'Не передан идентификатор звонка.'"));
	ОписанияОшибокДоставки.Вставить("404", НСтр("ru = 'Идентификатор звонка не найден (или пока не успел добавиться в очередь).'"));
	ОписанияОшибокДоставки.Вставить("500", НСтр("ru = 'Внутренняя ошибка сервиса.'"));
	
	Возврат Новый Структура("Отправка, Доставка", ОписанияОшибокОтправки, ОписанияОшибокДоставки);
	
КонецФункции

Функция ОписаниеОшибкиОтправки(КодОшибки)
	ОписанияОшибок = ОписанияОшибок().Отправка;
	ТекстСообщения = ОписанияОшибок[КодОшибки];
	Если ТекстСообщения = Неопределено Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Сообщение не отправлено (код ошибки: %1).'"), КодОшибки);
	КонецЕсли;
	Возврат ТекстСообщения;
КонецФункции

Функция ОписаниеОшибкиДоставки(КодОшибки)
	ОписанияОшибок =ОписанияОшибок().Доставка;
	ТекстСообщения = ОписанияОшибок[КодОшибки];
	Если ТекстСообщения = Неопределено Тогда
		ТекстСообщения = НСтр("ru = 'Отказ выполнения операции. Код ошибки: '") + СокрЛП(КодОшибки);
	КонецЕсли;
	Возврат ТекстСообщения;
КонецФункции

Функция МассивПолучателейСтрокой(Массив)
	Результат = "";
	Для Каждого Элемент Из Массив Цикл
		Номер = ФорматироватьНомер(Элемент);
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
	ДопустимыеСимволы = "1234567890";
	Для Позиция = 1 По СтрДлина(Номер) Цикл
		Символ = Сред(Номер,Позиция,1);
		Если СтрНайти(ДопустимыеСимволы, Символ) > 0 Тогда
			Результат = Результат + Символ;
		КонецЕсли;
	КонецЦикла;
	Возврат Результат;	
КонецФункции

Процедура ПриОпределенииНастроек(Настройки) Экспорт
	
	Настройки.АдресОписанияУслугиВИнтернете = "";
	Настройки.ПриОпределенииСпособовАвторизации = Истина;
	
КонецПроцедуры

Процедура ПриОпределенииСпособовАвторизации(СпособыАвторизации) Экспорт
	
	ПоляАвторизации = Новый СписокЗначений;
	ПоляАвторизации.Добавить("Пароль", НСтр("ru = 'api_id'"));
	СпособыАвторизации.Вставить("ПоКлючу", ПоляАвторизации);
	
КонецПроцедуры