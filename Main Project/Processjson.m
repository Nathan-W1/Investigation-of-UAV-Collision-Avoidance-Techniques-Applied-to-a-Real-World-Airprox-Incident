function [fileoutput] = Processjson(filename)

    fname = filename; 
    fid = fopen(fname); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    fileoutput = jsondecode(str);

    save fileoutput

end