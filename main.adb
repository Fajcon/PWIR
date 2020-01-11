with Ada.Text_IO;
use Ada.Text_IO;

procedure Main is
 
--Nasz magazyn  
protected Stock is
  procedure GetCleanPickle;
  procedure CleanPickle;
  procedure StoreReadyJar;
  function GetNumberOfCleanPickles return Integer;
  function GetNumberOfPickles return Integer;
  private
   NumberOfPickles : Integer := 10;
   NumberOfCleanPickles : Integer := 0;
   NumberOfReadyJars : Integer := 0;
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
  
  procedure StoreReadyJar is
  begin
    NumberOfReadyJars := NumberOfReadyJars + 1;
  end StoreReadyJar;

    function GetNumberOfPickles return Integer is 
	begin
		return NumberOfPickles;
	end GetNumberOfPickles;

	function GetNumberOfCleanPickles return Integer is
    begin
    	return NumberOfCleanPickles;
    end GetNumberOfCleanPickles;
    
    function GetNumberOfReadyJars return Integer is 
    begin
    	return NumberOfReadyJars;
    end GetNumberOfReadyJars;
end Stock;

protected type Slot is
	entry AddPickle;
	entry SetJar;
	entry AddVinegar;
	entry StoreJar;
	procedure Check;
	function isInMachine return Boolean;
	private
	    Vinegar: Boolean := False;
		Jar: Boolean := False;
		Pickle : Boolean := False;	    
		inMachine : Boolean := False;   --gdy jest false to wszystkie pola też muszą byc false
end Slot;

protected body Slot is
	entry SetJar when (not Jar) is
	begin
	    inMachine := True;
		Jar:= True;
	end SetJar;
	
	entry AddPickle when (Jar and not Pickle) is
	begin
        Stock.GetCleanPickle;
        Pickle := True;
	end AddPickle;
	
	entry AddVinegar when (Jar and Pickle) is
	begin
	    Vinegar := True;
	end;
	
	entry StoreJar when (Jar and Pickle and Vinegar) is
	begin
	    Stock.StoreReadyJar;
	    inMachine := False;
	    Jar := False;
	    Pickle := False;
	    Vinegar := False;
	end;
	
	procedure Check is
	begin
		if Pickle then
			Put_Line("Pickles +");
		else
			Put_Line("Pickles -");
		end if;
		if Vinegar then
            Put_Line("Vinegar +");
        else
            Put_Line("Vinegar -");
        end if;
	end Check;
	
	function isInMachine return Boolean is
	begin
	    return inMachine;
	end;
end Slot;

--Nasze sloty na słoiki
Slots : array (1 .. 3) of Slot;

--Urządzenie myjące ogórki
task Machine1;

task body Machine1 is
begin
	Put_Line("Machine1: I am ready to clean a pickle");
	--TODO change to exception
    loop
        if Stock.GetNumberOfPickles > 1 then
            Stock.CleanPickle;
            Put_Line("Machine1: I am washing a pickle.");
        else
            Put_Line("There is no more pickles in stock.");
        end if;
    delay 5.0;
	end loop;
end Machine1;

--Urządzenie magazynujące gotowy słoik
task JarStorer is
    entry Start (IndexOfSlot: in Integer);
end JarStorer;

task body JarStorer is
begin
    loop
        accept Start (IndexOfSlot: in Integer) do
            Put_Line("JarStorer: I am storing the jar" & IndexOfSlot'Image);
            delay 3.0;
            Slots(IndexOfSlot).StoreJar;
	    end Start;
	end loop;
end JarStorer;

--Urządzenie dodające zalewę do słoika
task VinegarAdder is
    entry Start (IndexOfSlot: in Integer);
end VinegarAdder;

task body VinegarAdder is
begin
	--TODO change to exception
    loop
        accept Start (IndexOfSlot: in Integer) do
            Put_Line("VinegarAdder: I add vinegar into the jar." & IndexOfSlot'Image);
            delay 3.0;
            Slots(IndexOfSlot).AddVinegar;
            JarStorer.Start(IndexOfSlot);
	    end Start;
	end loop;
end VinegarAdder;

--Urządzenie dodające ogórki do słoika
task PickleAdder is
    entry Start (IndexOfSlot: in Integer);
end PickleAdder;

task body PickleAdder is
begin
	--TODO change to exception
    loop
        accept Start (IndexOfSlot: in Integer) do
            delay 4.0;
            if Stock.GetNumberOfCleanPickles >= 1 then
                Put_Line("PickleAdder: I put pickle into the jar." & IndexOfSlot'Image);
                Slots(IndexOfSlot).AddPickle;
                VinegarAdder.Start(IndexOfSlot);
            else
                Put_Line("There is no more pickles in stock.");
            end if;
	    end Start;
	end loop;
end PickleAdder;

--Urządzenie przygotowujące słoik
task JarSetter is
    entry Start (IndexOfSlot: in Integer);
end JarSetter;

task body JarSetter is
begin
	--TODO change to exception
    loop
        accept Start (IndexOfSlot: in Integer) do
            Put_Line("JarSetter: I am setting the jar" & IndexOfSlot'Image);
            delay 3.0;
            Slots(IndexOfSlot).SetJar;
            PickleAdder.Start(IndexOfSlot);
	    end Start;
	end loop;
end JarSetter;

--Urządzenie sprawdzające zawartość słoika
--TODO to jest tylko tymczasowe zostanie zastąpione UI
task SupervisingMachine; 

task body SupervisingMachine is
begin
  loop
    for I in Slots'Range loop
        Put_Line("SupervisingMachine: I am checking " & Integer'Image (I) & " Jar.");
        Slots(I).Check;
    end loop;
    delay 2.0;
  end loop; 
end SupervisingMachine;

I : Integer := 1;
begin
	loop
	    if(Stock.GetNumberOfCleanPickles >= 1 and not Slots(I).isInMachine) then
	        Put_Line(I'Img);
	        JarSetter.Start(I);
            I := I + 1;
            if(I > Slots'Length) then
                I := 1;
            end if;
        end if;
    end loop;
end Main;
  
