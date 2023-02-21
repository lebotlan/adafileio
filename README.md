# adafileio
Ada helper library to read text files, line by line

## Example


```ada
   -- This example reads integers from a file (e.g. one integer on each line)
   Read : IO.T_Reader := IO.Fopen("files/ex1.txt") ;
   X : Integer ;
begin   
   while not Read.EOF loop
      X := Read.Int ;
   end loop ;
```

See all the examples: files ex1.adb, ex2.adb, ...
