function write_sys(sys, path)
  fid = fopen(path, 'wt');
  tf_string = evalc('sys');
  fprintf(fid, tf_string);
  fclose(fid);
end

