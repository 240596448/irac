// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Менеджер_Ид;          // manager
Перем Менеджер_ИдПроцесса;  // pid
Перем Менеджер_Адрес;       // host
Перем Менеджер_Порт;        // port
Перем Менеджер_Свойства;

Перем Кластер_Агент;
Перем Кластер_Владелец;

Перем ПараметрыОбъекта;

Перем ПериодОбновления;
Перем МоментАктуальности;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера      - АгентКластера             - ссылка на родительский объект агента кластера
//   Кластер            - Кластер                   - ссылка на родительский объект кластера
//   Менеджер           - Строка, Соответствие      - идентификатор менеджера в кластере 1С или параметры менеджера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Менеджер)

	Лог = Служебный.Лог();

	Если НЕ ЗначениеЗаполнено(Менеджер) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент, Перечисления.РежимыАдминистрирования.МенеджерыКластера);

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	
	Если ТипЗнч(Менеджер) = Тип("Соответствие") Тогда
		Менеджер_Ид = Менеджер["manager"];
		ЗаполнитьПараметрыМенеджера(Менеджер);
		МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Иначе
		Менеджер_Ид = Менеджер;
		МоментАктуальности = 0;
	КонецЕсли;

	ПериодОбновления = 60000;
	
КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно         - Булево    - Истина - принудительно обновить данные (вызов RAC)
//                                            - Ложь - данные будут получены если истекло время актуальности
//                                                    или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт

	Если НЕ Служебный.ТребуетсяОбновление(Менеджер_Свойства,
			МоментАктуальности, ПериодОбновления, ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ИдентификаторМенеджера"      , Ид());
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Описание");

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения описания менеджера, КодВозврата = %1: %2",
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Если НЕ ЗначениеЗаполнено(МассивРезультатов) Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьПараметрыМенеджера(МассивРезультатов[0]);

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

КонецПроцедуры // ОбновитьДанные()

// Процедура заполняет параметры менеджера кластера 1С
//   
// Параметры:
//   ДанныеЗаполнения        - Соответствие        - данные, из которых будут заполнены параметры менеджера
//   
Процедура ЗаполнитьПараметрыМенеджера(ДанныеЗаполнения)

	Менеджер_Адрес      = ДанныеЗаполнения.Получить("host");
	Менеджер_Порт       = Число(ДанныеЗаполнения.Получить("port"));
	Менеджер_ИдПроцесса = Число(ДанныеЗаполнения.Получить("pid"));

	Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Менеджер_Свойства, ДанныеЗаполнения);

КонецПроцедуры // ЗаполнитьПараметрыМенеджера()

// Функция возвращает коллекцию параметров объекта
//   
// Параметры:
//   ИмяПоляКлюча         - Строка    - имя поля, значение которого будет использовано
//                                      в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//    Соответствие - коллекция параметров объекта, для получения/изменения значений
//
Функция ПараметрыОбъекта(ИмяПоляКлюча = "Имя") Экспорт

	Возврат ПараметрыОбъекта.ОписаниеСвойств(ИмяПоляКлюча);

КонецФункции // ПараметрыОбъекта()

// Функция возвращает идентификатор сервера 1С
//   
// Возвращаемое значение:
//    Строка - идентификатор сервера 1С
//
Функция Ид() Экспорт

	Возврат Менеджер_Ид;

КонецФункции // Ид()

// Функция возвращает идентификатор процесса менеджера 1С
//   
// Возвращаемое значение:
//    Строка - идентификатор процесса менеджера 1С
//
Функция ИдПроцесса() Экспорт

	Возврат Менеджер_ИдПроцесса;

КонецФункции // ИдПроцесса()

// Функция возвращает адрес менеджера 1С
//   
// Возвращаемое значение:
//    Строка - адрес сервера 1С
//
Функция Адрес() Экспорт
	
	Если Служебный.ТребуетсяОбновление(Менеджер_Адрес, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Истина);
	КонецЕсли;

	Возврат Менеджер_Адрес;
	    
КонецФункции // Адрес()
	
// Функция возвращает порт менеджера 1С
//   
// Возвращаемое значение:
//    Строка - порт менеджера 1С
//
Функция Порт() Экспорт
	
	Если Служебный.ТребуетсяОбновление(Менеджер_Порт, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Истина);
	КонецЕсли;

	Возврат Менеджер_Порт;
	    
КонецФункции // Порт()
	
// Функция возвращает значение параметра кластера 1С
//   
// Параметры:
//   ИмяПоля                 - Строка        - Имя параметра кластера
//   ОбновитьПринудительно     - Булево        - Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//    Произвольный - значение параметра кластера 1С
//
Функция Получить(ИмяПоля, ОбновитьПринудительно = Ложь) Экспорт
	
	ОбновитьДанные(ОбновитьПринудительно);

	ЗначениеПоля = Неопределено;

	Если НЕ Найти("ИД, MANAGER", ВРег(ИмяПоля)) = 0 Тогда
		Возврат Менеджер_Ид;
	ИначеЕсли НЕ Найти("ИДПРОЦЕССА, PID", ВРег(ИмяПоля)) = 0 Тогда
		Возврат Менеджер_ИдПроцесса;
	ИначеЕсли НЕ Найти("СЕРВЕР, HOST", ВРег(ИмяПоля)) = 0 Тогда
		Возврат Менеджер_Адрес;
	ИначеЕсли НЕ Найти("ПОРТ, PORT", ВРег(ИмяПоля)) = 0 Тогда
		Возврат Менеджер_Порт;
	Иначе
		ЗначениеПоля = Менеджер_Свойства.Получить(ИмяПоля);
	КонецЕсли;
	
	Если ЗначениеПоля = Неопределено Тогда
	    
		ОписаниеПараметра = ПараметрыОбъекта("ИмяРАК").Получить(ИмяПоля);

		Если НЕ ОписаниеПараметра = Неопределено Тогда
			ЗначениеПоля = Менеджер_Свойства.Получить(ОписаниеПараметра["Имя"]);
		КонецЕсли;
	КонецЕсли;

	Возврат ЗначениеПоля;
	    
КонецФункции // Получить()
