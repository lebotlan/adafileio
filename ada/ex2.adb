with Ada.Text_IO ;
with File_Io ;

-- Exemple : un nombre par ligne
-- n nombres sur une ligne (ici le 7 en 3è input est le nombre de lignes qui suivront, les 2 premières lignes sont toujours de la même forme)
--
-- Entrée
--     5
--     90 80 1
--     7
--     0 0
--     -3 -22
--     -4 15
--     9 -9
--     4 21
--     -13 7
--     18 9


procedure Ex2 is
   
   package Txt renames Ada.Text_IO ;
   package IO renames File_Io ;
   
   Read : IO.T_Reader := IO.Fopen("files/ex2.txt") ;
   A,N : Integer ;
   X,Y : Integer ;
begin
   
   -- First line
   A := Read.Int ;
   Txt.Put_Line("First line is " & A'image) ;
   
   -- Second line: an array
   declare
      Ar : IO.Intarray := Read.Ints ;
   begin
      Txt.Put_Line("Second line, intarray is " & IO.Intarray2s(Ar)) ;
   end ;
     
   -- Third line: a number
   N := Read.Int ;
   Txt.Put_Line("Now reading " & N'Image & " lines.") ;
   
   -- Next lines : N pairs
   for I in 1..N loop
      
      X := Read.Int ;
      Y := Read.Int ;
      
      Txt.Put_Line(" Found pair : " & X'Image & ", " & Y'image) ;
   end loop ;
      
   Txt.New_Line ;
   Read.Fclose ;
      
end Ex2 ;
