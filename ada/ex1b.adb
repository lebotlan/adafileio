with Ada.Text_IO ;
with File_Io ;

-- Exemple : un nombre par ligne
--
-- Entrée
--
--    40
--    120
--    70

procedure Ex1 is
   
   package Txt renames Ada.Text_IO ;
   package IO renames File_Io ;
   
   -- From stdin
   Read : IO.T_Reader := IO.Fopen("") ;
   X : Integer ;
begin
   
   while not Read.EOF loop
      X := Read.Int ;
      
      Txt.Put_Line(" Found int : " & X'image) ;
   end loop ;
   
   Txt.New_Line ;
   Txt.Put_Line(Read.Nb_Lines'Image & " lines read.") ;
   Txt.New_Line ;
   Txt.New_Line ;     
   
   Read.Fclose ;
      
end Ex1 ;
