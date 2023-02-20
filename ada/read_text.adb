with Ada.Text_IO ;
with File_Io ;

procedure Read_Text is
   
   package Txt renames Ada.Text_IO ;
   package IO renames File_Io ;
   
   -- Read the whole given file, and close it.
   procedure Test_Txt(Title : String ; Read : IO.T_Reader) is
   begin
      Txt.Put_Line("Test: " & Title & "  " & Read.Nb_Lines'Image & " lines.") ;
      
      -- Show all file's content.
      for L of Read.Content.all loop
         Txt.Put_Line("Line ::" & L.all & "::") ;
      end loop ;
      
      
      while not Read.EOF loop
         Txt.Put_Line("Reading : <" & Read.Multiline_Str('Z') & ">") ;
         
         if Read.Eol then Read.Nl ; end if ;
      end loop ;
      
      Read.Fclose ;
      
      Txt.Put_Line("Done " & Title) ;
      Txt.New_Line ;
      Txt.New_Line ;
      
   end Test_Txt ;
   
begin
   
   Test_Txt("empty file", IO.Fopen(File => "files/empty.txt", Strip => False, Ignore_Empty_Lines => False)) ;   
   Test_Txt("empty file", IO.Fopen(File => "files/empty.txt", Strip => True, Ignore_Empty_Lines => True)) ;   
   
   Test_Txt("text.txt stripped and without empty lines", IO.Fopen(File => "files/text.txt", Strip => True, Ignore_Empty_Lines => True)) ;   
   Test_Txt("text.txt stripped and with empty lines", IO.Fopen(File => "files/text.txt", Strip => True, Ignore_Empty_Lines => False)) ;   
   Test_Txt("text.txt not stripped and without empty lines", IO.Fopen(File => "files/text.txt", Strip => False, Ignore_Empty_Lines => True)) ;
   Test_Txt("text.txt not stripped and with empty lines",    IO.Fopen(File => "files/text.txt", Strip => False, Ignore_Empty_Lines => False)) ;
   
end Read_Text ;
