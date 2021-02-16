// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

#Использовать logos
#Использовать tempfiles
#Использовать asserts
#Использовать strings
#Использовать 1commands
#Использовать v8runner
#Использовать 1connector
#Использовать "../Макеты"

Перем Лог;

// Функция - читает указанный макет JSON и возвращает содержимое в виде структуры/массива
//
// Параметры:
//	ИмяМакета    - Строка   - имя макета (файла) json
//
// Возвращаемое значение:
//	Структура, Массив       - прочитанные данные из макета 
//
Функция ПрочитатьДанныеИзМакетаJSON(ИмяМакета) Экспорт

	Чтение = Новый ЧтениеJSON();

	ПутьКМакету = ПолучитьМакет(СтрШаблон("/Макеты/%1", ИмяМакета));
	
	Чтение.ОткрытьФайл(ПутьКМакету, КодировкаТекста.UTF8);
	
	Возврат ПрочитатьJSON(Чтение, Ложь);

КонецФункции // ПрочитатьДанныеИзМакетаJSON()

// Функция добавляет кавычки в начале и в конце переданной строки
//   
// Параметры:
//   Строка         - Строка        - Строка для добавления кавычек
//
// Возвращаемое значение:
//    Строка - строка с добавленными кавычками
//
Функция ОбернутьВКавычки(Знач Строка) Экспорт
	Если Лев(Строка, 1) = """" И Прав(Строка, 1) = """" Тогда
		Возврат Строка;
	Иначе
		Возврат """" + Строка + """";
	КонецЕсли;
КонецФункции // ОбернутьВКавычки()

// Функция проверяет, что переданное значение является числом или строковым представлением числа
//   
// Параметры:
//   Параметр      - Строка, Число     - значение для проверки
//
// Возвращаемое значение:
//    Булево       - Истина - значение является числом или строковым представлением числа
//
Функция ЭтоЧисло(Параметр) Экспорт

	Если ТипЗнч(Параметр) = Тип("Число") Тогда
		Возврат Истина;
	КонецЕсли;

	Попытка
		ПараметрЧислом = Число(Параметр); //@skip-warning
	Исключение
		Возврат Ложь;
	КонецПопытки;

	Возврат Истина;

КонецФункции // ЭтоЧисло()

// Функция проверяет, что переданное значение является числом или строковым представлением числа
//   
// Параметры:
//   Параметр      - Строка, Число     - значение для проверки
//
// Возвращаемое значение:
//    Булево       - Истина - значение является числом или строковым представлением числа
//
Функция ЭтоGUID(Параметр) Экспорт

	РВ = Новый РегулярноеВыражение("(?i)[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}");
	
	Возврат РВ.Совпадает(Параметр);

КонецФункции // ЭтоGUID()

// Функция - возвращает Истина если значение является пустым GUID
//
// Параметры:
//    Значение      - Строка     - проверяемое значение
//
// Возвращаемое значение:
//    Булево     - Истина - значение является пустым GUID
//
Функция ЭтоПустойGUID(Значение) Экспорт

	Возврат (Значение = "00000000-0000-0000-0000-000000000000") ИЛИ НЕ ЗначениеЗаполнено(Значение);

КонецФункции // ЭтоПустойGUID()

// Функция возвращает период обновления данных для указанного типа объектов
//
// Параметры:
//   Объект       - ОбъектКластера     - объект кластера 1С
//
// Возвращаемое значение:
//    Число       - период обновления данных объекта в миллисекундах
//
Функция ПериодОбновленияДанныхОбъекта(Объект) Экспорт

	ПериодОбновления = 60000;

	ТипОбъекта = Объект.ПараметрыОбъекта().ТипОбъекта();

	Если ТипЗнч(ТипОбъекта) = Тип("Структура") И ТипОбъекта.Свойство("ПериодОбновления") Тогда
		ПериодОбновления = ТипОбъекта.ПериодОбновления;
	КонецЕсли;

	Возврат ПериодОбновления;

КонецФункции // ПериодОбновленияДанныхОбъекта()

// Процедура заполняет значения свойств объекта кластера 1С
//   
// Параметры:
//   ОбъектКластера          - Произвольный        - объект, свойства которого будут заполнены
//   Свойства                - Соответствие        - переменная, которая будет заполнена свойствами объекта
//   ДанныеЗаполнения        - Соответствие        - данные, из которых будут заполнены значения свойств объекта
//   
Процедура ЗаполнитьСвойстваОбъекта(ОбъектКластера, Свойства, ДанныеЗаполнения) Экспорт

	СтруктураПараметров = ОбъектКластера.ПараметрыОбъекта().ОписаниеСвойств();

	Если ТипЗнч(Свойства) = Тип("Соответствие") Тогда
		Свойства.Очистить();
	КонецЕсли;
	
	Если НЕ ТипЗнч(Свойства) = Тип("Соответствие") Тогда
		Свойства = Новый Соответствие();
	КонецЕсли;

	Для Каждого ТекЭлемент Из СтруктураПараметров Цикл

		ЗначениеПараметра = ПолучитьЗначениеИзСтруктуры(ДанныеЗаполнения,
	                                                    ТекЭлемент.Значение.ИмяРАК,
	                                                    ТекЭлемент.Значение.ПоУмолчанию);
		
		Если ТекЭлемент.Значение.Тип = Тип("Дата") И ТипЗнч(ЗначениеПараметра) = Тип("Строка") Тогда
			Если ЗначениеЗаполнено(ЗначениеПараметра) Тогда
				ЗначениеПараметра = ПрочитатьДатуJSON(ЗначениеПараметра, ФорматДатыJSON.ISO);
			Иначе
				ЗначениеПараметра = Дата(1, 1, 1, 0, 0, 0);
			КонецЕсли;
		ИначеЕсли ТекЭлемент.Значение.Тип = Тип("Число") И ТипЗнч(ЗначениеПараметра) = Тип("Строка") Тогда
			Если ЗначениеЗаполнено(ЗначениеПараметра) И ЭтоЧисло(ЗначениеПараметра) Тогда
				ЗначениеПараметра = Число(ЗначениеПараметра);
			ИначеЕсли НЕ ЗначениеЗаполнено(ЗначениеПараметра) Тогда
				ЗначениеПараметра = 0;
			КонецЕсли;
		КонецЕсли;

		Свойства.Вставить(ТекЭлемент.Ключ, ЗначениеПараметра);

	КонецЦикла;

КонецПроцедуры // ЗаполнитьСвойстваОбъекта()

// Функция возвращает значение указанного поля структуры/соответствия или значение по умолчанию
//   
// Параметры:
//   ПарамСтруктура      - Структура, Соответствие    - коллекция из которой возвращается значение
//   Ключ                - Произвольный               - значение ключа коллекции для получения значения
//   ПоУмолчанию         - Произвольный               - значение, возвращаемое в случае,
//                                                      когда ключ отсутствует в коллекции
//   
// Возвращаемое значение:
//    Произвольный - значение элемента коллекции или значение по умолчанию
//
Функция ПолучитьЗначениеИзСтруктуры(ПарамСтруктура, Ключ, ПоУмолчанию = Неопределено) Экспорт

	Если ТипЗнч(ПарамСтруктура) = Тип("Структура") Тогда
		Если ПарамСтруктура.Свойство(Ключ) Тогда
			Возврат ПарамСтруктура[Ключ];
		КонецЕсли;
	ИначеЕсли ТипЗнч(ПарамСтруктура) = Тип("Соответствие") Тогда
		Если НЕ ПарамСтруктура.Получить(Ключ) = Неопределено Тогда
			Возврат ПарамСтруктура.Получить(Ключ);
		КонецЕсли;
	Иначе
		Возврат ПоУмолчанию;
	КонецЕсли;

КонецФункции // ПолучитьЗначениеИзСтруктуры()

// Функция преобразует массив соответствий в иерархию соответствий в соответствии с указанным порядком полей
// копирования данных не происходят, в результирующее соответствие помещаются исходные элементы массива
//   
// Параметры:
//   МассивСоответствий      - Массив(Соответствие)   - Данные для преобразования
//            <имя поля>         - Произвольный           - Значение элемента соответствия
//   ПоляИерархии            - Строка, Массив         - имена полей для построения иерархии списка объектов,
//                                                      разделенные "," или массив имен полей
//
// Возвращаемое значение:
//    Соответствие - иерархия соответствий по значениям полей упорядочивания
//        <значение поля упорядочивания>   - Соответствие,         - подчиненные данные по значениям
//                                           Массив(Соответствие)    следующего поля упорядочивания
//                                                                   или элементы исходного массива
//                                                                   на последнем уровне иерархии
//
Функция ИерархическоеПредставлениеМассиваСоответствий(МассивСоответствий, ПоляИерархии) Экспорт

	МассивУпорядочивания = ПоляИерархии;

	Если ТипЗнч(ПоляИерархии) = Тип("Строка") Тогда
		МассивУпорядочивания = СтрРазделить(ПоляИерархии, ",", Ложь);
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(МассивУпорядочивания) Тогда
		Возврат МассивСоответствий;
	КонецЕсли;

	Результат = Новый Соответствие();

	Для Каждого ТекЭлемент Из МассивСоответствий Цикл
		ЗаполняемыйСписок = Результат;
		ТекСписок = Неопределено;
		Для Каждого ИмяПоля Из МассивУпорядочивания Цикл
			Если ТипЗнч(ТекСписок) = Тип("Соответствие") Тогда
				ЗаполняемыйСписок = ТекСписок;
			КонецЕсли;
			ЗначениеПоля = ТекЭлемент.Получить(ИмяПоля);
			ТекСписок = ЗаполняемыйСписок.Получить(ЗначениеПоля);
			Если ТекСписок = Неопределено Тогда
				ЗаполняемыйСписок.Вставить(ЗначениеПоля, Новый Соответствие());
				ТекСписок = ЗаполняемыйСписок[ЗначениеПоля];
			КонецЕсли;
		КонецЦикла;
		Если НЕ ТипЗнч(ЗаполняемыйСписок[ЗначениеПоля]) = Тип("Массив") Тогда
			ЗаполняемыйСписок[ЗначениеПоля] = Новый Массив();
		КонецЕсли;
		ЗаполняемыйСписок[ЗначениеПоля].Добавить(ТекЭлемент);
	КонецЦикла;

	Возврат Результат;

КонецФункции // ИерархическоеПредставлениеМассиваСоответствий()

// Функция возвращает массив элементов (соответствий), отвечающих заданному отбору
//   
// Параметры:
//   МассивСоответствий        - Массив(Соответствие)        - Обрабатываемый массив
//   Отбор                     - Соответствие                - Структура отбора вида <поле>:<значение>
//
// Возвращаемое значение:
//    Массив(Соответствие) - массив соответствий, соответствующих отбору
//
Функция ПолучитьЭлементыИзМассиваСоответствий(МассивСоответствий, Отбор) Экспорт

	Если НЕ ТипЗнч(Отбор) = Тип("Соответствие") Тогда
		Возврат МассивСоответствий;
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(Отбор) Тогда
		Возврат МассивСоответствий;
	КонецЕсли;

	Результат = Новый Массив();

	Для й = 0 По МассивСоответствий.ВГраница() Цикл
		
		ТекЭлемент = МассивСоответствий[й];
		
		ЭлементСоответствуетОтбору = Истина;

		Для Каждого ТекЭлементОтбора Из Отбор Цикл
			Если ТипЗнч(ТекЭлемент) = Тип("Соответствие") Тогда
				ПроверяемоеЗначение = ТекЭлемент.Получить(ТекЭлементОтбора.Ключ);
			Иначе
				ПроверяемоеЗначение = ТекЭлемент.Получить(ТекЭлементОтбора.Ключ,
				                                          Перечисления.РежимыОбновленияДанных.НеОбновлять);
			КонецЕсли;
			Если НЕ ПроверяемоеЗначение = ТекЭлементОтбора.Значение Тогда
				ЭлементСоответствуетОтбору = Ложь;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		Если НЕ ЭлементСоответствуетОтбору Тогда
			Продолжить;
		КонецЕсли;
		
		Результат.Добавить(ТекЭлемент);

	КонецЦикла;

	Возврат Результат;

КонецФункции // ПолучитьЭлементыИзМассиваСоответствий()

// Функция преобразует все элементы-объекты массива в соответствия с аналогичным набором полей
//   
// Параметры:
//   МассивЭлементов     - Массив(Произвольный)     - Обрабатываемый массив
//   ПоляЭлемента        - Соответствие             - Описания полей элементов
//
// Возвращаемое значение:
//    Массив(Соответствие) - массив элементов-соответствий
//
Функция МассивОбъектовВМассивСоответствий(МассивЭлементов, ПоляЭлемента) Экспорт

	Если НЕ ТипЗнч(МассивЭлементов) = Тип("Массив") Тогда
		Возврат МассивЭлементов;
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(МассивЭлементов) Тогда
		Возврат МассивЭлементов;
	КонецЕсли;

	Если ТипЗнч(МассивЭлементов[0]) = Тип("Соответствие") Тогда
		Возврат МассивЭлементов;
	КонецЕсли;

	Результат = Новый Массив();

	Для й = 0 По МассивЭлементов.ВГраница() Цикл
		ЭлементДляДобавления = ОбъектВСоответствие(МассивЭлементов[й], ПоляЭлемента);
		Результат.Добавить(ЭлементДляДобавления);
	КонецЦикла;

	Возврат Результат;

КонецФункции // МассивОбъектовВМассивСоответствий()

// Функция преобразует все объект кластера в соответствия с аналогичным набором полей
//   
// Параметры:
//   Объект           - Произвольный     - Обрабатываемый объект
//   ПоляОбъекта      - Соответствие     - Описания полей объекта
//
// Возвращаемое значение:
//    Соответствие - объект для преобразования
//
Функция ОбъектВСоответствие(Объект, ПоляОбъекта) Экспорт

	Если ТипЗнч(Объект) = Тип("Соответствие") Тогда
		Возврат Объект;
	КонецЕсли;

	Результат = Новый Соответствие();

	Для Каждого ТекПоле Из ПоляОбъекта Цикл
		Результат.Вставить(ТекПоле.Ключ,
		                   Объект.Получить(ТекПоле.Ключ, Перечисления.РежимыОбновленияДанных.НеОбновлять));
	КонецЦикла;

	Возврат Результат;

КонецФункции // ОбъектВСоответствие()

// Функция возвращает строку параметров запуска команды с заменой значений "приватных" параметров
// на символы подстановки и соответствие параметров подстановки и значений
// 
// Параметры:
//   ПараметрыКоманды   - Массив         - параметры запуска команды
//   Подстановки        - Соответствие   - (Возвр.) соответствие символов подстановки и значений
// 
// Возвращаемое значение:
//    Строка - строка параметров запуска команды
//
Функция ПараметрыКомандыВСтрокуСПодстановками(ПараметрыКоманды, Подстановки = Неопределено) Экспорт

	СтрокаПараметров = "";
	
	Если НЕ ТипЗнч(Подстановки) = Тип("Соответствие") Тогда
		Подстановки = Новый Соответствие();
	КонецЕсли;

	Для Каждого Параметр Из ПараметрыКоманды Цикл
		Если ТипЗнч(Параметр) = Тип("Структура") Тогда
			Если Параметр.Свойство("Приватный") И Параметр.Приватный Тогда
				Подстановка = ПолучитьИмяПодстановки();
				ПараметрДляВыполнения = СтрШаблон("--%1=${%2}", Параметр.Параметр, Подстановка);
				Подстановки.Вставить(СтрШаблон("${%1}", Подстановка), Параметр.Значение);
			ИначеЕсли Параметр.Свойство("Флаг") И Параметр.Флаг Тогда
				ПараметрДляВыполнения = СтрШаблон("--%1", Параметр.Параметр);
			Иначе
				ПараметрДляВыполнения = СтрШаблон("--%1=%2", Параметр.Параметр, Параметр.Значение);
			КонецЕсли;
		Иначе
			ПараметрДляВыполнения = Параметр;
		КонецЕсли;
		СтрокаПараметров = СтрШаблон("%1 %2", СтрокаПараметров, ПараметрДляВыполнения);
	КонецЦикла;

	Возврат СтрокаПараметров;

КонецФункции // ПараметрыКомандыВСтрокуСПодстановками()

// Функция возвращает строку параметров запуска команды
// 
// Параметры:
//   ПараметрыКоманды   - Массив         - параметры запуска команды
//   ДляЛога            - Булево         - Истина - приватные значения параметров (пользватель / пароль и т.п.)
//                                         будут скрыты символами "******"
// 
// Возвращаемое значение:
//    Строка - строка параметров запуска команды
//
Функция ПараметрыКомандыВСтроку(ПараметрыКоманды, ДляЛога = Ложь) Экспорт

	Подстановки = Новый Соответствие();
	
	СтрокаПараметров = ПараметрыКомандыВСтрокуСПодстановками(ПараметрыКоманды, Подстановки);

	ПодставитьЗначенияПараметров(СтрокаПараметров, Подстановки, ?(ДляЛога, "******", Неопределено));

	Возврат СтрокаПараметров;

КонецФункции // ПараметрыКомандыВСтроку()

// Процедура выполняет замену символов подстановки на значения
// 
// Параметры:
//   СтрокаПараметров      - Строка         - строка для обработки
//   Подстановки           - Соответствие   - соответствие символов подстановки и значений
//   ЗначениеПодстановки   - Строка         - если указано, то подставляется вместо всех символов подстановки
// 
Процедура ПодставитьЗначенияПараметров(СтрокаПараметров, Подстановки, Знач ЗначениеПодстановки = Неопределено)

	Если НЕ ТипЗнч(Подстановки) = Тип("Соответствие") Тогда
		Возврат;
	КонецЕсли;

	Для Каждого ТекЭлемент Из Подстановки Цикл
		Значение = ТекЭлемент.Значение;
		Если НЕ ЗначениеПодстановки = Неопределено Тогда
			Значение = ЗначениеПодстановки;
		КонецЕсли;
		СтрокаПараметров = СтрЗаменить(СтрокаПараметров, ТекЭлемент.Ключ, Значение);
	КонецЦикла;

КонецПроцедуры // ПодставитьЗначенияПараметров()

// Функция возвращает случайное имя переменной для выполнения подстановки
// 
// Возвращаемое значение:
//   Строка      - случайное имя переменной
// 
Функция ПолучитьИмяПодстановки() Экспорт

	ВремИмя = ПолучитьИмяВременногоФайла("sub"); //@skip-warning
	ВремФайл = Новый Файл(ВремИмя);
	
	Возврат ВремФайл.ИмяБезРасширения;

КонецФункции // ПолучитьИмяПодстановки()

// Функция преобразует переданный текст вывода команды в массив соответствий
// элементы массива создаются по блокам текста, разделенным пустой строкой
// пары <ключ, значение> структуры получаются для каждой строки с учетом разделителя ":"
//   
// Параметры:
//   ВыводКоманды            - Строка            - текст для разбора
//   
// Возвращаемое значение:
//    Массив (Соответствие) - результат разбора
//
Функция РазобратьВыводКоманды(Знач ВыводКоманды) Экспорт
	
	Текст = Новый ТекстовыйДокумент();
	Текст.УстановитьТекст(ВыводКоманды);

	МассивРезультатов = Новый Массив();
	Описание = Новый Соответствие();

	Для й = 1 По Текст.КоличествоСтрок() Цикл

		ТекстСтроки = Текст.ПолучитьСтроку(й);
		
		ПозРазделителя = СтрНайти(ТекстСтроки, ":");
		
		Если НЕ ЗначениеЗаполнено(ТекстСтроки) Тогда
			Если й = 1 Тогда
				Продолжить;
			КонецЕсли;
			МассивРезультатов.Добавить(Описание);
			Описание = Новый Соответствие();
			Продолжить;
		КонецЕсли;

		Если ПозРазделителя = 0 Тогда
			Описание.Вставить(СокрЛП(ТекстСтроки), "");
		Иначе
			Описание.Вставить(СокрЛП(Лев(ТекстСтроки, ПозРазделителя - 1)), СокрЛП(Сред(ТекстСтроки, ПозРазделителя + 1)));
		КонецЕсли;
		
	КонецЦикла;

	Если ЗначениеЗаполнено(Описание) Тогда
		МассивРезультатов.Добавить(Описание);
	КонецЕсли;
	
	Если МассивРезультатов.Количество() = 1 И ТипЗнч(МассивРезультатов[0]) = Тип("Строка") Тогда
		Возврат МассивРезультатов[0];
	КонецЕсли;

	Возврат МассивРезультатов;

КонецФункции // РазобратьВыводКоманды()

// Функция признак необходимости обновления данных
//   
// Параметры:
//   ОбъектДанных             - Произвольный  - данные для обновления
//   МоментАктуальности       - Число         - момент актуальности данных (мсек)
//   ПериодОбновления         - Число         - периодичность обновления (мсек)
//   РежимОбновления          - Число         - 1 - обновить данные принудительно (вызов RAC)
//                                              0 - обновить данные только по таймеру
//                                             -1 - не обновлять данные
//
// Возвращаемое значение:
//    Булево - Истина - требуется обновитьданные
//
Функция ТребуетсяОбновление(ОбъектДанных, МоментАктуальности, ПериодОбновления, РежимОбновления = 0) Экспорт

	Если РежимОбновления = Перечисления.РежимыОбновленияДанных.НеОбновлять Тогда
		Возврат Ложь;
	ИначеЕсли РежимОбновления = Перечисления.РежимыОбновленияДанных.Принудительно Тогда
		Возврат Истина;
	КонецЕсли;

	Возврат (ОбъектДанных = Неопределено
		ИЛИ (ПериодОбновления < (ТекущаяУниверсальнаяДатаВМиллисекундах() - МоментАктуальности)));

КонецФункции // ТребуетсяОбновление()

// Диагностическая процедура для вывода списка полей объекта
//   
// Параметры:
//   ОбъектДанных        - Произвольный    - объект, поля которого требуется вывести
//
Процедура ВывестиПоляОбъекта(Знач ОбъектДанных) Экспорт

	Коллекция = "";
	Если ТипЗнч(ОбъектДанных) = Тип("Массив") Тогда
		Если ОбъектДанных.Количество() = 0 Тогда
			Возврат;
		КонецЕсли;

		Коллекция = СокрЛП(ТипЗнч(ОбъектДанных)) + "\";
		ОбъектДанных = ОбъектДанных[0];
	КонецЕсли;

	Лог.Информация("Поля объекта ""%1%2"":", Коллекция, СокрЛП(ТипЗнч(ОбъектДанных)));

	Для Каждого ТекПоле Из ОбъектДанных Цикл
		Сообщить(СокрЛП(ТекПоле.Ключ) + ":" + СокрЛП(ТекПоле.Значение));
	КонецЦикла;

КонецПроцедуры // ВывестиПоляОбъекта()

// Функция возвращает структуру параметров авторизации для типа объектов кластера 1С
//   
// Параметры:
//    ТипАвторизации          - Строка        - тип тобъекта авторизации (agent, cluster, infobase)
//    ПараметрыАвторизации    - Структура     - структура параметров авторизации
//        *Администратор          - Строка        - имя администратора
//        *Пароль                 - Строка        - пароль администратора
//
// Возвращаемое значение:
//    Строка - структура параметров авторизации для типа объектов кластера 1С
//
Функция ПараметрыАвторизации(Знач ТипАвторизации, Знач ПараметрыАвторизации = Неопределено) Экспорт
	
	Результат = Новый Структура();
	Результат.Вставить("Тип"          , ТипАвторизации);
	Результат.Вставить("Администратор", "");
	Результат.Вставить("Пароль"       , "");

	Если ТипЗнч(ПараметрыАвторизации) = Тип("Структура") Тогда
		ЗаполнитьЗначенияСвойств(Результат, ПараметрыАвторизации);
	КонецЕсли;

	Возврат Результат;

КонецФункции // ПараметрыАвторизации()
	
// Функция возвращает строку параметров авторизации для типа объектов кластера 1С
//   
// Параметры:
//    ПараметрыАвторизации    - Структура     - структура параметров авторизации
//        *Тип                    - Строка        - тип тобъекта авторизации (agent, cluster, infobase)
//        *Администратор          - Строка        - имя администратора
//        *Пароль                 - Строка        - пароль администратора
//
// Возвращаемое значение:
//    Строка - строка параметров авторизации для типа объектов кластера 1С
//
Функция СтрокаАвторизации(Знач ПараметрыАвторизации) Экспорт
	
	Если НЕ ТипЗнч(ПараметрыАвторизации)  = Тип("Структура") Тогда
		Возврат "";
	КонецЕсли;

	Если НЕ ПараметрыАвторизации.Свойство("Администратор") Тогда
		Возврат "";
	КонецЕсли;

	Если ПустаяСтрока(ПараметрыАвторизации.Администратор) Тогда
		Возврат "";
	КонецЕсли;

	СтрокаАвторизации = СтрШаблон("--%1-user=%2",
	                              ПараметрыАвторизации.Тип,
	                              ОбернутьВКавычки(ПараметрыАвторизации.Администратор));

	Если НЕ ПустаяСтрока(ПараметрыАвторизации.Пароль) Тогда
		СтрокаАвторизации = СтрокаАвторизации + СтрШаблон(" --%1-pwd=%2",
		                                                  ПараметрыАвторизации.Тип,
		                                                  ПараметрыАвторизации.Пароль);
	КонецЕсли;
	
	Возврат СтрокаАвторизации;
	
КонецФункции // СтрокаАвторизации()
	
// Функция возвращает лог библиотеки
//   
// Возвращаемое значение:
//    Логгер - лог библиотеки
//
Функция Лог() Экспорт
	
	Если Лог = Неопределено Тогда
		Лог = Логирование.ПолучитьЛог(ИмяЛога());
	КонецЕсли;

	Возврат Лог;

КонецФункции // Лог()

// Функция возвращает имя лога библиотеки
//   
// Возвращаемое значение:
//    Строка - имя лога библиотеки
//
Функция ИмяЛога() Экспорт

	Возврат "oscript.lib.irac";
	
КонецФункции // ИмяЛога()
