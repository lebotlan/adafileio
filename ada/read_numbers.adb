with Ada.Text_IO ;
with File_Io ;

procedure Read_Numbers is
   
   package Txt renames Ada.Text_IO ;
   package IO renames File_Io ;
   
   -- Read the whole given file, and close it.
   procedure Test_Int(Title : String ; Read : IO.T_Reader) is
      X : Integer ;
      C : Character := ' ' ;
   begin
      Txt.Put_Line("Test: " & Title) ;
      
      -- Show all file's content.
      for L of Read.Content.all loop
         Txt.Put_Line("Line ::" & L.all & "::") ;
      end loop ;
      
      
      while not Read.EOF loop
         --Txt.Put_Line("Before : >" & Read.Peek_Current & "<") ;
         --Read.Skip_Spaces(True) ;
         --Txt.Put_Line("After : >" & Read.Peek_Current & "<") ;
         
         --C := Read.Char ;
         --Txt.Put_Line("Char read : pos = " & Character'Pos(C)'Image & "   => " & C'image) ;
         
         --if Read.EOL then Read.NL ; end if ;
         
         --X := Read.Int ;
         --Txt.Put_Line(" Read : " & X'Image ) ;
         
         Txt.Put_Line("Array : " & IO.Intarray2s(Read.Ints)) ;
      end loop ;
      
      Read.Fclose ;
      
      Txt.Put_Line("Done " & Title) ;
      Txt.New_Line ;
      Txt.New_Line ;
      
   end Test_Int ;
   
begin
   
   Test_Int("empty file", IO.Fopen(File => "files/empty.txt", Strip => False, Ignore_Empty_Lines => False)) ;   
   Test_Int("empty file", IO.Fopen(File => "files/empty.txt", Strip => True, Ignore_Empty_Lines => True)) ;   
   
   Test_Int("numbers.txt stripped and without empty lines", IO.Fopen(File => "files/numbers.txt", Strip => True, Ignore_Empty_Lines => True)) ;   
   Test_Int("numbers.txt stripped and with empty lines", IO.Fopen(File => "files/numbers.txt", Strip => True, Ignore_Empty_Lines => False)) ;   
   Test_Int("numbers.txt not stripped and without empty lines", IO.Fopen(File => "files/numbers.txt", Strip => False, Ignore_Empty_Lines => True)) ;
   Test_Int("numbers.txt not stripped and with empty lines",    IO.Fopen(File => "files/numbers.txt", Strip => False, Ignore_Empty_Lines => False)) ;
   
end Read_Numbers ;
