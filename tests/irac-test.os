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
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокМенеджеров");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокСерверовКластера");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокРабочихПроцессов");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокЛицензийПроцесса");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокСервисов");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокБазНаСервере");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокСеансовКластера");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокЛицензийСеанса");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокСоединенийКластера");
	СписокТестов.Добавить("ТестДолжен_ПолучитьСписокНазначенийФункциональностиСервера");
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
Процедура ТестДолжен_ПолучитьСписокМенеджеров() Экспорт
    
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
	
	АгентКластера.УстановитьИсполнительКоманд(Новый ИсполнительКоманд());

	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		Процессы = Кластер.РабочиеПроцессы().Список();
		Прервать;
	КонецЦикла;

	Для Каждого Процесс Из Процессы Цикл
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
Процедура ТестДолжен_ПолучитьСписокСеансовКластера() Экспорт
    
	АгентКластера.УстановитьИсполнительКоманд(Новый ИсполнительКоманд());

	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		Сеансы = Кластер.Сеансы().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(Сеансы.Количество(), 0, "Не удалось получить список сеансов");

КонецПроцедуры // ТестДолжен_ПолучитьСписокСеансовКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокЛицензийСеанса() Экспорт
	
	АгентКластера.УстановитьИсполнительКоманд(Новый ИсполнительКоманд());

	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		Сеансы = Кластер.Сеансы().Список();
		Прервать;
	КонецЦикла;

	Для Каждого Сеанс Из Сеансы Цикл
		Лицензии = Сеанс.Лицензии().Список();
		Прервать;
	КонецЦикла;

	Утверждения.ПроверитьБольше(Лицензии.Количество(), 0, "Не удалось получить список лицензий сеанса");
	
КонецПроцедуры // ТестДолжен_ПолучитьСписокЛицензийСеанса()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокСоединенийКластера() Экспорт
    
	АгентКластера.УстановитьИсполнительКоманд(Новый ИсполнительКоманд());

	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		Соединения = Кластер.Соединения().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(Соединения.Количество(), 0, "Не удалось получить список соединений");

КонецПроцедуры // ТестДолжен_ПолучитьСписокСоединенийКластера()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокНазначенийФункциональностиСервера() Экспорт
	
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Серверы.Список");
	
		Серверы = Кластер.Серверы().Список();
		Прервать;
	КонецЦикла;

	Для Каждого Сервер Из Серверы Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "Серверы.Параметры");
	
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "НазначенияФункциональности.Список");
	
		НазначенияФункциональности = Сервер.НазначенияФункциональности().Список();
		Прервать;
	КонецЦикла;

	Утверждения.ПроверитьБольше(НазначенияФункциональности.Количество(), 0,
								"Не удалось получить список назначений функциональности");
	
КонецПроцедуры // ТестДолжен_ПолучитьСписокНазначенийФункциональностиСервера()

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
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ПрофилиБезопасности.Список");
	
		Профили = Кластер.ПрофилиБезопасности().Список(, Истина);
		Прервать;
	КонецЦикла;
	
	Для Каждого Профиль Из Профили Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ПрофилиБезопасности.Каталоги.Список");
	
		Каталоги = Профиль.Каталоги().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(Каталоги.Количество(), 0, "Не удалось получить список каталогов профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокКаталоговПрофиля()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокCOMКлассовПрофиля() Экспорт
    
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ПрофилиБезопасности.Список");
	
		Профили = Кластер.ПрофилиБезопасности().Список(, Истина);
		Прервать;
	КонецЦикла;
	
	Для Каждого Профиль Из Профили Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ПрофилиБезопасности.COMКлассы.Список");
	
		COMКлассы = Профиль.COMКлассы().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(COMКлассы.Количество(), 0, "Не удалось получить список COM-классов профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокCOMКлассовПрофиля()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокКомпонентПрофиля() Экспорт
    
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ПрофилиБезопасности.Список");
	
		Профили = Кластер.ПрофилиБезопасности().Список(, Истина);
		Прервать;
	КонецЦикла;
	
	Для Каждого Профиль Из Профили Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ПрофилиБезопасности.Компоненты.Список");
	
		ВнешниеКомпоненты = Профиль.ВнешниеКомпоненты().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(ВнешниеКомпоненты.Количество(), 0, "Не удалось получить список внешних компонент профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокКомпонентПрофиля()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокМодулейПрофиля() Экспорт
    
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ПрофилиБезопасности.Список");
	
		Профили = Кластер.ПрофилиБезопасности().Список(, Истина);
		Прервать;
	КонецЦикла;
	
	Для Каждого Профиль Из Профили Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ПрофилиБезопасности.Модули.Список");
	
		ВнешниеМодули = Профиль.ВнешниеМодули().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(ВнешниеМодули.Количество(), 0, "Не удалось получить список внешних модулей профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокМодулейПрофиля()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокПриложенийПрофиля() Экспорт
    
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ПрофилиБезопасности.Список");
	
		Профили = Кластер.ПрофилиБезопасности().Список(, Истина);
		Прервать;
	КонецЦикла;
	
	Для Каждого Профиль Из Профили Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ПрофилиБезопасности.Приложения.Список");
	
		Приложения = Профиль.Приложения().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(Приложения.Количество(), 0, "Не удалось получить список приложений профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокПриложенийПрофиля()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьСписокИнтернетРесурсовПрофиля() Экспорт
    
	Кластеры = АгентКластера.Кластеры().Список();
	
	Для Каждого Кластер Из Кластеры Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ПрофилиБезопасности.Список");
	
		Профили = Кластер.ПрофилиБезопасности().Список(, Истина);
		Прервать;
	КонецЦикла;
	
	Для Каждого Профиль Из Профили Цикл
		ПараметрыКластера.УстановитьВыводИсполнителяКоманд(АгентКластера.ИсполнительКоманд(), "ПрофилиБезопасности.ИнтернетРесурсы.Список");
	
		ИнтернетРесурсы = Профиль.ИнтернетРесурсы().Список();
		Прервать;
	КонецЦикла;
	
	Утверждения.ПроверитьБольше(ИнтернетРесурсы.Количество(), 0, "Не удалось получить список интернет ресурсов профилей безопасности");

КонецПроцедуры // ТестДолжен_ПолучитьСписокИнтернетРесурсовПрофиля()

