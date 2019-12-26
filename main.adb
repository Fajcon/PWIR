with Ada.Text_IO;
use Ada.Text_IO;

procedure Main is
  
--Typ słoik TODO zastanowic sie czy zrobić to inaczej
protected type Jar (Init_Sem: Integer := 0) is
	entry AddPickle;
	procedure Start;
	procedure Check;
	private
		Ok: Boolean := False;
		Nr: Integer := Init_Sem;
		Pickle : Boolean := False;
end Jar;

protected body Jar is
	entry AddPickle when (not Pickle and Ok) is
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
end Jar;

--Nasz słoik TODO zamienić na listę słoików
Jar1: Jar(1);  

--Pierwsze urządzenie dodające ogórki do słoika
task Machine1;

task body Machine1 is
	NumberOfCucumbersInStock : Integer := 10;
begin  
	Put_Line("Machine1: I am putting a pickle into jar.");
	Jar1.AddPickle;
	NumberOfCucumbersInStock:= NumberOfCucumbersInStock - 1;
	Put_Line("Machine1: ready");
end Machine1;


--Urządzenie sprawdzające zawartość słoika
--TODO to jest tylko tymczasowe zostanie zastąpione UI
task SupervisingMachine; 

task body SupervisingMachine is
begin
	Put_Line("SupervisingMachine: I am checking Jar.");
	Jar1.Check;
  delay 2.0;
	Put_Line("SupervisingMachine: I am checking Jar.");
	Jar1.Check;
end SupervisingMachine;

begin
	Put_Line("Begin of production.");
  delay 0.5;
	Jar1.Start;
end Main;
  
