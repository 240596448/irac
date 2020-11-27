// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем ТипЭлементов;
Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем Профиль_Владелец;
Перем Элементы;

Перем ПараметрыОбъекта;

Перем МоментАктуальности;
Перем ПериодОбновления;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера      - АгентКластера             - ссылка на родительский объект агента кластера
//   Кластер            - Кластер                   - ссылка на родительский объект кластера
//   Профиль            - ПрофильБезопасности       - ссылка на родительский объект кластера
//   Тип                - Перечисления.             - имя типа объекта профиля
//                        ВидыОбъектовПрофиляБезопасности
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Профиль, Тип)

	Лог = Служебный.Лог();

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	Профиль_Владелец = Профиль;

	ТипЭлементов = Тип;

	ТипОбъектаПрофиля = СтрШаблон("%1.%2",
	                              Перечисления.РежимыАдминистрирования.ПрофилиБезопасности,
	                              ТипЭлементов);
	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент, ТипОбъектаПрофиля);

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает список объектов профиля безопасности от утилиты администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно         - Булево    - Истина - принудительно обновить данные (вызов RAC)
//                                            - Ложь - данные будут получены если истекло время актуальности
//                                                    или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт

	Если НЕ Элементы.ТребуетсяОбновление(ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИмяПрофиля"                  , Профиль_Владелец.Имя());
	ПараметрыКоманды.Вставить("ВидОбъектовПрофиля"          , ТипЭлементов);

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Список");

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения списка доступа объектов ""%1"" профиля ""%2"": %3",
		                            ТипЭлементов,
		                            Профиль_Владелец.Имя(),
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;

	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	МассивОбъектов = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		ТипОбъектаПрофиля = СтрШаблон("%1.%2",
		                              Перечисления.РежимыАдминистрирования.ПрофилиБезопасности,
		                              ТипЭлементов);
		МассивОбъектов.Добавить(Новый ОбъектКластера(Кластер_Агент, Кластер_Владелец, ТипОбъектаПрофиля, ТекОписание));
	КонецЦикла;

	Элементы.Заполнить(МассивОбъектов);

	Элементы.УстановитьАктуальность();

КонецПроцедуры // ОбновитьДанные()

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

// Функция возвращает список объектов кластера
//
// Параметры:
//   Отбор                    - Структура    - Структура отбора объектов (<поле>:<значение>)
//   ОбновитьПринудительно    - Булево       - Истина - принудительно обновить данные (вызов RAC)
//   ЭлементыКакСоответствия  - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                              Строка         с именами свойств в качестве ключей
//                                             <Имя поля> - элементы результата будут преобразованы в соответствия
//                                             со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                             Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Массив - список объектов кластера 1С
//
Функция Список(Отбор = Неопределено, ОбновитьПринудительно = Ложь, ЭлементыКакСоответствия = Ложь) Экспорт

	Возврат Элементы.Список(Отбор, ОбновитьПринудительно, ЭлементыКакСоответствия);

КонецФункции // Список()

// Функция возвращает список объектов кластера
//
// Параметры:
//   ПоляИерархии             - Строка       - Поля для построения иерархии списка объектов, разделенные ","
//   ОбновитьПринудительно    - Булево       - Истина - принудительно обновить данные (вызов RAC)
//   ЭлементыКакСоответствия  - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                              Строка         с именами свойств в качестве ключей
//                                             <Имя поля> - элементы результата будут преобразованы в соответствия
//                                             со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                             Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Соответствие - список объектов кластера 1С
//        <имя поля объекта>    - Массив(Соответствие), Соответствие    - список объектов кластера или следующий уровень
//
Функция ИерархическийСписок(Знач ПоляИерархии, ОбновитьПринудительно = Ложь, ЭлементыКакСоответствия = Ложь) Экспорт

	Возврат Элементы.ИерархическийСписок(ПоляИерархии, ОбновитьПринудительно, ЭлементыКакСоответствия);

КонецФункции // ИерархическийСписок()

// Функция возвращает количество обектов в списке профиля безопасности
//   
// Возвращаемое значение:
//    Число - количество объектов
//
Функция Количество() Экспорт

	ОбновитьДанные();

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Процедура устанавливает значение периода обновления
//   
// Параметры:
//   НовыйПериодОбновления     - Число        - новый период обновления
//
Процедура УстановитьПериодОбновления(НовыйПериодОбновления) Экспорт

	ПериодОбновления = НовыйПериодОбновления;

КонецПроцедуры // УстановитьПериодОбновления()

// Процедура устанавливает новое значение момента актуальности данных
//   
Процедура УстановитьАктуальность() Экспорт

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

КонецПроцедуры // УстановитьАктуальность()

// Процедура добавляет новый или изменяет существующий объект профиля безопасности
//   
// Параметры:
//   Имя                      - Строка     - имя объекта профиля безопасности 1С
//   ПараметрыОбъектаПрофиля  - Структура  - параметры объекта профиля безопасности 1С
//
Процедура Изменить(Имя, ПараметрыОбъектаПрофиля = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыОбъектаПрофиля) = Тип("Структура") Тогда
		ПараметрыОбъектаПрофиля = Новый Структура();
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИмяПрофиля"                  , Профиль_Владелец.Имя());
	ПараметрыКоманды.Вставить("ВидОбъектовПрофиля"          , ТипЭлементов);
	ПараметрыКоманды.Вставить("ИмяОбъектаПрофиля"           , Имя);

	Для Каждого ТекЭлемент Из ПараметрыОбъектаПрофиля Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Изменить");

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка изменения объекта доступа ""%1"" (%2) профиля ""%3"": %4",
		                            Имя,
		                            ТипЭлементов,
		                            Профиль_Владелец.Имя(),
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;

	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);

КонецПроцедуры // Изменить()

// Процедура удаляет объект профиля из профиля безопасности
//   
// Параметры:
//   Имя            - Строка    - Имя объекта профиля безопасности
//
Процедура Удалить(Имя) Экспорт
	
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИмяПрофиля"                  , Профиль_Владелец.Имя());
	ПараметрыКоманды.Вставить("ВидОбъектовПрофиля"          , ТипЭлементов);
	ПараметрыКоманды.Вставить("ИмяОбъектаПрофиля"           , Имя);

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Удалить");

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка удаления объекта доступа ""%1"" (%2) профиля ""%3"": %4",
		                            Имя,
		                            ТипЭлементов,
		                            Профиль_Владелец.Имя(),
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;

	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);

КонецПроцедуры // Удалить()
