with Ada.Text_IO ;
with File_Io ;

-- Exemple : une grille sans espaces
--
-- 3 5
-- ...#.
-- ...##
-- ..B.#
    
procedure Ex5 is
   
   package Txt renames Ada.Text_IO ;
   package IO renames File_Io ;
   
   Read : IO.T_Reader := IO.Fopen("files/ex5.txt") ;
   NL,NC : Integer ;
   K : Character ;
begin
   
   NL := Read.Int ;
   NC := Read.Int ;
   
   -- Read the matrix
   for L in 1..NL loop
      for C in 1..NC loop
         K := Read.Char ;
         
         Txt.Put(K & " ") ;
      end loop ;
      Txt.New_Line ;
   end loop ;
   
   Txt.New_Line ;
   Read.Fclose ;
      
end Ex5 ;
