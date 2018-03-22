Перем ИБ_Ид; // infobase
Перем ИБ_Имя; // name
Перем ИБ_Описание; // descr
Перем ИБ_ПолноеОписание;
Перем ИБ_Параметры;

Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем ИБ_Администратор;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера		- АгентКластера	- ссылка на родительский объект агента кластера
//   Кластер			- Кластер		- ссылка на родительский объект кластера
//   Ид					- Строка		- идентификатор информационной базы в кластере
//   Администратор 			- Строка	- администратор информационной базы
//   ПарольАдминистратора 	- Строка	- пароль администратора информационной базы
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Ид, Администратор = "", ПарольАдминистратора = "")

	Если НЕ ЗначениеЗаполнено(Ид) Тогда
		Возврат;
	КонецЕсли;

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	ИБ_Ид = Ид;
	
	Если ЗначениеЗаполнено(Администратор) Тогда
		ИБ_Администратор = Новый Структура("Администратор, Пароль", Администратор, ПарольАдминистратора);
	Иначе
		ИБ_Администратор = Неопределено;
	КонецЕсли;
	
	ОбновитьДанные();

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
Процедура ОбновитьДанные()

	ТекОписание = ПолучитьОписаниеИБ();

	Если ТекОписание = Неопределено Тогда
		ИБ_ПолноеОписание = Ложь;
		ТекОписание = ПолучитьОписаниеИБСокращенно();
	Иначе
		ИБ_ПолноеОписание = Истина;
	КонецЕсли;
			
	ИБ_Имя = ТекОписание.Получить("name");
	ИБ_Описание = ТекОписание.Получить("descr");

	ПараметрыОбъекта = ПолучитьСтруктуруПараметровОбъекта();

	ИБ_Параметры = Новый Структура();

	Для Каждого ТекЭлемент Из ПараметрыОбъекта Цикл
		ЗначениеПараметра = Служебный.ПолучитьЗначениеИзСтруктуры(ТекОписание,
																  ТекЭлемент.Значение.ИмяПоляРАК,
																  ТекЭлемент.Значение.ЗначениеПоУмолчанию); 
		ИБ_Параметры.Вставить(ТекЭлемент.Ключ, ЗначениеПараметра);
	КонецЦикла;

КонецПроцедуры // ОбновитьДанные()

// Функция возвращает полное описание информационной базы 1С
//
// Возвращаемое значение:
//	Соответствие - полное описание информационной базы 1С
//   
Функция ПолучитьОписаниеИБ()

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("infobase");
	ПараметрыЗапуска.Добавить("info");

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	ПараметрыЗапуска.Добавить(СтрШаблон("--infobase=%1", Ид()));
	ПараметрыЗапуска.Добавить(СтрокаАвторизации());
	
	КодВозврата = Служебный.ВыполнитьКоманду(ПараметрыЗапуска, Ложь);
	
	Если НЕ КодВозврата = 0 Тогда
		Если Найти(Служебный.ВыводКоманды(), "Недостаточно прав пользователя") = 0 Тогда
			ВызватьИсключение Служебный.ВыводКоманды();
		Иначе
			Возврат Неопределено;
		КонецЕсли;
	КонецЕсли;
		
	МассивРезультатов = Служебный.РазобратьВыводКоманды(Служебный.ВыводКоманды());

	Возврат МассивРезультатов[0];

КонецФункции // ПолучитьОписаниеИБ()

// Функция возвращает сокращенное описание информационной базы 1С
//
// Возвращаемое значение:
//	Соответствие - сокращенное описание информационной базы 1С
//   
Функция ПолучитьОписаниеИБСокращенно()

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("infobase");
	ПараметрыЗапуска.Добавить("summary");
	ПараметрыЗапуска.Добавить("info");

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	ПараметрыЗапуска.Добавить(СтрШаблон("--infobase=%1", Ид()));
	ПараметрыЗапуска.Добавить(СтрокаАвторизации());
	
	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	МассивРезультатов = Служебный.РазобратьВыводКоманды(Служебный.ВыводКоманды());

	Возврат МассивРезультатов[0];

КонецФункции // ПолучитьОписаниеИБСокращенно()

// Функция возвращает строку параметров авторизации для информационной базы 1С
//   
// Возвращаемое значение:
//	Строка - строка параметров авторизации на агенте кластера 1С
//
Функция СтрокаАвторизации() Экспорт
	
	Если НЕ ТипЗнч(ИБ_Администратор)  = Тип("Структура") Тогда
		Возврат "";
	КонецЕсли;

	Если НЕ ИБ_Администратор.Свойство("Администратор") Тогда
		Возврат "";
	КонецЕсли;

	Лог.Отладка("Администратор " + ИБ_Администратор.Администратор);
	Лог.Отладка("Пароль <***>");

	СтрокаАвторизации = "";
	Если Не ПустаяСтрока(ИБ_Администратор.Администратор) Тогда
		СтрокаАвторизации = СтрШаблон("--infobase-user=%1 --infobase-pwd=%2",
									  ИБ_Администратор.Администратор,
									  ИБ_Администратор.Пароль);
	КонецЕсли;
			
	Возврат СтрокаАвторизации;
	
КонецФункции // СтрокаАвторизации()
	
// Процедура устанавливает параметры авторизации для информационной базы 1С
//   
// Параметры:
//   Администратор 		- Строка	- администратор информационной базы 1С
//   Пароль			 	- Строка	- пароль администратора информационной базы 1С
//
Процедура УстановитьАдминистратора(Администратор, Пароль) Экспорт

	ИБ_Администратор = Новый Структура("Администратор, Пароль", Администратор, Пароль);

КонецПроцедуры // УстановитьАдминистратора()

// Функция возвращает идентификатор информационной базы 1С
//   
// Возвращаемое значение:
//	Строка - идентификатор информационной базы 1С
//
Функция Ид() Экспорт

	Возврат ИБ_Ид;

КонецФункции // Ид()

// Функция возвращает имя информационной базы 1С
//   
// Возвращаемое значение:
//	Строка - имя информационной базы 1С
//
Функция Имя() Экспорт

	Возврат ИБ_Имя;
	
КонецФункции // Имя()

// Функция возвращает описание информационной базы 1С
//   
// Возвращаемое значение:
//	Строка - описание информационной базы 1С
//
Функция Описание() Экспорт

	Возврат ИБ_Описание;
	
КонецФункции // Описание()

// Функция возвращает признак доступности полного описания информационной базы 1С
//   
// Возвращаемое значение:
//	Булево - Истина - доступно полное описание; Ложь - доступно сокращенное описание
//
Функция ПолноеОписание() Экспорт

	Возврат ИБ_ПолноеОписание;
	
КонецФункции // ПолноеОписание()

// Функция возвращает параметры информационной базы 1С
//   
// Возвращаемое значение:
//	Строка - параметры информационной базы 1С
//
Функция Параметры() Экспорт
	
		Возврат ИБ_Параметры;
		
КонецФункции // Параметры()
	
// Процедура изменяет параметры информационной базы
//   
// Параметры:
//   ПараметрыИБ	 	- Структура		- новые параметры информационной базы
//
Процедура Изменить(Знач ПараметрыИБ = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыИБ) = Тип("Структура") Тогда
		ПараметрыИБ = Новый Структура();
	КонецЕсли;

	ПараметрыЗапуска = Новый Массив();

	ПараметрыЗапуска.Добавить("infobase");
	ПараметрыЗапуска.Добавить("update");

	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить(СтрШаблон("--infobase=%1", Ид()));
	ПараметрыЗапуска.Добавить(СтрокаАвторизации());

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());
		
	ПараметрыОбъекта = ПолучитьСтруктуруПараметровОбъекта();

	Для Каждого ТекЭлемент Из ПараметрыОбъекта Цикл
		Если НЕ ПараметрыИБ.Свойство(ТекЭлемент.Ключ) Тогда
			Продолжить;
		КонецЕсли;
		ПараметрыЗапуска.Добавить(СтрШаблон(ТекЭлемент.ПараметрКоманды + "=%1", ПараметрыИБ[ТекЭлемент.Ключ]));
	КонецЦикла;

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Лог.Информация(Служебный.ВыводКоманды());

	ОбновитьДанные();

КонецПроцедуры // Изменить()

// Функция возвращает коллекцию параметров объекта
//   
// Параметры:
//   ИмяПоляКлюча 		- Строка	- имя поля, значение которого будет использовано
//									  в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//	Соответствие - коллекция параметров объекта, для получения/изменения значений
//
Функция ПолучитьСтруктуруПараметровОбъекта(ИмяПоляКлюча = "ИмяПараметра") Экспорт
	
	СтруктураПараметров = Новый Соответствие();

	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ТипСУБД"								, "dbms", Перечисления.ТипыСУБД.MSSQLServer);
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"АдресСервераСУБД"						, "db-server", "localhost");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ИмяБазыСУБД"							, "db-name");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ИмяПользователяБазыСУБД"				, "db-user", "sa");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ПарольПользователяБазыСУБД"			, "db-pwd");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"НачалоБлокировкиСеансов"				, "denied-from", '00010101');
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ОкончаниеБлокировкиСеансов"			, "denied-to", '00010101');
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"СообщениеБлокировкиСеансов"			, "denied-message");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ПараметрБлокировкиСеансов"				, "denied-parameter");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"КодРазрешения"							, "permission-code");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"БлокировкаСеансовВключена"				, "sessions-deny", Перечисления.ВклВыкл.Выключено);
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"БлокировкаРегламентныхЗаданийВключена"	, "scheduled-jobs-deny", Перечисления.ВклВыкл.Выключено);
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ВыдачаЛицензийСервером"				, "license-distribution", Перечисления.ПраваДоступа.Разрешено);
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ПараметрыВнешнегоУправленияСеансами"	, "external-session-manager-connection-string");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ОбязательноеВнешнееУправлениеСеансами"	, "external-session-manager-required", Перечисления.ДаНет.Нет);
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ПрофильБезопасности"					, "security-profile-name");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ПрофильБезопасностиБезопасногоРежима"	, "safe-mode-security-profile-name");

	Возврат СтруктураПараметров;

КонецФункции // ПолучитьСтруктуруПараметровОбъекта()

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
