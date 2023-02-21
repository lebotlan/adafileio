# adafileio
Ada helper library to read data from text files.

## Example


```ada
   -- This example reads integers from standard input (""), e.g. one integer on each line.
   Read : IO.T_Reader := IO.Fopen("") ;
   X : Integer ;
begin   
   while not Read.EOF loop
      X := Read.Int ;
   end loop ;
```

See all the examples: files ex1.adb, ex2.adb, ...
