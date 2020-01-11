with Ada.Text_IO;
use Ada.Text_IO;

procedure Main is
 
--Nasz magazyn  
protected Stock is
  procedure GetCleanPickle;
  procedure CleanPickle;
	function GetNumberOfPickles return Integer;
  private
   NumberOfPickles : Integer := 10;
   NumberOfCleanPickles : Integer := 0;
end Stock;

protected body Stock is
procedure CleanPickle is
  begin
    NumberOfPickles := NumberOfPickles - 1;
    NumberOfCleanPickles := NumberOfCleanPickles + 1;
  end CleanPickle;
  procedure GetCleanPickle is
  begin
    NumberOfCleanPickles := NumberOfCleanPickles - 1;
  end GetCleanPickle;
	function GetNumberOfPickles return Integer is
	begin
		return NumberOfPickles;
	end GetNumberOfPickles;
--  	function GetNumberOfCleanPickles return Integer is
--      begin
--      	return NumberOfCleanPickles;
--      end GetNumberOfCleanPickles;
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
        Stock.CleanPickle;                  --!!!!!!!!!!
        Stock.GetCleanPickle;
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
	for I in Slots'Range loop
	    if Stock.GetNumberOfPickles > 1 then
--  	        Stock.CleanPickle;
--  	        Put_Line("I am cleaning a pickle.");
--  		    Stock.GetCleanPickle;		
            Slots(I).AddPickle; 
            Put_Line("Machine2: I put pickle into the " & Integer'Image (I) & " jar."); 
	    else
		    Put_Line("There is no more pickles in stock.");
	    end if;	    
	end loop;
end Machine2;


--Urządzenie sprawdzające zawartość słoika
--TODO to jest tylko tymczasowe zostanie zastąpione UI
task SupervisingMachine; 

task body SupervisingMachine is
begin
  loop
--  	Put_Line("SupervisingMachine: I am checking Jar.");
--  	Slots(1).Check;
--    delay 0.5;
    for I in Slots'Range loop
        Put_Line("SupervisingMachine: I am checking " & Integer'Image (I) & " Jar.");
        Slots(I).Check;
        delay 0.5;
    end loop;
  end loop; 
end SupervisingMachine;

begin
	Put_Line("Begin of production.");
  delay 0.5;
	for I in Slots'Range loop
        Slots(I).Start;
    end loop;
end Main;
  
