with Ada.Text_IO ;

--
-- Ada library to read text files (which must fit in memory).
-- (Does not handle UTF files.)
--

package File_Io is
   
   -- Type of a file reader, as created by Fopen next.
   type T_Reader is tagged private;
   
   -- Opens a file. Returns a T_Reader ;
   function Fopen (File : String ;
                   
                   --
                   -- Optional parameters:
                   --
                   
                   -- Do we strip lines ? (Remove spaces and tabs at the beginning and at the end of each line)
                   Strip : Boolean := True ;
                   
                   -- Do we ignore empty lines (such lines are automatically skipped)
                   Ignore_Empty_Lines : Boolean := True
                     
                  ) return T_Reader ;
   
   procedure Fclose(Read : T_Reader) ;
   
   -- number of lines in the file
   -- (if ignore_empty_lines was true, such lines are not counted)
   function Nb_Lines (Read : T_Reader) return Integer ;
   
   Already_Closed: exception ;
   
   -------------------------------------------------------------------------------------------------------
   --            Incremental reading: each reading operation shifts the current reading position
   -------------------------------------------------------------------------------------------------------
   
   -- Indicates if we have reached the end of file.
   -- (True from the beginning if the file is empty).   
   function EOF (Read : T_Reader) return Boolean ;
   
   -- Indicates if we have reached the end of the current line.
   function EOL (Read : T_Reader) return Boolean ;
   
   -- Skip everything until end of current line.
   -- Current point is put on the next line.
   procedure NL (Read :  T_Reader) ;

   -- Skip spaces until something else than a space is found.
   -- skip_NL: if true, also skips newlines.
   procedure Skip_Spaces(Read :  T_Reader ; Skip_Nl : Boolean := false) ;
   
   -- Read a string until the given character (excluded) is found, or end of line.
   -- May return an empty string if the current point is already at the end of line
   -- or if until_char is found at the current position.
   function Str(Read :  T_Reader ; Until_char : Character) return String ;
   
   LF : constant String := "" & ASCII.LF ;
   CR : constant String := "" & ASCII.CR ;
   
   -- Same a str, but does not stop at end of line (stops at end of file, though).
   -- You may specify which end_of_line characters you want in the resulting string (there is no obvious way to know which one is used in the original file).
   function Multiline_Str(Read :  T_Reader ; Until_char : Character ; Eol_Chars: String := LF) return String ;
   
   -- Debug: return what is at the current position
   -- Empty string if end of line or end of file.
   function Peek_Current(Read : T_Reader) return String ;
   
   --------------------------------------------------------------------------------------------
   --
   -- All the following functions work in a similar way: they try to read something from the current point.
   -- 
   -- Spaces and newlines are automatically skipped when looking for the first element (but not for subsequent elements in Ints).
   --
   -- These functions expect an optional argument:
   --      Bad_value: the value returned if something unexpected was found (-1 by default).
   --
   -- For example, function Int below tries to read an integer.
   --   It skips spaces.
   --   If the current point is at the end of line, it tries the next line (and again if needed).
   --   If the current point corresponds to an integer, it returns this integer.
   --   If the current point corresponds to, say, "aaa" instead of an integer, it returns Bad_value (-1).
   --
   -------------------------------------------------------------------------------------------
   
   -- Read an integer on the current line (the current position is shifted after the integer).
   function Int (Read :  T_Reader ; 
                 Bad_Value : Integer := -1) return Integer ;
   
   -- Read as many integers as possible. All the integers are read on the same line.
   -- Stops as soon as it encounters something else than an integer.
   -- Returns an empty array if no integer was found.
   -- It behaves like Int for the first integer of the list.
   
   type IntArray is array (Integer range <>) of Integer ;   
   
   -- toString
   function Intarray2S (A : Intarray) return String ;

   function Ints (Read :  T_Reader) return Intarray ;
   
   Zero_Char : constant Character := Character'Val (0) ;
   
   function Char (Read :  T_Reader ;
                  Bad_Value : Character := Zero_Char) return Character ;

   
   
   --------------------------------------------------------------------------------------------
   --            Auxiliary functions
   --------------------------------------------------------------------------------------------
   
   -- Ada needs this to allow deallocation (!)
   type String_Access is access String ;
   
   -- Lines do not contain the eol character(s).   
   type T_Lines is array(Integer range <>) of String_Access ;
   
   type T_Lines_Access is access T_Lines ;
   
   -- Returns the whole file content. Does not depend on current position.
   function Content (Read : T_Reader) return T_Lines_access ;
   
   -----------------------------------------------------------------------------------------------------------
private   
   type T_File is record
      Filename: String_access ;
      --File: access Ada.Text_IO.File_type ;
      Lines: T_Lines_access ;
      Closed: Boolean ;
      
      -- Current point coordinates (line, column), starting from (1,1)
      --   PC > last_column => end of line
      --   PL > last_line => end of file
      --   PC > last_column and PL = last_line => end_of_file
      PL: Integer ;
      PC: Integer ;
      
      -- Flags corresponding to the current position
      EOF: Boolean ;
      EOL: Boolean ;      
   end record ;
   
   -- Oh la la, Ada.
   type T_Reader is tagged record
      F : access T_File ;
   end record ;
   
end File_Io ;
