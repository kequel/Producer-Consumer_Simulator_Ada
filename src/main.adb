with Ada.Text_IO; use Ada.Text_IO;
with Ada.Characters.Latin_1; use Ada.Characters.Latin_1;
with Ada.Integer_Text_IO;
with Ada.Numerics.Discrete_Random;

procedure Simulation is

   Number_Of_Producers: constant Integer := 5;
   Number_Of_Assemblies: constant Integer := 3;
   Number_Of_Consumers: constant Integer := 2;

   subtype Producer_Type is Integer range 1 .. Number_Of_Producers;
   subtype Assembly_Type is Integer range 1 .. Number_Of_Assemblies;
   subtype Consumer_Type is Integer range 1 .. Number_Of_Consumers;

   Product_Name: constant array (Producer_Type) of String(1 .. 30)
     := ("Keychain                      ", 
         "Socks                         ", 
         "T-shirt                       ", 
         "Mousepad                      ", 
         "Mousepad Deluxe               ");

   Assembly_Name: constant array (Assembly_Type) of String(1 .. 30)
     := ("Basic                         ", 
         "Deluxe                        ", 
         "Premium Deluxe                ");

   task type Producer is
      entry Start(Product: in Producer_Type; Production_Time: in Integer);
   end Producer;

   task type Consumer is
      entry Start(Consumer_Number: in Consumer_Type;
                  Consumption_Time: in Integer);
   end Consumer;

   task type Buffer is
      entry Take(Product: in Producer_Type; Number: in Integer);
      entry Deliver(Assembly: in Assembly_Type; Number: out Integer);
      entry Nobel_Gift(Charity_Level: in Integer);
   end Buffer;

   task type CharityEvent is
      entry Start(goodness_of_heart_level: out Integer);
   end CharityEvent;

   P: array ( 1 .. Number_Of_Producers ) of Producer;
   K: array ( 1 .. Number_Of_Consumers ) of Consumer;
   B: Buffer;
   C: CharityEvent;

   task body CharityEvent is
      subtype Charity_Level_Range is integer range 0 .. 10;
      package Random_Charity is new Ada.Numerics.Discrete_Random(Charity_Level_Range);
      GC: Random_Charity.Generator;
   begin
      loop
         accept Start(goodness_of_heart_level: out Integer) do
            Random_Charity.Reset(GC);
            goodness_of_heart_level := Random_Charity.Random(GC);
         end Start;
      end loop;
   end CharityEvent;

   task body Producer is
      subtype Production_Time_Range is Integer range 1 .. 3;
      package Random_Production is new Ada.Numerics.Discrete_Random(Production_Time_Range);
      G: Random_Production.Generator;
      Producer_Type_Number: Integer;
      Product_Number: Integer;
      Production: Integer;
      Random_Time: Duration;
      In_Storage_Count: Integer := 0;
   begin
      accept Start(Product: in Producer_Type; Production_Time: in Integer) do
         Random_Production.Reset(G);
         Product_Number := 1;
         Producer_Type_Number := Product;
         Production := Production_Time;
      end Start;
      Put_Line(ESC & "[93m" & "P: Started producer of " & Product_Name(Producer_Type_Number) & ESC & "[0m");
      loop
         if In_Storage_Count > 0 then
            Random_Time := Duration(Random_Production.Random(G)) / 3.0;
         else
            Random_Time := Duration(Random_Production.Random(G));
         end if;

         delay Random_Time;
         Put_Line(ESC & "[93m" & "P: Produced product " & Product_Name(Producer_Type_Number)
                  & " number "  & Integer'Image(Product_Number) & ESC & "[0m");
         select
            B.Take(Producer_Type_Number, Product_Number);
            if In_Storage_Count > 0 then
               In_Storage_Count := In_Storage_Count - 1;
            end if;
         or
            delay 0.0;
               In_Storage_Count := In_Storage_Count + 1;
               case In_Storage_Count is
                  when 1 =>
                     Put_Line(ESC & "[93m" & "P: To storage went " & Integer'Image(In_Storage_Count) & "st product: " & Product_Name(Producer_Type_Number)
                              & " number " & Integer'Image(Product_Number) & ESC & "[0m");
                  when 2 =>
                     Put_Line(ESC & "[93m" & "P: To storage went " & Integer'Image(In_Storage_Count) & "nd product: " & Product_Name(Producer_Type_Number)
                              & " number " & Integer'Image(Product_Number) & ESC & "[0m");
                  when 3 =>
                     Put_Line(ESC & "[93m" & "P: To storage went " & Integer'Image(In_Storage_Count) & "rd product: " & Product_Name(Producer_Type_Number)
                              & " number " & Integer'Image(Product_Number) & ESC & "[0m");
                  when others =>
                     Put_Line(ESC & "[93m" & "P: To storage went " & Integer'Image(In_Storage_Count) & "th product: " & Product_Name(Producer_Type_Number)
                              & " number " & Integer'Image(Product_Number) & ESC & "[0m");
               end case;
         end select;
         Product_Number := Product_Number + 1;
         if In_Storage_Count > 3 then
            Put_Line(ESC & "[93m" & "P: On vacation went producer " & Product_Name(Producer_Type_Number)
                     & ESC & "[0m");
            delay 3.0;
         end if;
      end loop;
   end Producer;

   task body Consumer is
      subtype Consumption_Time_Range is Integer range 4 .. 8;
      package Random_Consumption is new
        Ada.Numerics.Discrete_Random(Consumption_Time_Range);

      package Random_Assembly is new
        Ada.Numerics.Discrete_Random(Assembly_Type);

      G: Random_Consumption.Generator;
      GA: Random_Assembly.Generator;
      Consumer_Nb: Consumer_Type;
      Assembly_Number: Integer;
      Consumption: Integer;
      Assembly_Type: Integer;
      Consumer_Name: constant array (1 .. Number_Of_Consumers)
        of String(1 .. 12)
        := ("MEDIA EXPERT", "RTV EURO AGD");
      Consumer_Happy: Boolean;
   begin
      accept Start(Consumer_Number: in Consumer_Type;
                   Consumption_Time: in Integer) do
         Random_Consumption.Reset(G);
         Random_Assembly.Reset(GA);
         Consumer_Nb := Consumer_Number;
         Consumption := Consumption_Time;
      end Start;
      Put_Line(ESC & "[96m" & "C: Started consumer " & Consumer_Name(Consumer_Nb) & ESC & "[0m");
      loop
         if Consumer_Happy then
            delay Duration(Random_Consumption.Random(G))/2.0;
            Consumer_Happy := False;
         else
            delay Duration(Random_Consumption.Random(G));
         end if;
         Assembly_Type := Random_Assembly.Random(GA);
         select
            B.Deliver(Assembly_Type, Assembly_Number);
            if Assembly_Number /= 0 then
               Put_Line(ESC & "[96m" & "C: " & Consumer_Name(Consumer_Nb) & " takes assembly " &
                         Assembly_Name(Assembly_Type) & " number " &
                         Integer'Image(Assembly_Number) & ESC & "[0m");
               Consumer_Happy := True;
            else
               Put_Line(ESC & "[96m" & "C: " & Consumer_Name(Consumer_Nb) & " as there are no products in storage can not take assembly " &
                         Assembly_Name(Assembly_Type) & ESC & "[0m");
            end if;
         or
            delay 2.0;
            Put_Line("Consumer waited too long. Does not want it anymore.");
         end select;
      end loop;
   end Consumer;

   task body Buffer is
      subtype Buffer_Time_Range is Integer range 1 .. 3;
      package Random_Buffer is new Ada.Numerics.Discrete_Random(Buffer_Time_Range);
      Gb: Random_Buffer.Generator;
      Random_Time_B: Duration;

      Storage_Capacity: constant Integer := 30;
      Keychain_Max: constant Integer := 9;
      Socks_Max: constant Integer := 9;
      Tshirt_Max: constant Integer := 3;
      Mousepad_Max: constant Integer := 3;
      MousepadDeluxe_Max: constant Integer := 6;

      type Storage_type is array (Producer_Type) of Integer;
      Storage: Storage_type := (0, 0, 0, 0, 0);
      Assembly_Content: array(Assembly_Type, Producer_Type) of Integer
        := ((2, 1, 2, 0, 2),
            (1, 2, 0, 1, 0),
            (3, 2, 2, 0, 1));
      Max_Assembly_Content: array(Producer_Type) of Integer;
      Assembly_Number: array(Assembly_Type) of Integer := (1, 1, 1);
      In_Storage: Integer := 0;

      procedure Wait_Buffer is
      begin
         Random_Buffer.Reset(Gb);
         Random_Time_B := Duration(Random_Buffer.Random(Gb));
         delay Random_Time_B;
      end Wait_Buffer;

      procedure Setup_Variables is
      begin
         for W in Producer_Type loop
            Max_Assembly_Content(W) := 0;
            for Z in Assembly_Type loop
               if Assembly_Content(Z, W) > Max_Assembly_Content(W) then
                  Max_Assembly_Content(W) := Assembly_Content(Z, W);
               end if;
            end loop;
         end loop;
      end Setup_Variables;

      function Can_Accept(Product: Producer_Type) return Boolean is
      begin
         if In_Storage >= Storage_Capacity then
            return False;
         else
            case Product is
               when 1 =>
                  if Storage(Product) = Keychain_Max then
                     return False;
                  end if;
               when 2 =>
                  if Storage(Product) = Socks_Max then
                     return False;
                  end if;
               when 3 =>
                  if Storage(Product) = Tshirt_Max then
                     return False;
                  end if;
               when 4 =>
                  if Storage(Product) = Mousepad_Max then
                     return False;
                  end if;
               when 5 =>
                  if Storage(Product) = MousepadDeluxe_Max then
                     return False;
                  end if;
               when others =>
                  return True;
            end case;
            return True;
         end if;
      end Can_Accept;

      function Can_Deliver(Assembly: Assembly_Type) return Boolean is
      begin
         for W in Producer_Type loop
            if Storage(W) < Assembly_Content(Assembly, W) then
               return False;
            end if;
         end loop;
         return True;
      end Can_Deliver;

      procedure Storage_Contents is
      begin
         for W in Producer_Type loop
            Put_Line("|   Storage contents: " & Integer'Image(Storage(W)) & " " & Product_Name(W));
         end loop;
         Put_Line("|   Number of products in storage: " & Integer'Image(In_Storage));
      end Storage_Contents;

   begin
      Put_Line(ESC & "[91m" & "B: Buffer started" & ESC & "[0m");
      Setup_Variables;
      loop
         select
            accept Take(Product: in Producer_Type; Number: in Integer) do
               if Can_Accept(Product) then
                  Put_Line(ESC & "[91m" & "B: Accepted product " & Product_Name(Product) & " number " &
                            Integer'Image(Number) & ESC & "[0m");
                  Storage(Product) := Storage(Product) + 1;
                  In_Storage := In_Storage + 1;
               else
                  Put_Line(ESC & "[91m" & "B: Rejected product " & Product_Name(Product) & " number " &
                            Integer'Image(Number) & ESC & "[0m");
               end if;
            end Take;
            Storage_Contents;
         or
            accept Deliver(Assembly: in Assembly_Type; Number: out Integer) do
               if Can_Deliver(Assembly) then
                  Wait_Buffer;
                  Put_Line(ESC & "[91m" & "B: Delivered assembly " & Assembly_Name(Assembly) & " number " &
                            Integer'Image(Assembly_Number(Assembly)) & ESC & "[0m");
                  for W in Producer_Type loop
                     Storage(W) := Storage(W) - Assembly_Content(Assembly, W);
                     In_Storage := In_Storage - Assembly_Content(Assembly, W);
                  end loop;
                  Number := Assembly_Number(Assembly);
                  Assembly_Number(Assembly) := Assembly_Number(Assembly) + 1;
               else
                  Put_Line(ESC & "[91m" & "B: Lacking products for assembly " & Assembly_Name(Assembly) & ESC & "[0m");
                  Number := 0;
               end if;
            end Deliver;
         or
            accept Nobel_Gift(Charity_Level : in Integer) do
               if Charity_Level > 7 then
                  Put_Line(ESC & "[92m" & "B: Nobel gift accepted with charity level " & Integer'Image(Charity_Level) & ESC & "[0m");
                   for W in Producer_Type loop
                     Storage(W) := Storage(W) / 2;
                     In_Storage := In_Storage - (Storage(W) / 2);
                  end loop;
               else
                  Put_Line(ESC & "[91m" & "B: Nobel gift rejected, charity level too low: " & Integer'Image(Charity_Level) & ESC & "[0m");
               end if;
            end Nobel_Gift;
         end select;
         Storage_Contents;
      end loop;
   end Buffer;

begin
   for I in 1 .. Number_Of_Producers loop
      P(I).Start(I, 10);
   end loop;
   for J in 1 .. Number_Of_Consumers loop
      K(J).Start(J, 12);
   end loop;

   loop
      declare
         Charity_Level: Integer;
      begin
         C.Start(Charity_Level);
         B.Nobel_Gift(Charity_Level);
         delay 5.0;
      end;
   end loop;

end Simulation;
