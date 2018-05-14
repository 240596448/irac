﻿#Использовать "../src"
#Использовать "./fixtures"
#Использовать asserts
#Использовать fs
#Использовать tempfiles
#Использовать moskito

Перем ЮнитТест;
Перем АгентКластера;
Перем МокИсполнительКоманд;
Перем ВременныйКаталог;

// Процедура выполняется после запуска теста
//
Процедура ПередЗапускомТеста() Экспорт
	
	АдресСервера = "localhost";
	ПортСервера = 1545;

	Если АгентКластера = Неопределено Тогда
		АгентКластера = Новый АдминистрированиеКластера(АдресСервера, ПортСервера, "");
	КонецЕсли;	

	Если МокИсполнительКоманд = Неопределено Тогда
		МокИсполнительКоманд = Мок.Получить(Новый ИсполнительКоманд(""));
	КонецЕсли;

	АгентКластера.УстановитьИсполнительКоманд(МокИсполнительКоманд);
	
	Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
	Лог.УстановитьУровень(УровниЛога.Отладка);

КонецПроцедуры // ПередЗапускомТеста()

// Функция возвращает список тестов для выполнения
//
// Параметры:
//	Тестирование	- Тестер		- Объект Тестер (1testrunner)
//	
// Возвращаемое значение:
//	Массив		- Массив имен процедур-тестов
//	
Функция ПолучитьСписокТестов(Тестирование) Экспорт
	
	ЮнитТест = Тестирование;
	
	СписокТестов = Новый Массив;
	СписокТестов.Добавить("ТестДолжен_ПодключитьсяКСерверуАдминистрирования");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокКластеров");
	СписокТестов.Добавить("ТестДолжен_ПолучитьПараметрыКластера");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокМенеджеров");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокСерверовКластера");
	СписокТестов.Добавить("ТестДолжен_ПолучитьПараметрыСервераКластера");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокРабочихПроцессов");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокЛицензийПроцесса");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокСервисов");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокБазНаСервере");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСокращенныеПараметрыБазыНаСервере");
	СписокТестов.Добавить("ТестДолжен_ПолучитьПолныеПараметрыБазыНаСервере");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокСеансовКластера");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокЛицензийСеанса");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокСоединенийКластера");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокНазначенийФункциональностиСервера");
	СписокТестов.Добавить("ТестДолжен_ПолучитьПараметрыНазначенияФункциональностиСервера");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокПрофилейБезопасностиКластера");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокКаталоговПрофиля");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокCOMКлассовПрофиля");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокКомпонентПрофиля");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокМодулейПрофиля");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокПриложенийПрофиля");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокИнтернетРесурсовПрофиля");

	Возврат СписокТестов;
	
КонецФункции // ПолучитьСписокТестов()

// Процедура выполняется после запуска теста
//
Процедура ПослеЗапускаТеста() Экспорт

	Если ЗначениеЗаполнено(ВременныйКаталог) Тогда

		Утверждения.ПроверитьИстину(НайтиФайлы(ВременныйКаталог, "*").Количество() = 0,
			"Во временном каталоге " + ВременныйКаталог + " не должно остаться файлов");
	
		ВременныеФайлы.УдалитьФайл(ВременныйКаталог);

		Утверждения.ПроверитьИстину(Не ФС.КаталогСуществует(ВременныйКаталог), "Временный каталог должен быть удален");

		ВременныйКаталог = "";

	КонецЕсли;

КонецПроцедуры // ПослеЗапускаТеста()

// Процедура - тест
//
Процедура ТестДолжен_ПодключитьсяКСерверуАдминистрирования() Экспорт
	
	СтрокаПроверки = "localhost:1545";
	ДлинаСтроки = СтрДлина(СтрокаПроверки);

	Утверждения.ПроверитьРавенство(Лев(АгентКластера.ОписаниеПодключения(), ДлинаСтроки), СтрокаПроверки);

КонецПроцедуры // ТестДолжен_ПодключитьсяКСерверуАдминистрирования()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокКластеров() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры().Список();

	Утверждения.ПроверитьБольше(Кластеры.Количество(), 0, "Не удалось получить список кластеров");

КонецПроцедуры // ТестДолжен_ПолучитьСписокКластеров()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьПараметрыКластера() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Параметры");
	
	Кластеры = АгентКластера.Кластеры().Список();

	Кластер = Кластеры[0];

	Имя = Кластер.Получить("Имя");
	Сервер = Кластер.Получить("Сервер");
	Порт = Кластер.Получить("Порт");
	РежимРаспределенияНагрузки = Кластер.Получить("РежимРаспределенияНагрузки");

	Утверждения.ПроверитьРавенство(Имя, """Локальный кластер""", "Ошибка проверки имени кластера");
	Утверждения.ПроверитьРавенство(Сервер, "Sport1", "Ошибка проверки сервера кластера");
	Утверждения.ПроверитьРавенство(Порт, "1541", "Ошибка проверки порта кластера");
	Утверждения.ПроверитьРавенство(РежимРаспределенияНагрузки
								, Перечисления.РежимыРаспределенияНагрузки.ПоПроизводительности
								, "Ошибка проверки режима распределения нагрузки кластера");
	
КонецПроцедуры // ТестДолжен_ПолучитьПараметрыКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокМенеджеров() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры().Список();

	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Менеджеры.Список");
	
		Менеджеры = Кластер.Менеджеры().Список();
		Прервать;
	КонецЦикла;

	Утверждения.ПроверитьБольше(Менеджеры.Количество(), 0, "Не удалось получить список менеджеров");

КонецПроцедуры // ТестДолжен_ПолучитьСписокМенеджеров()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокСерверовКластера() Экспорт
	
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Серверы.Список");
	
		Серверы = Кластер.Серверы().Список();
		Прервать;
	КонецЦикла;

	Утверждения.ПроверитьБольше(Серверы.Количество(), 0, "Не удалось получить список серверов кластера");
	
КонецПроцедуры // ТестДолжен_ПолучитьСписокСерверовКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьПараметрыСервераКластера() Экспорт
	
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Серверы.Параметры");
	
		Серверы = Кластер.Серверы().Список();
		Прервать;
	КонецЦикла;

	Сервер = Серверы[0];

	Имя = Сервер.Получить("Имя");
	Хост = Сервер.Получить("Сервер");
	Порт = Сервер.Получить("Порт");
	ДиапазонПортов = Сервер.Получить("ДиапазонПортов");

	Утверждения.ПроверитьРавенство(Имя, """Центральный сервер""", "Ошибка проверки имени сервера");
	Утверждения.ПроверитьРавенство(Хост, "Sport1", "Ошибка проверки сервера кластера");
	Утверждения.ПроверитьРавенство(Порт, "1540", "Ошибка проверки порта кластера");
	Утверждения.ПроверитьРавенство(ДиапазонПортов, "1560:1591", "Ошибка проверки диапазона портов сервера");
	
КонецПроцедуры // ТестДолжен_ПолучитьПараметрыСервераКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокРабочихПроцессов() Экспорт
	
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "РабочиеПроцессы.Список");
	
		Процессы = Кластер.РабочиеПроцессы().Список();
		Прервать;
	КонецЦикла;

	Утверждения.ПроверитьБольше(Процессы.Количество(), 0, "Не удалось получить список рабочих процессов");
	
КонецПроцедуры // ТестДолжен_ПолучитьСписокРабочихПроцессов()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокЛицензийПроцесса() Экспорт
	
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"РабочиеПроцессы.Список");
	
		Процессы = Кластер.РабочиеПроцессы().Список();
		Прервать;
	КонецЦикла;

	Для Каждого Процесс Из Процессы Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"РабочиеПроцессы.Лицензии.Список");
	
		Лицензии = Процесс.Лицензии().Список();
		Прервать;
	КонецЦикла;

	Утверждения.ПроверитьБольше(Лицензии.Количество(), 0, "Не удалось получить список лицензий рабочего процесса");
	
КонецПроцедуры // ТестДолжен_ПолучитьСписокРабочихПроцессов()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокСервисов() Экспорт
	
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Сервисы.Список");
	
		Сервисы = Кластер.Сервисы().Список();
		Прервать;
	КонецЦикла;

	Утверждения.ПроверитьБольше(Сервисы.Количество(), 0, "Не удалось получить список сервисов");
	
КонецПроцедуры // ТестДолжен_ПолучитьСписокСервисов()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокБазНаСервере() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ИБ.Список");
	
		ИБ = Кластер.ИнформационныеБазы().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(ИБ.Количество(), 0, "Не удалось получить список информационных баз");

КонецПроцедуры // ТестДолжен_ПолучитьСписокБазНаСервере()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСокращенныеПараметрыБазыНаСервере() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ИБ.Список");
	
		ИБ = Кластер.ИнформационныеБазы();
		Прервать;
	КонецЦикла;
	
	АгентКластера.ИсполнительКоманд().Когда().КодВозврата().ТогдаВозвращает(0);
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ИБ.НедостаточноПрав");
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ИБ.СокращенныеПараметры");

	База = ИБ.Получить("DEV_User1_ACC_Cust1");

	Имя = База.Получить("Имя");
	Описание = База.Получить("Описание");
	ПолноеОписание = База.Получить("ПолноеОписание");

	Утверждения.ПроверитьРавенство(Имя, "DEV_User1_ACC_Cust1", "Ошибка проверки имени базы");
	Утверждения.ПроверитьРавенство(Описание, "", "Ошибка проверки описания базы");
	Утверждения.ПроверитьРавенство(ПолноеОписание, Ложь, "Ошибка проверки признака полного описания базы");
	
КонецПроцедуры // ТестДолжен_ПолучитьСокращенныеПараметрыБазыНаСервере()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьПолныеПараметрыБазыНаСервере() Экспорт
	
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ИБ.Список");
	
		ИБ = Кластер.ИнформационныеБазы();
		Прервать;
	КонецЦикла;
	
	АгентКластера.ИсполнительКоманд().Когда().КодВозврата().ТогдаВозвращает(0);
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ИБ.ПолныеПараметры");

	База = ИБ.Получить("DEV_User1_ACC_Cust1");
	База.УстановитьАдминистратора("""Пользователь И. Б.""", "123");

	Имя = База.Получить("Имя", Истина);
	Описание = База.Получить("Описание");
	ПолноеОписание = База.Получить("ПолноеОписание");
	ТипСУБД	= База.Получить("ТипСУБД");
	ИмяБазыСУБД	= База.Получить("ИмяБазыСУБД");

	Утверждения.ПроверитьРавенство(Имя, "DEV_User1_ACC_Cust1", "Ошибка проверки имени базы");
	Утверждения.ПроверитьРавенство(Описание, "", "Ошибка проверки описания базы");
	Утверждения.ПроверитьРавенство(ПолноеОписание, Ложь, "Ошибка проверки признака полного описания базы");
	Утверждения.ПроверитьРавенство(ТипСУБД, Перечисления.ТипыСУБД.MSSQLServer, "Ошибка проверки типа сервера СУБД");
	Утверждения.ПроверитьРавенство(ИмяБазыСУБД, "DEV_User1_ACC_Cust1", "Ошибка проверки имени базы на сервере СУБД");
	
КонецПроцедуры // ТестДолжен_ПолучитьПолныеПараметрыБазыНаСервере()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокСеансовКластера() Экспорт
    
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Сеансы.Список");
	
		Сеансы = Кластер.Сеансы().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(Сеансы.Количество(), 0, "Не удалось получить список сеансов");

КонецПроцедуры // ТестДолжен_ПолучитьСписокСеансовКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокЛицензийСеанса() Экспорт
	
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Сеансы.Список");
	
		Сеансы = Кластер.Сеансы().Список();
		Прервать;
	КонецЦикла;

	Для Каждого Сеанс Из Сеансы Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Сеансы.Лицензии.Список");
	
		Лицензии = Сеанс.Лицензии().Список();
		Прервать;
	КонецЦикла;

	Утверждения.ПроверитьБольше(Лицензии.Количество(), 0, "Не удалось получить список лицензий сеанса");
	
КонецПроцедуры // ТестДолжен_ПолучитьСписокЛицензийСеанса()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокСоединенийКластера() Экспорт
    
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Соединения.Список");
	
		Соединения = Кластер.Соединения().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(Соединения.Количество(), 0, "Не удалось получить список соединений");

КонецПроцедуры // ТестДолжен_ПолучитьСписокСоединенийКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокНазначенийФункциональностиСервера() Экспорт
	
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"Серверы.Список");
	
		Серверы = Кластер.Серверы().Список();
		Прервать;
	КонецЦикла;

	Для Каждого Сервер Из Серверы Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"Серверы.Параметры");
	
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"НазначенияФункциональности.Список");
	
		НазначенияФункциональности = Сервер.НазначенияФункциональности().Список();
		Прервать;
	КонецЦикла;

	Утверждения.ПроверитьБольше(НазначенияФункциональности.Количество(),
								0,
								"Не удалось получить список назначений функциональности");
	
КонецПроцедуры // ТестДолжен_ПолучитьСписокНазначенийФункциональностиСервера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьПараметрыНазначенияФункциональностиСервера() Экспорт
    
	ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
														"Кластеры.Список");
	
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"Серверы.Список");
	
		Серверы = Кластер.Серверы().Список();
		Прервать;
	КонецЦикла;

	Для Каждого Сервер Из Серверы Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"Серверы.Параметры");
	
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"НазначенияФункциональности.Параметры");
	
		НазначенияФункциональности = Сервер.НазначенияФункциональности().Список();
		Прервать;
	КонецЦикла;

	НазначениеФункциональности = НазначенияФункциональности[0];

	ИмяИБ = НазначениеФункциональности.Получить("ИмяИБ");
	ТипОбъекта = НазначениеФункциональности.Получить("ТипОбъекта");
	ТипНазначения = НазначениеФункциональности.Получить("ТипНазначения");

	Утверждения.ПроверитьРавенство(ИмяИБ, "DEV_User1_TRADE_Cust1", "Ошибка проверки имени ИБ назначения функциональности");
	Утверждения.ПроверитьРавенство(ТипОбъекта
								, """" + Перечисления.ОбъектыНазначенияФункциональности.КлиентскиеСоединения + """"
								, "Ошибка проверки типа объекта назначения функциональности");
	Утверждения.ПроверитьРавенство(ТипНазначения
								, Перечисления.ТипыНазначенияФункциональности.Назначать
								, "Ошибка проверки типа назначения функциональности");
	
КонецПроцедуры // ТестДолжен_ПолучитьПараметрыНазначенияФункциональностиСервера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокПрофилейБезопасностиКластера() Экспорт
    
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ПрофилиБезопасности.Список");
	
		Профили = Кластер.ПрофилиБезопасности().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(Профили.Количество(), 0, "Не удалось получить список профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокПрофилейБезопасностиКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокКаталоговПрофиля() Экспорт
    
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"ПрофилиБезопасности.Список");
	
		Профили = Кластер.ПрофилиБезопасности().Список(, Истина);
		Прервать;
	КонецЦикла;
	
	Для Каждого Профиль Из Профили Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"ПрофилиБезопасности.Каталоги.Список");
	
		Каталоги = Профиль.Каталоги().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(Каталоги.Количество(),
								0,
								"Не удалось получить список каталогов профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокКаталоговПрофиля()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокCOMКлассовПрофиля() Экспорт
    
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"ПрофилиБезопасности.Список");
	
		Профили = Кластер.ПрофилиБезопасности().Список(, Истина);
		Прервать;
	КонецЦикла;
	
	Для Каждого Профиль Из Профили Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"ПрофилиБезопасности.COMКлассы.Список");
	
		COMКлассы = Профиль.COMКлассы().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(COMКлассы.Количество(),
								0,
								"Не удалось получить список COM-классов профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокCOMКлассовПрофиля()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокКомпонентПрофиля() Экспорт
    
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"ПрофилиБезопасности.Список");
	
		Профили = Кластер.ПрофилиБезопасности().Список(, Истина);
		Прервать;
	КонецЦикла;
	
	Для Каждого Профиль Из Профили Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"ПрофилиБезопасности.Компоненты.Список");
	
		ВнешниеКомпоненты = Профиль.ВнешниеКомпоненты().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(ВнешниеКомпоненты.Количество(),
								0,
								"Не удалось получить список внешних компонент профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокКомпонентПрофиля()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокМодулейПрофиля() Экспорт
    
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"ПрофилиБезопасности.Список");
	
		Профили = Кластер.ПрофилиБезопасности().Список(, Истина);
		Прервать;
	КонецЦикла;
	
	Для Каждого Профиль Из Профили Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"ПрофилиБезопасности.Модули.Список");
	
		ВнешниеМодули = Профиль.ВнешниеМодули().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(ВнешниеМодули.Количество(),
								0,
								"Не удалось получить список внешних модулей профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокМодулейПрофиля()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокПриложенийПрофиля() Экспорт
    
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"ПрофилиБезопасности.Список");
	
		Профили = Кластер.ПрофилиБезопасности().Список(, Истина);
		Прервать;
	КонецЦикла;
	
	Для Каждого Профиль Из Профили Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"ПрофилиБезопасности.Приложения.Список");
	
		Приложения = Профиль.Приложения().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(Приложения.Количество(),
								0,
								"Не удалось получить список приложений профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокПриложенийПрофиля()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокИнтернетРесурсовПрофиля() Экспорт
    
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"ПрофилиБезопасности.Список");
	
		Профили = Кластер.ПрофилиБезопасности().Список(, Истина);
		Прервать;
	КонецЦикла;
	
	Для Каждого Профиль Из Профили Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(),
															"ПрофилиБезопасности.ИнтернетРесурсы.Список");
	
		ИнтернетРесурсы = Профиль.ИнтернетРесурсы().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(ИнтернетРесурсы.Количество(),
								0,
								"Не удалось получить список интернет ресурсов профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокИнтернетРесурсовПрофиля()

