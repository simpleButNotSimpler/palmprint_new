%% get the image
[path1, name] = uigetfile('data\testimages\direction_code\*.bmp', 'test');
if ~name
    return
end
test_im = imread(fullfile(name, path1));

[path2, name] = uigetfile('data\database\direction_code\*.bmp', 'database');
if ~name
    return
end
dbase_im = imread(fullfile(name, path2));
figure, imshowpair(test_im, dbase_im)

%% alignment
test_canny = imread(fullfile('data\testimages\cleaned', path1));
db_canny = imread(fullfile('data\database\cleaned', path2));
raw_test_im = imread(fullfile('data\testimages\raw', path1));
raw_db_im = imread(fullfile('data\database\raw', path2));

[angle, trans, cf, direction] = test_alignment_one(test_canny, db_canny);

if direction
   temp = test_im;
   test_im = dbase_im;
   dbase_im = temp;
   
   temp = raw_test_im;
   raw_test_im = raw_db_im;
   raw_db_im = temp;
end

original = palmcode_diff(test_im, dbase_im)
% figure, imshowpair(test_canny, db_canny)

%% transformation info
RA = imref2d(size(raw_test_im));
imt = imtranslate(raw_test_im, RA, trans');
raw_test_output = rotateAround(imt, cf(2), cf(1), angle);

%% get the score of the images
%test
[temp, ~] = edgeresponse(raw_test_output);
[~, dc_test_output] = edgeresponse(imcomplement(temp));

not_cropped = palmcode_diff(dc_test_output, dbase_im)
figure, imshowpair(dc_test_output, dbase_im), title('no cropping')

[row, col, dc_test_output] = crop_rotation(dc_test_output);
dc_db_output = dbase_im(row(1):row(2), col(1):col(2));

cropped = palmcode_diff(dc_test_output, dc_db_output)
figure, imshowpair(dc_test_output, dc_db_output), title('cropped')

dc_test_output_rebased = imresize(dc_test_output, [128, 128]);
dc_db_output_rebased = imresize(dc_db_output, [128, 128]);

figure, imshowpair(dc_test_output_rebased, dc_db_output_rebased), title('resized')

%resized
raw_test_output_resized = raw_test_output(row(1):row(2), col(1):col(2));
raw_test_output_resized = imresize(raw_test_output_resized, [128, 128]);

raw_db_output_resized = raw_db_im(row(1):row(2), col(1):col(2));
raw_db_output_resized = imresize(raw_db_output_resized, [128, 128]);

[temp, ~] = edgeresponse(raw_test_output_resized);
[~, dc_test_output_resized] = edgeresponse(imcomplement(temp));

[temp, ~] = edgeresponse(raw_db_output_resized);
[~, dc_db_output_resized] = edgeresponse(imcomplement(temp));


resized = palmcode_diff(dc_test_output_resized, dc_db_output_resized)
figure, imshowpair(dc_test_output_resized, dc_db_output_resized), title('resized real')

%%
% no_cropped = palmcode_diff(dc_test_output, dbase_im)
% 
% dbase_im_rebased = dbase_im(row(1):row(2), col(1):col(2));
% dbase_im_rebased = imresize(dbase_im_rebased, [128, 128]);
% 
% rebased = palmcode_diff(dc_test_output, dbase_im_rebased)
% figure, imshowpair(dc_test_output, dbase_im_rebased)

% direction_code = direction_code(row(1):row(2), col(1):col(2));
% dbase_im_out = dbase_im(row(1):row(2), col(1):col(2));
% 
% cropped = palmcode_diff(direction_code, dbase_im_out)
% no_cropped = palmcode_diff(direction_code_nocrop, dbase_im)
