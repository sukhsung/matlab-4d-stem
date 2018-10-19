

fname = 'test.raw';

fid = fopen('test.raw');


i = 16;

A = fread(fid, 128*128*128*130,'long',0,'l');
im = reshape(A(1:end),[128,130,128,128]);

im = im - min(im(:)) - 1*10^13;
im = im - min(im(:));
%im = log(im + 1);
vis4D(im)