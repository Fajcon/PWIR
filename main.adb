with Ada.Text_IO; use Ada.Text_IO;
with Exceptions; use Exceptions;

procedure Main is
 
--Nasz magazyn  
protected Stock is
  procedure GetCleanPickle;
  procedure CleanPickle;
  procedure GetCleanJar;
  procedure CleanJar;
  procedure StoreReadyJar;
  function GetNumberOfCleanPickles return Integer;
  function GetNumberOfPickles return Integer;
  function GetNumberOfJars return Integer;
  function GetNumberOfCleanJars return Integer;
  function GetNumberOfReadyJars return Integer;

  private
   NumberOfPickles : Integer := 10;
   NumberOfCleanPickles : Integer := 1;
   NumberofJars : Integer := 10;
   NumberOfCleanJars : Integer := 1;
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
  
  procedure CleanJar is
  begin
      NumberOfJars := NumberOfJars - 1;
      NumberOfCleanJars := NumberOfCleanJars + 1;
  end CleanJar;
      
  procedure GetCleanJar is
  begin
      NumberOfCleanJars := NumberOfCleanJars - 1;
  end GetCleanJar;
  
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
    
    function GetNumberOfCleanJars return Integer is
    begin
        return NumberOfCleanJars;
    end GetNumberOfCleanJars;
    
    function GetNumberOfReadyJars return Integer is
    begin
        return NumberOfReadyJars;
    end GetNumberOfReadyJars;
        
    function GetNumberOfJars return Integer is
    begin
        return NumberOfJars;
    end GetNumberOfJars;
    
end Stock;

protected type Slot is
	entry AddPickle;
	entry SetJar;
	entry AddVinegar;
	entry AddSpices;
	entry StoreJar;
	procedure Check;
	function isInMachine return Boolean;
	private
	    Vinegar: Boolean := False;
		Jar: Boolean := False;
		Pickle : Boolean := False;
		Spices : Boolean := False;	    
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
		
	entry AddSpices when (Jar and Pickle) is
	begin
	    Spices := True;
	end;
	
	entry AddVinegar when (Jar and Pickle and Spices) is
	begin
	    Vinegar := True;
	end;

	
	entry StoreJar when (Jar and Pickle and Vinegar) is
	begin
	    Stock.StoreReadyJar;
	    inMachine := False;
	    Jar := False;
	    Pickle := False;
	    Spices := False;
	    Vinegar := False;
	end;
	
	procedure Check is
	begin
		if Pickle then
			Put_Line("Pickles +");
		else
			Put_Line("Pickles -");
		end if;
        if Spices then
            Put_Line("Spices +");
        else
            Put_Line("Spices -");
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
task PickleCleaner;

task body PickleCleaner is
begin
	Put_Line("PickleCleaner: I am ready to clean a pickle");
    loop
        if Stock.GetNumberOfPickles > 1 then
            Stock.CleanPickle;
            Put_Line("PickleCleaner: I am washing a pickle.");
        else
            Put_Line("There is no more pickles in stock.");
            
        end if;
    delay 5.0;
	end loop;
end PickleCleaner;


--Urządzenie myjące słoiki
task JarCleaner;

task body JarCleaner is
begin
	Put_Line("JarCleaner: I am ready to clean a jar");
    loop
        if Stock.GetNumberOfJars > 1 then
            Stock.CleanJar;
            Put_Line("JarCleaner: I am washing a jar.");
        else
            Put_Line("There is no more jars in stock.");
        end if;
    delay 5.0;
	end loop;
end JarCleaner;


--Urządzenie magazynujące gotowy słoik
task JarStorer is
    entry Start (IndexOfSlot: in Integer);
end JarStorer;

task body JarStorer is
begin
    loop
        accept Start (IndexOfSlot: in Integer) do
            Put_Line("JarStorer: I am storing the jar" & IndexOfSlot'Image);
            Slots(IndexOfSlot).StoreJar;
            delay 3.0;
	    end Start;
	end loop;
end JarStorer;

--Urządzenie dodające zalewę do słoika
task VinegarAdder is
    entry Start (IndexOfSlot: in Integer);
end VinegarAdder;

task body VinegarAdder is
begin
    loop
        accept Start (IndexOfSlot: in Integer) do
            Put_Line("VinegarAdder: I add vinegar into the jar." & IndexOfSlot'Image);
            Slots(IndexOfSlot).AddVinegar;
            delay 3.0;
            JarStorer.Start(IndexOfSlot);
	    end Start;
	end loop;
end VinegarAdder;

--Urządzenie dodające przyprawy do słoika
task SpiceAdder is
    entry Start (IndexOfSlot: in Integer);
end SpiceAdder;

task body SpiceAdder is
begin
    loop
        accept Start (IndexOfSlot: in Integer) do
            Put_Line("SpiceAdder: I add spices into the jar." & IndexOfSlot'Image);
            Slots(IndexOfSlot).AddSpices;
            delay 3.0;
            VinegarAdder.Start(IndexOfSlot);
	    end Start;
	end loop;
end SpiceAdder;

--Urządzenie dodające ogórki do słoika
task PickleAdder is
    entry Start (IndexOfSlot: in Integer);
end PickleAdder;

task body PickleAdder is
begin
    loop
        accept Start (IndexOfSlot: in Integer) do
            if Stock.GetNumberOfCleanPickles >= 1 then
                Put_Line("PickleAdder: I put pickles into the jar." & IndexOfSlot'Image);
                Slots(IndexOfSlot).AddPickle;
                delay 4.0;
                SpiceAdder.Start(IndexOfSlot);
            else
                raise No_More_Pickles_Exception;
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
    loop
        accept Start (IndexOfSlot: in Integer) do
            if Stock.GetNumberOfCleanJars >= 1 then
                Put_Line("JarSetter: I am setting the jar" & IndexOfSlot'Image);
                Slots(IndexOfSlot).SetJar;
                delay 3.0;
                PickleAdder.Start(IndexOfSlot);
            else
                raise No_More_Jars_Exception;
            end if;
            exception
               when No_More_Pickles_Exception =>
                  raise No_More_Pickles_Exception;           
	    end Start;
	end loop;
end JarSetter;

--Urządzenie sprawdzające zawartość słoika
task SupervisingMachine; 

task body SupervisingMachine is
Ready_Jars: Integer;
begin
  loop
    for I in Slots'Range loop
        Put_Line("SupervisingMachine: I am checking " & Integer'Image (I) & " Jar.");
        Slots(I).Check;
    end loop;
    Ready_Jars := Stock.GetNumberOfReadyJars;
    Put_Line("SupervisingMachine: Number of ready Jars:" & Ready_Jars'Image);
    delay 3.0;
  end loop; 
end SupervisingMachine;

I : Integer := 1;
begin
	loop
	    if(not Slots(I).isInMachine) then
	        JarSetter.Start(I);	           
            I := I + 1;
            if(I > Slots'Length) then
                I := 1;
            end if;
        end if;        
    end loop;
    exception
       when No_More_Jars_Exception =>
          Put_Line("There is no more clean jars in stock. Exception");          
       when No_More_Pickles_Exception =>
          Put_Line("There is no more clean pickles in stock exception");          
end Main;