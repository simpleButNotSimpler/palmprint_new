function report_palmcode_recog_shrink()
total = 0;
right_dp = zeros(1, 15);
wrong_dp = right_dp;

%parpool
% parpool(4)

parfor main_counter=1:100
    disp(num2str(main_counter))
    im_prefix = strcat('p', num2str(main_counter), '_*.bmp');
    
    testim = dir(fullfile('data\testimages\direction_code', im_prefix));
    if isempty(testim)
       continue
    end
    
    if numel(testim) ~= 6
        disp('nou la')
    end
    
    %recognition
    for t=1:numel(testim)
       current_im_name = testim(t).name;
        
       %get class (1xN array), same size as error
       [dp] = report_score(current_im_name);
       
       %classification
       %min indexes
       [~, dp_min_idx] = min(dp);
       
       %verdicts
       idx = (dp_min_idx == main_counter);
       right_dp = right_dp + idx;
       wrong_dp = wrong_dp + ~idx;
       
       if ~idx(1)
          fid = fopen('mismatched_dp.txt', 'a');
          fprintf(fid, '%10s %3d \n', current_im_name, dp_min_idx(1));
          fclose(fid);
       end
              
       total = total + 1;
    end
 end

%write result to file
fid = fopen('recog_palmcode_dp_shrink.txt', 'w');
fprintf(fid, '%s\n', 'DP');
fprintf(fid, '%4d %4d\n', [right_dp; wrong_dp]);
fclose(fid);

% delete(gcp('nocreate'))
disp('nou fini')
end


function [dp] = report_score(im_test_name)
   %image
   
   %test the image against all the database
   folder_dc = 'data\database\direction_code';
   dp = zeros(100, 10) + inf;
   
   for t=1:100
       db_name = strcat('db', num2str(t),'_*.bmp');
       database_dc = dir(fullfile(folder_dc, db_name));
       
       %get the score form direct palmcode
       dp(t, :) = direct_palmcode_shrink(im_test_name, database_dc);
   end
end