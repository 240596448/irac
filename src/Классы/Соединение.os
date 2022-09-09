// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Соединение_Ид;
Перем Соединение_Свойства;
Перем Соединение_ПолноеОписание;   // Истина - получено полное описание; Ложь - сокращенное
Перем ПараметрыОбъекта;    // - КомандыОбъекта    - объект-генератор команд объекта кластера

Перем Кластер_Агент;       // - УправлениеКластером1С    - родительский объект агента кластера
Перем Кластер_Владелец;    // - Кластер                  - родительский объект кластера
Перем Процесс_Владелец;
Перем ИБ_Владелец;

Перем ПериодОбновления;      // - Число    - период обновления информации от сервиса RAS
Перем МоментАктуальности;    // - Число    - последний момент получения информации от сервиса RAS

Перем Лог;      // - Логирование     - объект-логгер

// Конструктор
//   
// Параметры:
//   АгентКластера    - УправлениеКластером1С    - ссылка на родительский объект агента кластера
//   Кластер          - Кластера                 - ссылка на родительский объект кластера
//   Процесс          - Процесс                  - ссылка на родительский объект процесса
//   ИБ               - ИнформационнаяБаза       - ссылка на родительский объект информационной базы
//   Соединение       - Строка, Соответствие     - идентификатор или параметры соединения
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, ИБ, Соединение, Процесс = Неопределено)
	
	Лог = Служебный.Лог();

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	ИБ_Владелец = ИБ;
	Процесс_Владелец = Процесс;
	
	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент, Перечисления.РежимыАдминистрирования.Соединения);

	Если ТипЗнч(Соединение) = Тип("Соответствие") Тогда
		Соединение_Ид = Соединение["connection"];
		Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Соединение_Свойства, Соединение);
		МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Иначе
		Соединение_Ид = Соединение;
		МоментАктуальности = 0;
	КонецЕсли;
	
	ПериодОбновления = Служебный.ПериодОбновленияДанныхОбъекта(ЭтотОбъект);
	
КонецПроцедуры // ПриСозданииОбъекта()

// Функция возвращает ИД объекта
//
// Возвращаемое значение:
//    Строка     - идентификатор объекта
//
Функция Ид() Экспорт
	
	Возврат Соединение_Ид;
	
КонецФункции // Ид()

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   РежимОбновления          - Число        - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//                                             2 - обновить только основную информацию (вызов RAC)
//   
Процедура ОбновитьДанные(РежимОбновления = 0) Экспорт
	
	Если НЕ ТребуетсяОбновление(РежимОбновления) Тогда
		Возврат;
	КонецЕсли;

	Соединение_ПолноеОписание = Ложь;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("ИдентификаторСоединения", Ид());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Описание");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		Лог.Предупреждение("Ошибка получения описания соединения ""%1"" кластера ""%2"",
		                   | КодВозврата = %3:%4%5",
		                   Ид(),
		                   Кластер_Владелец.Имя(),
		                   КодВозврата,
		                   Символы.ПС,
		                   ВыводКоманды);
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Если НЕ ЗначениеЗаполнено(МассивРезультатов) Тогда
		Кластер_Владелец.Соединения().ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);
		Возврат;
	КонецЕсли;

	Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Соединение_Свойства, МассивРезультатов[0]);

	Если НЕ РежимОбновления = Перечисления.РежимыОбновленияДанных.ТолькоОсновные Тогда
		ДополнитьДанные();
	КонецЕсли;

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
КонецПроцедуры // ОбновитьДанные()

// Процедура получает и устанавливает полные данные соединений от утилиты администрирования кластера 1С
// полные данные доступны только при указании ИБ и процесса
//
Процедура ДополнитьДанные() Экспорт
	
	Если НЕ (ЗначениеЗаполнено(Процесс_Владелец) И ЗначениеЗаполнено(ИБ_Владелец))
	 ИЛИ ИБ_Владелец.ОшибкаАвторизации() Тогда
		Возврат;
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторПроцесса"       , Процесс_Владелец.Ид());
	ПараметрыКоманды.Вставить("ИдентификаторИБ"             , ИБ_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииИБ"      , ИБ_Владелец.ПараметрыАвторизации());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Список");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);
		Если Найти(ВыводКоманды, "Недостаточно прав пользователя") = 0
		   И Найти(ВыводКоманды, "Превышено допустимое количество ошибок при вводе имени и пароля") = 0 Тогда
			ВызватьИсключение ВыводКоманды;
		Иначе
			Лог.Предупреждение("Ошибка получения полного описания соединения ""%1"" ИБ ""%2"" в кластере ""%3"",
			                   | КодВозврата = %4:%5%6",
			                   Ид(),
			                   ИБ_Владелец.Имя(),
			                   Кластер_Владелец.Имя(),
			                   КодВозврата,
			                   Символы.ПС,
			                   ВыводКоманды);
			ИБ_Владелец.УстановитьОшибкуАвторизации(Истина);
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Для Каждого ТекОписание Из МассивРезультатов Цикл
		Если ТекОписание["connection"] = Соединение_Ид Тогда
			ЗаполнитьСвойстваОбъекта(ТекОписание, Истина);
		Иначе
			СоединениеДляОбновления =
				Кластер_Владелец.Соединения().Получить(ТекОписание["connection"],
				                                       Перечисления.РежимыОбновленияДанных.НеОбновлять);
			Если НЕ (СоединениеДляОбновления = Неопределено ИЛИ СоединениеДляОбновления.ПолноеОписание()) Тогда
				СоединениеДляОбновления.ЗаполнитьСвойстваОбъекта(ТекОписание, Истина);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры // ДополнитьДанные()

Процедура ЗаполнитьСвойстваОбъекта(ОписаниеОбъекта, ПолноеОписание = Ложь) Экспорт
	Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Соединение_Свойства, ОписаниеОбъекта, Истина);
	Соединение_ПолноеОписание = ПолноеОписание;
КонецПроцедуры // ЗаполнитьСвойстваОбъекта()

// Функция признак необходимости обновления данных
//   
// Параметры:
//   РежимОбновления          - Число        - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//                                             2 - обновить только основную информацию (вызов RAC)
//
// Возвращаемое значение:
//    Булево - Истина - требуется обновитьданные
//
Функция ТребуетсяОбновление(РежимОбновления = 0) Экспорт

	Если НЕ Кластер_Владелец.Соединения().ТребуетсяОбновление(РежимОбновления) Тогда
		Возврат Ложь;
	КонецЕсли;

	Возврат Служебный.ТребуетсяОбновление(Соединение_Свойства, МоментАктуальности,
	                                      ПериодОбновления, РежимОбновления);

КонецФункции // ТребуетсяОбновление()

// Функция возвращает описание параметров объекта
//   
// Возвращаемое значение:
//    КомандыОбъекта - описание параметров объекта,
//
Функция ПараметрыОбъекта() Экспорт

	Возврат ПараметрыОбъекта;

КонецФункции // ПараметрыОбъекта()

// Функция возвращает признак доступности полного описания соединения 1С
//   
// Возвращаемое значение:
//    Булево - Истина - доступно полное описание; Ложь - доступно сокращенное описание
//
Функция ПолноеОписание() Экспорт

	Возврат (Соединение_ПолноеОписание = Истина);
	
КонецФункции // ПолноеОписание()

// Функция возвращает значение параметра соединения 1С
//   
// Параметры:
//   ИмяПоля                 - Строка        - Имя параметра соединения
//   РежимОбновления         - Число         - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//                                             2 - обновить только основную информацию (вызов RAC)
//
// Возвращаемое значение:
//     Произвольный - значение параметра соединения 1С
//
Функция Получить(ИмяПоля, РежимОбновления = 0) Экспорт
	
	ОбновитьДанные(РежимОбновления);

	Если НЕ Найти("ИД, CONNECTION", ВРег(ИмяПоля)) = 0 Тогда
		Возврат Соединение_Ид;
	КонецЕсли;
	
	ЗначениеПоля = Соединение_Свойства.Получить(ИмяПоля);

	Если ЗначениеПоля = Неопределено Тогда
	    
		ОписаниеПараметра = ПараметрыОбъекта.ОписаниеСвойств("ИмяРАК").Получить(ИмяПоля);

		Если НЕ ОписаниеПараметра = Неопределено Тогда
			ЗначениеПоля = Соединение_Свойства.Получить(ОписаниеПараметра["Имя"]);
		КонецЕсли;
	КонецЕсли;

	Возврат ЗначениеПоля;

КонецФункции // Получить()

// Процедура отключает соединение в кластере 1С
//   
Процедура Отключить() Экспорт

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());

	ПараметрыКоманды.Вставить("ИдентификаторПроцесса"  , Процесс_Владелец.Ид());
	ПараметрыКоманды.Вставить("ИдентификаторСоединения", Ид());

	ОтборИБ = Новый Соответствие();
	ОтборИБ.Вставить("infobase", Получить("infobase"));

	СписокИБ = Кластер_Владелец.ИнформационныеБазы().Список(ОтборИБ);
	Если ЗначениеЗаполнено(СписокИБ) Тогда
		ПараметрыКоманды.Вставить("ПараметрыАвторизацииИБ", СписокИБ[0].ПараметрыАвторизации());
	КонецЕсли;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Отключить");
	ВыводКоманды = Кластер_Агент.ВыводКоманды(Ложь);

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка удаления соединения ""%1"" кластера ""%2"", КодВозврата = %3:%4%5",
		                        Ид(),
		                        Кластер_Владелец.Имя(),
		                        КодВозврата,
		                        Символы.ПС,
		                        ВыводКоманды);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	Лог.Отладка(ВыводКоманды);

	Кластер_Владелец.Соединения().ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);

КонецПроцедуры // Отключить()
