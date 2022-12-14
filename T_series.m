
wdir = '/Users/sung/Desktop/20181116_TaS2_Heating/T_series/';

files = dir( [wdir '*.raw']);
num_files = length(files);
dim = 64;

for ind_file = 1:num_files
    fname = files(ind_file).name;
    e = datacube(read_empad([wdir fname],dim));

    im(:,:,ind_file) = e.getSingleImage(30,21);
end
%%
figure;
imagesc(e.getSingleImage(30,21))