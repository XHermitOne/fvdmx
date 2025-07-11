{
Модуль функций-заглушек Memavail and Maxavail.

Старые функции Turbo Pascal Функции MemAvail и MaxAvail 
больше не доступны в Free Pascal с версии 2.0. 

Причина несовместимости указана ниже:

В современных операционных системах 4 идея «доступной свободной памяти» не подходит для приложения. 
Причины:
    Один цикл процессора после того, как приложение запросило у ОС, 
    сколько памяти свободно, другое приложение могло выделить все.
    Неясно, что означает «свободная память»: включает ли она память подкачки, 
    включает ли она дисковую кеш-память 
    (дисковый кеш может увеличиваться и уменьшаться в современных ОС), 
    включает ли она память, выделенную другим приложениям, но которая может быть поменял местами и т. д.

Поэтому программы, использующие функции MemAvail и MaxAvail, следует переписать, 
чтобы они больше не использовали эти функции, потому что это больше не имеет смысла в современных ОС. 
Есть 3 возможности:

    Используйте исключения, чтобы отловить ошибки нехватки памяти.
    Установите для глобальной переменной ReturnNilIfGrowHeapFails значение True и проверяйте после каждого выделения, отличается ли указатель от Nil.
    Не обращайте внимания и объявите фиктивную функцию MaxAvail, которая всегда возвращает High (LongInt) (или какую-то другую константу). 

Версия: 0.0.0.1
}

unit Avail;

//{$mode Delphi}{$H+}
{$mode objfpc}{$H+}

interface

{
Возвращает размер     наибольшего      непрерывного
свободного   блока  кучи,  соответствующей  размеру
наибольшей динамической переменной,  которая  может
быть распределена в момент вызова MaxAvail
}
function MaxAvail(): Longint;

{
Возвращает количество  имеющихся  в  куче свободных байт
}
function MemAvail(): Longint;

var
  Mem: array [0..$7fffffff-1] of Byte;

implementation

function MaxAvail(): Longint;
begin
  Result := High(Longint);
end;

{
Возвращает количество  имеющихся  в  куче свободных байт
}
function MemAvail(): Longint;
begin
  Result := High(Longint);
end;

end.
