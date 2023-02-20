with Ada.Unchecked_Deallocation ;
with Ada.Text_IO ;
with Ada.Strings.Fixed ;

package body File_Io is
   
   package IO renames Ada.Text_IO ;
   package SF renames Ada.Strings.Fixed ;
   
   procedure Free is new Ada.Unchecked_Deallocation(String, String_Access) ;
   procedure LFree is new Ada.Unchecked_Deallocation(T_Lines, T_Lines_Access) ;
   
   -- Get the tfile structure, check it is not closed.
   function Tfile (Read : T_Reader) return access T_File is
   begin
      if Read.F.Closed then 
         raise Already_Closed ;
      else      
         return Read.F ;
      end if ;
   end TFile ;
   
   -- Getters
   function Nb_Lines(Read : T_Reader) return Integer is
   begin
      return Read.Tfile.Lines.all'Length ;
   end Nb_Lines ;
   
   function EOF (Read : T_Reader) return Boolean is 
   begin
      return Read.Tfile.EOF ;
   end EOF ;
   
   function EOL (Read : T_Reader) return Boolean is 
   begin
      return Read.Tfile.EOL ;
   end EOL ;
   
   function Content (Read : T_Reader) return T_Lines_access is
   begin
      return Read.Tfile.Lines ;
   end Content ;
   
   -- Debug
   procedure Show_Pos(F : access T_File ; Title : String := "") is
   begin
      IO.Put_Line(" POS[" & Title & "] = (" & F.PL'Image & ", " & F.PC'Image & ")") ;
   end Show_Pos ;

   
   -- Update the flags EOF, EOL according to the current position.
   procedure Update_Flags(F : access T_File) is
      
   begin
      if F.PL in F.Lines'Range then
         -- In file
         
         if F.PC in F.Lines(F.PL).all'Range then
            -- In line
            F.EOF := False ;
            F.EOL := False ;
         else
            -- Outside the line
            if F.PL = F.Lines'Last then
               -- Outside the last line => EOF
               F.EOF := True ;
               F.EOL := True ;
            else
               F.EOF := False ;
               F.EOL := True ;
            end if ;
            
         end if ;      
      else
         -- Not in file
         F.EOF := True ;
         F.EOL := True ;
      end if ;
      
   end Update_Flags ;
      
   -- Constructor
   function Fopen (File : String ;
                   Strip : Boolean := True ;
                   Ignore_Empty_Lines : Boolean := True                     
                  ) return T_Reader is
      
      -- Default init size of lines array.
      Default_Size: constant Integer := 200 ;
      
      -- Strip each read line if the option is set.
      function Line_Strip(Line : String) return String is
      begin
         if Strip then 
            return SF.Trim(Line,Ada.Strings.Both) ;
         else
            return Line ;
         end if ;
      end Line_Strip ;
      
      -- Read all lines from the file (optionnally strip and ignore empty lines)
      Function Get_All_Lines(Handler : IO.File_type) return T_Lines_Access is
         Lines: T_Lines_access := new T_Lines(1..Default_Size) ;
         
         -- Index of next line to be put in Lines.
         Nb : Integer := 1 ;
         
         -- Add a line to the buffer. Expand the buffer if necessary.
         procedure Append_Line(L : String_access) is
            Old_Lines: T_Lines_Access ;
            Newsize : Integer ;
         begin
            if NB not in Lines'Range then
               -- Reallocate
               Old_Lines := Lines ;
               Newsize := Lines'Length * 4 ;
               
               Lines := new T_Lines(1..newsize) ;
               for I in Old_Lines'Range loop
                  Lines(I) := Old_Lines(I) ;
               end loop ;
               
               LFree(Old_Lines) ;
            end if ;
            
            Lines(NB) := L ;
            NB := NB + 1 ;
         end Append_Line ;
      begin
         
         while not IO.End_Of_File(Handler) loop
            declare 
               Line : String := Line_Strip(IO.Get_Line(Handler)) ;
               Line2 : String(1..Line'Length) := Line ;
            begin
               if Ignore_Empty_Lines and Line'length = 0 then null ;
               else
                  Append_Line(New String'(Line2)) ;
               end if ;
            end ;
         end loop ;
         
         -- Finished, trim the table.
         declare
            Lines2: T_Lines_Access := new T_Lines(1..Nb-1) ;
         begin
            for L in Lines2'Range loop
               Lines2(L) := Lines(L) ;
            end loop ;
            
            LFree(Lines) ;
            return Lines2 ;
         end ;
      end Get_All_Lines ;
      
      Res : T_Reader ;
      F : access T_File := new T_File ;
      Handler : IO.File_Type ;
   begin
      F.Filename := new String'(File) ;
      
      IO.Open (Handler, IO.In_File, File) ;      
      F.Lines := Get_All_Lines(Handler) ;
      IO.Close (Handler) ;
      
      F.Closed := False ;
      F.PL := 1 ;
      F.PC := 1 ;
      
      Update_Flags(F) ;
      
      Res.F := F ;
      
      return Res ;
   end Fopen ;
      
   procedure Fclose(Read : T_Reader) is
      F : access T_File := Read.Tfile ;
   begin
      F.Closed := True ;
      
      -- Deallocate      
      Free(F.Filename) ;
      
      for L of F.Lines.all loop
         Free(L) ;
      end loop ;      
      
      LFree(F.Lines) ;
   end Fclose ;
   
   procedure NL(Read :  T_Reader) is
      F : access T_File := Read.Tfile ;
   begin
      F.PL := F.PL + 1 ;
      F.PC := 1 ;
      Update_Flags(F) ;
   end NL ;
   
   type T_Status is (S_ok, S_Eol, S_Eof, S_bad) ;
   
   type T_Char is record
      St : T_Status ;
      Ch : Character ;
   end record ;
   
   -- Peeks next char
   -- Flags are supposed to be up to date.
   function Peek_Char(F : access T_File) return T_Char is
   begin
      if F.EOF then return (S_Eof, Zero_Char) ;
      elsif F.EOL then return (S_Eol, Zero_Char) ;
      else
         return (S_Ok, F.Lines.all(F.PL).all(F.PC)) ;
      end if ;
   end Peek_Char ;
   
   function Peek_Current(Read : T_Reader) return String is
      F : access T_File := Read.Tfile ;
      What : T_Char := Peek_Char(F) ;
      Last : Integer ;
   begin
      case What.St is
         when S_Eof | S_Eol | S_Bad => return "" ;
         when S_Ok =>
            Last := F.Lines.all(F.PL).all'Last ;
            return F.Lines.all(F.PL).all(F.PC..last) ;
      end case ;
   end Peek_Current ;
   
   -- Next char on the same line.
   procedure Next(F : access T_File) is
   begin
      if F.EOF then null ;
      elsif F.EOL then null ;
      else
         F.PC := F.PC + 1 ;
         Update_Flags(F) ;
      end if ;
   end Next ;
   
   HT : constant Character := Character'Val(9);
   
   function Is_Space(Char : Character) return Boolean is
   begin
      case Char is
         when ' ' | HT => return True ;
         when others => return False ;
      end case ;
   end Is_Space ;

   procedure Skip_Spaces(Read :  T_Reader ; Skip_Nl : Boolean := false) is
      F : access T_File := Read.Tfile ;
      Continue : Boolean := True ;
      What : T_Char ;
   begin
      while Continue loop
         What := Peek_Char(F) ;
         
         case What.St is
            when S_Eof | S_Bad => Continue := False ; 
               
            when S_Eol => 
               if Skip_Nl then
                  Nl(Read) ;
               else
                  Continue := False ;
               end if ;
               
            when S_Ok =>
               if Is_Space(What.Ch) then Next(F) ;
               else Continue := False ;
               end if ;               
         end case ;
      end loop ;
   end Skip_Spaces ;
   
   
   -- Reading functions
      
   function Str(Read :  T_Reader ; Until_char : Character) return String is
      F : access T_File := Read.Tfile ;
      Start : T_File := F.all ;
      Continue : Boolean := True ;
      What : T_Char ;
   begin 
      
      if F.Eof then return "" ;
      else
         while Continue loop
            What := Peek_Char(F) ;
            case What.St is
               when S_Eof | S_Eol | S_Bad => Continue := False ;
               when S_Ok => 
                  Next(F) ;
                  Continue := What.Ch /= Until_Char ;
            end case ;
         end loop ;
         
         return F.Lines.all(F.PL).all(Start.PC..F.PC-1) ;
         
      end if ;
      
   end Str ;
   
   function XStr(Read :  T_Reader ; Until_char : Character) return String is
      S : String := Str(Read,Until_Char) ;
   begin
      if S'Length > 0 and then S(S'Last) = Until_Char then
         return S(S'First..S'Last-1) ;
      else
         return S ;
      end if ;
   end XStr ;
   
   function Multiline_Str(Read :  T_Reader ; Until_char : Character ; Eol_Chars : String := LF) return String is
      F : access T_File := Read.Tfile ;      
      
      function Sloop(Acu : String) return String is
         Chunk : String := Read.Str(Until_Char) ;
      begin
         if Chunk'Length > 0 and then Chunk(Chunk'Last) = Until_Char then
            -- Until_char is found.
            return Acu & Chunk ;
                       
         else
            -- The until_char was not found. The chunk might be empty.
            if F.EOF then 
               -- No more stuff
               return Acu & Chunk ;
            else
               
               if not F.EOL then raise Program_Error ; end if ;
               
               -- Try next line.
               Read.NL ;
               return Sloop(Acu & Chunk & Eol_chars) ;
            end if ;
              
         end if ;
         
      end Sloop ;
   begin      
      return Sloop("") ;
   end Multiline_Str ;
   
   type T_Int is record
      St : T_Status ;
      II : Integer ;
   end record ;
   
   -- Must be at the begining of the integer
   function Raw_Int (F : access T_File) return T_Int is
      What : T_Char ;
      Backup : T_File := F.all ;
      
      function Read_Digits(Sign : Integer ; N : Integer ; First : Boolean) return T_Int is
         N2 : Integer ;
      begin
         What := Peek_Char(F) ;
         case What.St is
            when S_Eof | S_Eol | S_Bad => 
               if First then
                  -- This is not an int. Backup.
                  F.all := Backup ; return (What.St, 0) ;
               else
                  -- OK, we are finished.
                  return (S_Ok, Sign * N) ;
               end if ;
               
            when S_Ok =>
               case What.Ch is
                  when '0'..'9' =>                      
                     N2 := 10 * N + Character'Pos(What.Ch) - Character'Pos('0') ;
                     Next(F) ;
                     return (Read_Digits(Sign, N2, False)) ;
                     
                  when others => 
                     if First then
                        F.all := Backup ; 
                        return (S_Bad, 0) ;
                     else
                        return (S_Ok, Sign * N) ;
                     end if ;
               end case ;
         end case ;
      end Read_Digits ;
      
   begin      
      -- Check first char
      What := Peek_Char(F) ;
      
      case What.St is
         when S_Eof | S_Eol | S_Bad => return (What.St, 0) ;
         when S_Ok => 
            
            case What.Ch is
               when '0'..'9' => return Read_Digits(1, 0, True) ;
               when '+' => Next(F) ; return Read_Digits(1, 0, True) ;
               when '-' => Next(F) ; return Read_Digits(-1, 0, True) ;
               when others => return (S_Bad, 0) ;
            end case ;
            
      end case ;

   end Raw_Int ;

   function Int (Read :  T_Reader ; Bad_Value : Integer := -1) return Integer is
      F : access T_File := Read.Tfile ;
      R : T_Int ;
   begin
      Skip_Spaces(Read, True) ;      
      R := Raw_Int(F) ;
      
      case R.St is
         when S_Eof | S_Eol | S_Bad => return Bad_Value ;
         when S_Ok => return R.Ii ;            
      end case ;
   end Int ;
   
   function Intarray2S (A : Intarray) return String is
      
      function iloop(Acu : String ; I : Integer) return String is
      begin
         if I not in A'Range then
            return Acu ;
         elsif Acu = "" then return Iloop(A(I)'image, I+1) ;
         else return Iloop(Acu & ", " & A(i)'image,I+1) ;
         end if ;
      end iloop ;
      
   begin
      return Iloop("", A'First) ;
   end Intarray2S ;
   
   function Ints (Read :  T_Reader) return Intarray is
      
      F : access T_File := Read.Tfile ;
      Backup : T_File ;
      
      function Count_Ints(N : Integer) return Integer is
         RI : T_Int ;
      begin
         Skip_Spaces(Read, False) ;      
         RI := Raw_Int(F) ;
         case RI.St is
            when S_Eof | S_Eol | S_Bad => return N ;
            when S_Ok => return (Count_Ints(N+1)) ;
         end case ;
      end Count_Ints ;
      
      Nb : Integer ;
      RI : T_Int ;
   begin
      Skip_Spaces(Read, True) ;
      Backup := F.all ;
      NB := Count_Ints(0) ;
      
      -- Reset
      F.all := Backup ;
      
      declare
         Res : Intarray(1..Nb) := (others => 0) ;
      begin
         for I in Res'Range loop
            Skip_Spaces(Read,False) ;
            RI := Raw_Int(F) ;
            
            case RI.St is
               when S_Eof | S_Eol | S_Bad => raise Program_Error ;
               when S_Ok =>
                  Res(I) := RI.II ;
            end case ;
         end loop ;
         
         return Res ;
      end ;
   end Ints ;
   
   
   function Char (Read :  T_Reader ;
                  Bad_Value : Character := Zero_Char) return Character is
      F : access T_File := Read.Tfile ;
      What : T_Char ;
   begin      
      Skip_Spaces(Read, True) ;      
      What := Peek_Char(F) ;
      
      case What.St is
         when S_Eof | S_Eol | S_Bad => return Bad_Value ;
         when S_Ok => 
            Next(F) ;
            return What.Ch ;
      end case ;
   end Char ;


   
end File_Io ;
