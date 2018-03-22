Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем Элементы;

Перем ПериодОбновления;
Перем МоментАктуальности;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера		- АгентКластера	- ссылка на родительский объект агента кластера
//   Кластер			- Кластер		- ссылка на родительский объект кластера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер)

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;

	Элементы = Неопределено;

	ПериодОбновления = 60000;

КонецПроцедуры

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//											- Ложь - данные будут получены если истекло время актуальности
//													или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь)

	Если НЕ Служебный.ТребуетсяОбновление(Элементы, МоментАктуальности, ПериодОбновления, ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("cluster");
	ПараметрыЗапуска.Добавить("admin");
	ПараметрыЗапуска.Добавить("list");

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Элементы = Служебный.РазобратьВыводКоманды(Служебный.ВыводКоманды());

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

КонецПроцедуры // ОбновитьДанные()

// Функция возвращает список администраторов кластера 1С
//   
// Параметры:
//   ПоляУпорядочивания 	- Строка		- Список полей упорядочивания списка администратор, разделенные ","
//											  если не указаны, то имя администратора name
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - список администраторов кластеров 1С
//
Функция ПолучитьСписок(Знач ПоляУпорядочивания = "", ОбновитьПринудительно = Ложь) Экспорт

	ОбновитьДанные(ОбновитьПринудительно);

	Если НЕ ЗначениеЗаполнено(ПоляУпорядочивания) = 0 Тогда
		ПоляУпорядочивания = "name";
	КонецЕсли;

	Возврат Служебный.ИерархическоеПредставлениеМассиваСоответствий(Элементы, ПоляУпорядочивания);

КонецФункции // ПолучитьСписок()

// Функция возвращает описание администратора кластера 1С
//   
// Параметры:
//   Отбор				 	- Структура	- Структура отбора сеансов (<поле>:<значение>)
//   ОбновитьПринудительно 	- Булево	- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - описание администратора кластера 1С
//
Функция Получить(Отбор, ОбновитьПринудительно = Ложь) Экспорт

	ОбновитьДанные(ОбновитьПринудительно);

	Результат = Служебный.ПолучитьЭлементыИзМассиваСоответствий(Элементы, Отбор);

	Если Результат.Количество() = 0 Тогда
		Возврат Неопределено;
	ИначеЕсли Результат.Количество() = 1 Тогда
		Возврат Результат[0];
	Иначе
		Возврат Результат;
	КонецЕсли;

КонецФункции // Получить()

// Процедура добавляет нового администратора кластера
//   
// Параметры:
//   Имя			 	- Строка		- имя администратора кластера 1С
//   Пароль			 	- Строка		- пароль администратора кластера 1С
//   УстановитьТекущим 	- Булево		- Истина - сделать добавленного администратора текущим для кластера
//   Описание		 	- Строка		- описание администратора кластера 1С
//   СпособАвторизации 	- Строка		- Пароль / пользователь ОС
//   ПользовательОС 	- Строка		- пользователь ОС, соответствующий администратору
//
Процедура Добавить(Имя
				 , Пароль = ""
				 , УстановитьТекущим = Ложь
				 , Описание = ""
				 , СпособАвторизации = "pwd"
				 , ПользовательОС = "") Экспорт

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("cluster");
	ПараметрыЗапуска.Добавить("admin");
	ПараметрыЗапуска.Добавить("register");
	
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаАвторизации());

	ПараметрыЗапуска.Добавить(СтрШаблон("--name=%1", Имя));
	ПараметрыЗапуска.Добавить(СтрШаблон("--pwd=%1", Пароль));
	ПараметрыЗапуска.Добавить(СтрШаблон("--descr=%1", Описание));
	ПараметрыЗапуска.Добавить(СтрШаблон("--auth=%1", СпособАвторизации));
	ПараметрыЗапуска.Добавить(СтрШаблон("--os-user=%1", ПользовательОС));
	
	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());
	
	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Если УстановитьТекущим Тогда
		Кластер_Владелец.УстановитьАдминистратора(Имя, Пароль);
	КонецЕсли;

	Лог.Информация(Служебный.ВыводКоманды());

	Элементы = Неопределено;

КонецПроцедуры // Добавить()

// Процедура удаляет администратора кластера
//   
// Параметры:
//   Имя			 	- Строка		- имя администратора кластера 1С
//
Процедура Удалить(Имя) Экспорт

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("cluster");
	ПараметрыЗапуска.Добавить("admin");
	ПараметрыЗапуска.Добавить("remove");
	
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаАвторизации());

	ПараметрыЗапуска.Добавить(СтрШаблон("--name=%1", Имя));

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());
	
	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Лог.Информация(Служебный.ВыводКоманды());

	Элементы = Неопределено;

КонецПроцедуры // Удалить()

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
