with Ada.Text_IO;
use Ada.Text_IO;

procedure Main is
 
--Nasz magazyn  
protected Stock is
  procedure GetCleanPickle;
  procedure CleanPickle;
  function GetNumberOfCleanPickles return Integer;
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

	function GetNumberOfCleanPickles return Integer is
    begin
    	return NumberOfCleanPickles;
    end GetNumberOfCleanPickles;
end Stock;

protected type Slot is
	entry AddPickle;
	entry SetJar;
	entry AddVinegar;
	procedure Check;
	function isInMachine return Boolean;
	private
	    Vinegar: Boolean := False;
	    --TODO ustawić na false idodać maszyne która ustawia to na true
		Jar: Boolean := True;
		Pickle : Boolean := False;
	    --TODO chodzi o to czy jest używany ustawić na true w gdy rozpoczynamy na nim prace i na false w ostatniej maszynie
	    --gdy jest false to wszystkie pola też muszą byc false
		inMachine : Boolean := False;
end Slot;

protected body Slot is
	entry SetJar when (not Jar) is
	begin
		Jar:= True;
	end SetJar;
	
	entry AddPickle when (Jar and not Pickle) is
	begin
        inMachine := True;
        Stock.GetCleanPickle;
        Pickle := True;
	end AddPickle;
	
	entry AddVinegar when (Jar and Pickle) is
	begin
	    Vinegar := True;
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
            Put_Line("PickleAdder: I put pickle into the jar." & IndexOfSlot'Image);
            delay 4.0;
            if Stock.GetNumberOfCleanPickles >= 1 then
                Slots(IndexOfSlot).AddPickle;
                VinegarAdder.Start(IndexOfSlot);
            else
                Put_Line("There is no more pickles in stock.");
            end if;
	    end Start;
	end loop;
end PickleAdder;

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
            PickleAdder.Start(I);
            I := I + 1;
            if(I > Slots'Length) then
                I := 1;
            end if;
        end if;
    end loop;
end Main;
  
