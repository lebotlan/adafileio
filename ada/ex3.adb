with Ada.Text_IO ;
with File_Io ;

-- Exemple : plusieurs données sur chaque ligne

-- Entrée
--
--    Lyon 400 300 326 700 840
--    Toulouse 567 27 400 41 670
--    Rennes 900 63 567 342 785
--    Rouen 1 608 567 32 543
--    Strasbourg 1000 903 543 675 567
--    CVL 592 953 78 152 634
--    HDF 0 67 243 345 82

procedure Ex3 is
   
   package Txt renames Ada.Text_IO ;
   package IO renames File_Io ;
   
   Read : IO.T_Reader := IO.Fopen("files/ex3.txt") ;
begin
   
   while not Read.EOF loop
      declare
         Name : String := Read.XStr(' ') ;
         Data : IO.Intarray := Read.Ints ;
      begin
         Txt.Put_Line("Read data of '" & Name & "'  =>  " & IO.Intarray2s(Data)) ;
         
         -- Finish the current line, otherwise the next Read.str will return an empty string.
         Read.NL ;
      end ;
   end loop ;
      
   Txt.New_Line ;
   Read.Fclose ;
      
end Ex3 ;
