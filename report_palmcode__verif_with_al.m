function report_palmcode__verif_with_al()
n1 = zeros(1, 9);
n2 = n1;
n3 = n1;
n4 = n1;
total_pos = 0;
total_neg = 0;

idx = 1:9;
error = [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9];

for main_counter=125:185
    disp(num2str(main_counter))
    db_prefix = strcat('db', num2str(main_counter));
    im_prefix = strcat('p', num2str(main_counter));    
    
    database = dir(strcat('data\database\direction_code\', db_prefix, '_*.bmp'));
    testim = dir(strcat('data\testimages\direction_code\', im_prefix, '_*.bmp'));
    if isempty(database) || isempty(testim)
       continue
    end
    
    if numel(testim) ~= 5
        disp('nou la')
    end
    
    %positive
    scores = report_score(testim, database);
    
    for sc=1:numel(scores)
        %score = floor(scores(sc)*10);
        score = scores(sc);
        idx_n1 = idx(score <= error);
        idx_n2 = idx(score > error); 
        
        n1(idx_n1) = n1(idx_n1) + 1;
        n2(idx_n2) = n2(idx_n2) + 1;
        
        if score >= 2.5
            disp(testim(sc).name)
        end
    end
    
    total_pos = total_pos + numel(scores);
    
    %negative
    for t=1:185
       if t == main_counter
          continue
       end
       
       
       %load the two sets
       db_prefix = strcat('db', num2str(t));
       database = dir(strcat('data\database\direction_code\', db_prefix, '_*.bmp'));
       if isempty(database)
          continue
       end
       
       %get score
       scores = report_score(testim, database);
       for sc=1:numel(scores)
           %score = floor(scores(sc)*10);
           score = scores(sc);
           idx_n3 = idx(score <= error);
           idx_n4 = idx(score > error);

           n3(idx_n3) = n3(idx_n3) + 1;
           n4(idx_n4) = n4(idx_n4) + 1;
       end
       
       total_neg = total_neg + numel(scores);
    end
end

%write result to file
output = [n1; n2; n3; n4];
fid = fopen('report_palmcode_verif_with_al.txt', 'w');
fprintf(fid, '%4s %4s %4s %4s\n', 'N1', 'N2', 'N3', 'N4');
fprintf(fid, '%4d %4d %4d %4d\n', output);
fprintf(fid, '\n\n%10s %4d \n%10s %4d\n', 'Total_pos = ', total_pos, 'Total_neg = ', total_neg);
fclose(fid);

disp('nou fini')
end


function score = report_score(testimage, database)
   %run icp on every image
   im_len = length(testimage);
   score = zeros(1, im_len);
   idx = [];
   %fid = fopen('aligned_data.txt', 'a');
   
   for t=1:im_len
       test_im_name = testimage(t).name;
       current_im = imread(fullfile(testimage(t).folder, test_im_name));
       if isempty(find(current_im, 1))
           continue
       end
       
       [error, witness] = build_alignment_one(current_im, database, test_im_name);
       if ~witness
           idx = [idx, t];
           continue
       end
       
       score(t) = error;      
   end
   
   %fclose(fid);
   score(idx) = [];
end

function [gloabl_min, witness] = build_alignment_one(moving_im, database, test_im_name)
db_len = length(database);
witness = 0;

gloabl_min = inf;

for counter=1:db_len
    % get the image image for one person
    db_im_name = database(counter).name;
    fixed_im = imread(fullfile(database(counter).folder, db_im_name));
    
    if isempty(find(fixed_im, 1))
        continue
    end
    
    witness = 1;
    
    err = get_palmcode_error(moving_im, fixed_im, test_im_name, db_im_name);
    
    %statistics
    min_er = err;
    
    %global_min
    if min_er < gloabl_min
        gloabl_min = min_er;
    end
end


end

function score = get_palmcode_error(test_im, dbase_im, path1, path2)
    score1 = palm_histo_score(test_im, dbase_im);
   
    %align
    test_canny = imread(fullfile('data\testimages\cleaned', path1));
    db_canny = imread(fullfile('data\database\cleaned', path2));

    [angle, trans, cf, direction] = test_alignment_one(test_canny, db_canny);

    if direction
       dbase_im = test_im;
       test_im = imread(fullfile('data\database\raw_database', path2));
    else
        test_im = imread(fullfile('data\testimages\raw_testimages', path1));
    end
    
    %translation
    translation = trans';
    RA = imref2d(size(test_im));
    imt = imtranslate(test_im, RA, translation);
    
    %rotation
    output = rotateAround(imt, cf(2), cf(1), angle);
    
    %recompute palmcode
    [output, ~] = edgeresponse(output);
    [~, direction_code] = edgeresponse(imcomplement(output));

    %crop
    direction_code = direction_code(2:end, 2:end);
    dbase_im = dbase_im(2:end, 2:end);

    center = 64;
    pad = 50;

    direction_code = direction_code(center-pad:center+pad, center-pad:center+pad);
    dbase_im = dbase_im(center-pad:center+pad, center-pad:center+pad);

    %score
    score2 = palm_histo_score(direction_code, dbase_im);
    
    if score1 < score2
        score = score1;
    else
        score = score2;
    end
end

function [angle, trans, cf, direction] = test_alignment_one(moving_im, fixed_im)
cf = 0;
direction = 0;
    
    if isempty(find(fixed_im, 1))
        return
    end
    
    % datasets
    [y, x] = find(fixed_im);
    M = [x, y];

    [y, x] = find(moving_im);
    D = [x, y];
%tic
    %first way
    [~, T1, ~, angle1, er1, cf1] = icp(D, M, 50, 0.0001, 0);
%toc
%tic
    %second way
    [~, T2, ~, angle2, er2,  cf2] = icp(M, D, 50, 0.0001, 0);
%toc   
    % statistics
     er1_1 = er1(end);
     er2_1 = er2(end);
     
     if er1_1 < er2_1
         direction = 0;
         cf = cf1;
         angle = angle1;
         trans = T1;
     else
         direction = 1;
         cf = cf2;
         angle = angle2;
         trans = T2;
     end
end










