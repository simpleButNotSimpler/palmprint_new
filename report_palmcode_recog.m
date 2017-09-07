function report_palmcode_recog()

right_dp = zeros(1, 1);
wrong_dp = right_dp;


%parpool
% parpool(4)

for main_counter=1:500
    disp(num2str(main_counter))
    im_prefix = strcat('p', num2str(main_counter), '_*.bmp');
    
    testim = dir(fullfile('data\testimages\cleaned', im_prefix));
    if isempty(testim)
       continue
    end
    
    if numel(testim) ~= 6
        disp('nou la')
    end
    
    %recognition
    for t=5:numel(testim)
       current_im_name = testim(t).name;
        
       %get class (1xN array), same size as error
       [dp] = report_score(current_im_name);
       
%        plot(1:numel(dp), dp, 'r*')
       
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
    end
 end

%write result to file
try
fid = fopen('recog_palmcode_aligned.txt', 'w');
fprintf(fid, '%s\n', 'DP');
fprintf(fid, '%4d %4d\n', [right_dp; wrong_dp]);
fclose(fid);
catch
   disp('problem') 
end

% delete(gcp('nocreate'))
winopen('recog_palmcode_aligned.txt');
disp('nou fini')
end


function dp = report_score(im_test_name)   
   %test the image against all the database
   folder_dc = 'data\database\direction_code';
   dp = zeros(500, 1) + inf;
   
   for t=1:500
       db_name = strcat('db', num2str(t),'_*.bmp');
       database_dc = dir(fullfile(folder_dc, db_name));
       
       %get the score form direct palmcode 
       dp(t, :) = direct_palmcode(im_test_name, database_dc);
       
   end
end