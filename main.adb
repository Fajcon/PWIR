with Ada.Text_IO;
use Ada.Text_IO;

procedure Main is
 
--Nasz magazyn  
protected Stock is
  procedure GetPickle;
	function GetNumberOfPickles return Integer;
  private
   NumberOfPickles : Integer := 10;
end Stock;

protected body Stock is
  procedure GetPickle is
  begin
    NumberOfPickles := NumberOfPickles - 1;
  end GetPickle;
	function GetNumberOfPickles return Integer is
	begin
		return NumberOfPickles;
	end GetNumberOfPickles;
end Stock;

--Typ słoik TODO zastanowic sie czy zrobić to inaczej
protected type Slot is
	entry AddPickle;
	entry SetJar;
	procedure Start;
	procedure Check;
	private
		Ok: Boolean := False;
		Jar: Boolean := True;
		Pickle : Boolean := False;
end Slot;

protected body Slot is
	entry SetJar when (not Jar and Ok) is
	begin
		Jar:= True;
	end SetJar;
	entry AddPickle when (Jar and not Pickle and Ok) is
	begin
		Pickle := True;
	end AddPickle;
	procedure Start is
	begin
		Ok:= True;
	end Start;
	procedure Check is
	begin
		if Pickle then
			Put_Line("Pickles +");
		else
			Put_Line("Pickles -");
		end if;
	end Check;
end Slot;

--Nasze sloty na słoiki TODO zamienić na listę.

--  Wielkość tablicy slotów
subtype Index is integer range 1..2;

type SlotsArray is array (Index) of Slot;

--Nasze sloty na słoiki
Slots : array (1 .. 3) of Slot;
  
--Urządzenie dodające ogórki do słoika
task Machine2;

task body Machine2 is
begin  
	Put_Line("Machine2: I am ready to put a pickle into jar.");
	--TODO change to exception
	if Stock.GetNumberOfPickles > 1 then
		Stock.GetPickle;
		Slots(1).AddPickle;
	else
		Put_Line("There is no more pickles in stock.");
	end if;
	Put_Line("Machine2: I put pickle into the jar.");
end Machine2;


--Urządzenie sprawdzające zawartość słoika
--TODO to jest tylko tymczasowe zostanie zastąpione UI
task SupervisingMachine; 

task body SupervisingMachine is
begin
  loop
	Put_Line("SupervisingMachine: I am checking Jar.");
	Slots(1).Check;
  delay 0.5;
  end loop; 
end SupervisingMachine;

begin
	Put_Line("Begin of production.");
  delay 0.5;
	Slots(1).Start;
end Main;
  
