// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Кластер_Агент;
Перем ПараметрыОбъекта;
Перем Элементы;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера         - АгентКластера    - ссылка на родительский объект агента кластера
//
Процедура ПриСозданииОбъекта(АгентКластера)

	Лог = Служебный.Лог();

	Кластер_Агент = АгентКластера;
	
	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент, Перечисления.РежимыАдминистрирования.АдминистраторыАгента);

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает список администраторов агента кластера 1С от утилиты администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно         - Булево    - Истина - принудительно обновить данные (вызов RAC)
//                                             - Ложь - данные будут получены если истекло время актуальности
//                                                    или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт

	Если НЕ Элементы.ТребуетсяОбновление(ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента", Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииАгента", Кластер_Агент.ПараметрыАвторизации());
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Список");

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения списка администраторов агента, КодВозврата = %1: %2",
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;

	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	МассивАдминистраторов = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		Администратор = Новый ОбъектКластера(Кластер_Агент,
		                                     Кластер_Агент,
		                                     Перечисления.РежимыАдминистрирования.АдминистраторыАгента,
		                                     ТекОписание);
		МассивАдминистраторов.Добавить(Администратор);
	КонецЦикла;

	Элементы.Заполнить(МассивАдминистраторов);

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

// Функция возвращает список администраторов агента кластера
//   
// Параметры:
//   Отбор                     - Структура    - Структура отбора администраторов (<поле>:<значение>)
//   ОбновитьПринудительно     - Булево       - Истина - принудительно обновить данные (вызов RAC)
//   ЭлементыКакСоответствия   - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                               Строка         с именами свойств в качестве ключей
//                                              <Имя поля> - элементы результата будут преобразованы в соответствия
//                                              со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                              Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Массив - список администраторов агента кластера 1С
//
Функция Список(Отбор = Неопределено, ОбновитьПринудительно = Ложь, ЭлементыКакСоответствия = Ложь) Экспорт

	Возврат Элементы.Список(Отбор, ОбновитьПринудительно, ЭлементыКакСоответствия);

КонецФункции // Список()

// Функция возвращает список администраторов агента кластеров 1С
//   
// Параметры:
//   ПоляИерархии              - Строка       - Поля для построения иерархии списка администраторов, разделенные ","
//   ОбновитьПринудительно     - Булево       - Истина - принудительно обновить данные (вызов RAC)
//   ЭлементыКакСоответствия   - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                               Строка         с именами свойств в качестве ключей
//                                              <Имя поля> - элементы результата будут преобразованы в соответствия
//                                              со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                              Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Соответствие - список администраторов агента кластеров 1С
//        <имя поля объекта>    - Массив(Соответствие), Соответствие    - список администраторов или следующий уровень
//
Функция ИерархическийСписок(Знач ПоляИерархии, ОбновитьПринудительно = Ложь, ЭлементыКакСоответствия = Ложь) Экспорт

	Возврат Элементы.ИерархическийСписок(ПоляИерархии, ОбновитьПринудительно, ЭлементыКакСоответствия);

КонецФункции // ИерархическийСписок()

// Функция возвращает количество администраторов агента в списке
//   
// Возвращаемое значение:
//    Число - количество администраторов агента
//
Функция Количество() Экспорт

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Функция возвращает описание администратора агента кластеров 1С
//   
// Параметры:
//   Имя                      - Строка    - Имя администраторов агента
//   ОбновитьПринудительно    - Булево    - Истина - принудительно обновить данные (вызов RAC)
//   КакСоответствие          - Булево    - Истина - результат будет преобразован в соответствие
//
// Возвращаемое значение:
//    Соответствие - описание администратора агента кластеров 1С
//
Функция Получить(Знач Имя, Знач ОбновитьПринудительно = Ложь, КакСоответствие = Ложь) Экспорт

	Отбор = Новый Соответствие();
	Отбор.Вставить("name", Имя);

	АдминистраторыАгента = Элементы.Список(Отбор, ОбновитьПринудительно, КакСоответствие);
	
	Если НЕ ЗначениеЗаполнено(АдминистраторыАгента) Тогда
		Возврат Неопределено;
	КонецЕсли;

	Возврат АдминистраторыАгента[0];

КонецФункции // Получить()

// Процедура добавляет нового администратора агента кластеров
//   
// Параметры:
//    Имя                         - Строка        - имя администратора агента кластеров 1С
//    ПараметрыАдминАгента        - Структура        - параметры создаваемого администратора
//        - Пароль                    - Строка        - пароль администратора агента кластеров 1С
//        - Описание                  - Строка        - описание администратора агента кластеров 1С
//        - СпособАвторизации         - Строка        - Пароль / пользователь ОС
//        - ПользовательОС            - Строка    - пользователь ОС, соответствующий администратору
//    УстановитьТекущим           - Булево        - Истина - сделать добавленного администратора
//                                                  текущим для агента кластеров
//
Процедура Добавить(Знач Имя, Знач ПараметрыАдминАгента = Неопределено, УстановитьТекущим = Ложь) Экспорт

	Если НЕ ТипЗнч(ПараметрыАдминАгента) = Тип("Структура") Тогда
		ПараметрыАдминАгента = Новый Структура();
	КонецЕсли;

	ТекущееКоличество = Количество();

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента", Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииАгента", Кластер_Агент.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("Имя"                    , Имя);

	Для Каждого ТекЭлемент Из ПараметрыАдминАгента Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Добавить");

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка добавления администратора агента ""%1"", КодВозврата = %2: %3",
	                                Имя,
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;

	Если НЕ ПараметрыАдминАгента.Свойство("Пароль") Тогда
		ПараметрыАдминАгента.Вставить("Пароль", "");
	КонецЕсли;
	
	Если УстановитьТекущим ИЛИ ТекущееКоличество = 0 Тогда
		Кластер_Агент.УстановитьАдминистратора(Имя, ПараметрыАдминАгента.Пароль);
	КонецЕсли;

	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);

КонецПроцедуры // Добавить()

// Процедура удаляет администратора агента кластеров
//   
// Параметры:
//   Имя                 - Строка        - имя администратора агента кластеров 1С
//
Процедура Удалить(Имя) Экспорт

	ТекущееКоличество = Количество();

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"   , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииАгента", Кластер_Агент.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("Имя"                    , Имя);

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Удалить");

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка удаления администратора агента ""%1"", КодВозврата = %2: %3",
	                                Имя,
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	Если ТекущееКоличество = 1 Тогда
		Кластер_Агент.УстановитьАдминистратора("", "");
	КонецЕсли;

	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);

КонецПроцедуры // Удалить()

