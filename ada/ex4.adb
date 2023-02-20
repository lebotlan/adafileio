with Ada.Text_IO ;
with File_Io ;

-- Exemple : une grille puis une liste de paires
--
-- 3
-- 0 0 E
-- 0 E 0
-- 0 0 E
-- 1 1
-- 2 2
-- 1 2
  
procedure Ex4 is
   
   package Txt renames Ada.Text_IO ;
   package IO renames File_Io ;
   
   Read : IO.T_Reader := IO.Fopen("files/ex4.txt") ;
   N : Integer ;
   K : Character ;
   A,B : Integer ;
begin
   
   N := Read.Int ;
   
   -- Read the matrix
   for L in 1..N loop
      for C in 1..N loop
         K := Read.Char ;
         
         Txt.Put_Line(" Read " & K'Image & " at (" & L'Image & ", " & C'Image & ")") ;
      end loop ;
   end loop ;
   
   Txt.New_Line ;
   
   -- Read the couples
   while not Read.Eof loop
      A := Read.Int ;
      B := Read.Int ;
      Txt.Put_Line(" Pos (" & A'Image & ", " & B'Image & ")") ;
   end loop ;
      
   Txt.New_Line ;
   Read.Fclose ;
      
end Ex4 ;
