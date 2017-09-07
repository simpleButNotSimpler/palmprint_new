function report_palmcode_verif_dp()

n1 = zeros(1, 13);
n2 = n1;
n3 = n1;
n4 = n1;
total_pos = 0;
total_neg = 0;

error = [0.2 0.25 0.27 0.29 0.3 0.32 0.34 0.4 0.5 0.6 0.7 0.8 0.9];

for main_counter=1:10    
    disp(num2str(main_counter))
    db_prefix = strcat('db', num2str(main_counter));
    im_prefix = strcat('p', num2str(main_counter));
    
    database = dir(strcat('data\database\direction_code\', db_prefix, '_*.bmp'));
    testim = dir(strcat('data\testimages\direction_code\', im_prefix, '_*.bmp'));
    
    %positive
    scores = report_score(testim, database);
    
    for sc=1:numel(scores)
        %score = floor(scores(sc)*10);
        score = scores(sc);
        idx_n1 = score <= error;
        idx_n2 = score > error;
        
        n1 = n1 + idx_n1;
        n2 = n2 + idx_n2;
    end
    
    total_pos = total_pos + numel(scores);
    
    %negative
    for t=1:500
       if t == main_counter
          continue
       end       
       
       %load the two sets
       db_prefix = strcat('db', num2str(t));
       database = dir(strcat('data\database\direction_code\', db_prefix, '_*.bmp'));
       
       %get score
       scores = report_score(testim, database);
       for sc=1:numel(scores)
           %score = floor(scores(sc)*10);
           score = scores(sc);
           idx_n3 = score <= error;
           idx_n4 = score > error;

           n3 = n3 + idx_n3;
           n4 = n4 + idx_n4;
       end
       
       total_neg = total_neg + numel(scores);
    end
end

%write result to file
output = [n1; n2; n3; n4];
fid = fopen('report_palmcode_without_al.txt', 'w');
fprintf(fid, '%4s %4s %4s %4s\n', 'N1', 'N2', 'N3', 'N4');
fprintf(fid, '%4d %4d %4d %4d\n', output);
fprintf(fid, '\n\n%10s %4d \n%10s %4d\n', 'Total_pos = ', total_pos, 'Total_neg = ', total_neg);
fclose(fid);

disp('nou fini')
winopen('report_palmcode_without_al.txt')
end


function score = report_score(testimage, database)
   %run icp on every image
   im_len = length(testimage);
   score = zeros(1, im_len);
   idx = [];
   
   for t=1:im_len
       [~, gloabl_min, witness] = build_alignment_one(testimage(t).name, database);
       if ~witness
          idx = [idx, t];
          continue
       end
       
       %score
       score(t) = gloabl_min;   
   end
   
   score(idx) = [];
end

function [winner_idx, gloabl_min, witness] = build_alignment_one(test_im_name, database)
db_len = length(database);
witness = 0;
winner_idx = 1;

gloabl_min = inf;

dc_test_im = read_image(fullfile('data\testimages\direction_code', test_im_name));
canny_test_im = read_image(fullfile('data\testimages\canny', test_im_name));
if isempty(find(dc_test_im, 1))
   return
end

for counter=1:db_len
    % get the image image for one person
    dc_db_im = read_image(fullfile(database(counter).folder, database(counter).name));
    canny_db_im = read_image(fullfile('data\database\canny', database(counter).name));
    
    if isempty(find(dc_db_im, 1))
        continue
    end
    
    witness = 1;
    
    
    score = palmcode_diff_weights_fused(dc_test_im, dc_db_im, canny_test_im, canny_db_im);
%     score = palm_histo_score(moving_im, fixed_im);
    %global_min
    if score < gloabl_min
        winner_idx = counter;
        gloabl_min = score;
    end
end

end